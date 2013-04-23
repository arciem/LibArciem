/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 *******************************************************************************/

#import "CRestWorker.h"
#import "ThreadUtils.h"
#import "CNetworkActivity.h"

NSString* const CRestErrorDomain = @"CRestErrorDomain";

NSString* const CRestErrorFailingURLErrorKey = @"CRestErrorFailingURLErrorKey";
NSString* const CRestErrorWorkerErrorKey = @"CRestErrorWorkerErrorKey";
NSString* const CRestErrorOfflineErrorKey = @"CRestErrorOfflineErrorKey";

@interface CRestWorker ()

@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, readwrite, nonatomic) NSURLResponse* response;
@property (strong, nonatomic) NSMutableData* mutableData;
@property (strong, nonatomic) CNetworkActivity* activity;
@property (weak, nonatomic) NSThread* workerThread;
@property (nonatomic) BOOL workerWaitLoopStopped;

@end

@implementation CRestWorker

+ (void)initialize
{
//	CLogSetTagActive(@"C_REST_WORKER", YES);
}

- (id)initWithRequest:(NSURLRequest*)request
{
	if(self = [super init]) {
		self.request = request;
		self.mutableData = [NSMutableData data];
		self.successStatusCodes = [NSIndexSet indexSetWithIndex:200];
		self.showsNetworkActivityIndicator = YES;
	}

	return self;
}

+ (CRestWorker*)workerWithRequest:(NSURLRequest*)request
{
	return [[self alloc] initWithRequest:request];
}

- (NSData*)data
{
	return [NSData dataWithData:self.mutableData];
}

- (NSString*)dataAsString
{
	return [[NSString alloc] initWithData:self.mutableData encoding:NSUTF8StringEncoding];
}

- (id)dataAsJSONWithError:(NSError**)error
{
	id json = [NSJSONSerialization JSONObjectWithData:self.mutableData options:0 error:error];
	if(json == nil) {
		CLogError(nil, @"%@ Parsing JSON: %@", self, *error);
	}
	return json;
}

- (id)dataAsJSON
{
	return [self dataAsJSONWithError:nil];
}

- (NSHTTPURLResponse*)httpResponse
{
	NSHTTPURLResponse* httpResponse = nil;
	if([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
		httpResponse = (NSHTTPURLResponse*)self.response;
	}
	return httpResponse;
}

- (void)didCancel
{
	[super didCancel];
	[self.connection cancel];
}

- (void)operationDidBegin
{
	[super operationDidBegin];
	self.activity = [CNetworkActivity activityWithIndicator:self.showsNetworkActivityIndicator];
}

- (void)operationWillEnd
{
	[super operationWillEnd];
	self.activity = nil;
}

- (BOOL)isOffline
{
	return NO;
}

- (void)performOperationWork
{
	CLogTrace(@"C_REST_WORKER", @"%@ starting NSURLConnection: %@", self, self.request);
	
    self.workerThread = [NSThread currentThread];
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	if(self.isOffline) {
		CLogTrace(@"C_REST_WORKER", @"%@ failing because offline", self);
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
		[self connection:self.connection didFailWithError:[NSError errorWithDomain:CRestErrorDomain code:CRestOfflineError userInfo:nil]];
	} else {
		CLogTrace(@"C_REST_WORKER", @"%@ scheduling in runloop:0x%08x", self, runLoop);
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
	}
	
	// Here we don't want to block the thread as the NSURLConnection will call our delegate methods on the same thread we're on.
	// So run the run loop until it is out of sources, at which point the callbacks will all be done.
    CLogTrace(@"C_REST_WORKER", @"%@ entering worker wait loop", self);
    while(YES) {
        if(self.isCancelled) {
            CLogTrace(@"C_REST_WORKER", @"%@ aborting aborting worker wait loop due to cancel", self);
            break;
        }
        
        CLogTrace(@"C_REST_WORKER", @"%@ running runloop:0x%08x", self, runLoop);
        BOOL hadSources = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        BOOL hadSources = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        CLogTrace(@"C_REST_WORKER", @"%@ ran runloop:0x%08x hadSources:%d", self, runLoop, hadSources);
        if(!hadSources) {
            CLogTrace(@"C_REST_WORKER", @"%@ aborting worker wait loop due to no sources", self);
            break;
        } else if(self.workerWaitLoopStopped) {
            CLogTrace(@"C_REST_WORKER", @"%@ aborting worker wait loop due to workerWaitLoopStopped flag", self);
            break;
        }
    }
	CLogTrace(@"C_REST_WORKER", @"%@ worker wait loop exited", self);
}

- (void)stopWorkerWaitLoop_
{
    self.workerWaitLoopStopped = YES;
}

- (void)stopWorkerWaitLoop
{
    [self performSelector:@selector(stopWorkerWaitLoop_) onThread:self.workerThread withObject:nil waitUntilDone:NO];
}

- (NSOperation*)createOperationForTry
{
	NSAssert(self.connection == nil, @"connection must not exist");
	NSAssert(self.request != nil, @"request must exist");

	return [super createOperationForTry];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connection:didReceiveResponse:", self);
		
		if(!self.isCancelled) {
			self.response = response;
			[self.mutableData setLength:0];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connection:didReceiveData:", self);

		if(!self.isCancelled) {
			[self.mutableData appendData:data];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@synchronized(self) {
		self.connection = nil;
		[self operationFailedWithError:error];
        [self stopWorkerWaitLoop];
	}
}

- (void)updateTitleForError
{
	if(self.error != nil) {
		[self.titleItems addObject:[NSString stringWithFormat:@"=%d", self.error.code]];
	} else if(self.httpResponse != nil) {
		[self.titleItems addObject:[NSString stringWithFormat:@"=%d", self.httpResponse.statusCode]];
	} else {
		[self.titleItems addObject:@"=?"];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connectionDidFinishLoading:", self);
		self.connection = nil;

		NSHTTPURLResponse* httpResponse = self.httpResponse;
		if(httpResponse != nil) {
			NSInteger statusCode = httpResponse.statusCode;
			if([self.successStatusCodes containsIndex:statusCode]) {
				[self operationSucceeded];
			} else {
				NSDictionary* userInfo = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:statusCode],
										  CRestErrorFailingURLErrorKey: self.request.URL,
										  CRestErrorWorkerErrorKey: self};
				NSError* error = [NSError errorWithDomain:CRestErrorDomain code:statusCode userInfo:userInfo];
				[self operationFailedWithError:error];
			}
		} else {
			[self operationSucceeded];
		}
        [self stopWorkerWaitLoop];
	}
}

@end
