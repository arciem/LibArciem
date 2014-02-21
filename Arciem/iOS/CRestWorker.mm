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
#import "CLog.h"
#import "ErrorUtils.h"
#import "DeviceUtils.h"
#import "ObjectUtils.h"

NSString *const CRestErrorDomain = @"CRestErrorDomain";

NSString *const CRestErrorFailingURLErrorKey = @"CRestErrorFailingURLErrorKey";
NSString *const CRestErrorWorkerErrorKey = @"CRestErrorWorkerErrorKey";
NSString *const CRestErrorOfflineErrorKey = @"CRestErrorOfflineErrorKey";

NSString *const CRestJSONMIMEType = @"application/json";

@interface CRestWorker () <NSURLSessionTaskDelegate>

@property (nonatomic) NSURLConnection *connection;
@property (readonly, nonatomic) NSURLSession *session;
@property (strong, readwrite, nonatomic) NSURLResponse *response;
@property (nonatomic) NSMutableData *mutableData;
@property (nonatomic) CNetworkActivity *activity;
@property (weak, nonatomic) NSThread *workerThread;
@property (nonatomic) BOOL workerWaitLoopStopped;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation CRestWorker

@synthesize dataAsJSON = _dataAsJSON;
@synthesize dataAsString = _dataAsString;

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
    if(_dataAsString == nil) {
        _dataAsString = [[NSString alloc] initWithData:self.mutableData encoding:NSUTF8StringEncoding];
    }
    return _dataAsString;
}

- (id)dataAsJSONWithError:(NSError**)error
{
    if(_dataAsJSON == nil) {
        NSError *myError;
        _dataAsJSON = [NSJSONSerialization JSONObjectWithData:self.mutableData options:0 error:&myError];
        if(_dataAsJSON == nil) {
            CLogError(nil, @"%@ Parsing JSON:%@ dataAsString:\"%@\"", self, myError, self.dataAsString);
            if(error != nil) {
                *error = myError;
            }
        }
    }
	return _dataAsJSON;
}

- (id)dataAsJSON
{
	return [self dataAsJSONWithError:nil];
}

- (NSHTTPURLResponse*)httpResponse
{
	NSHTTPURLResponse *httpResponse = nil;
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
    BSELF;
    void (^expirationHandler)(void) = ^{
        NSString *message = [NSString stringWithFormat:@"Background task expired: %@", bself.title];
        NSError *error = [NSError errorWithDomain:CRestErrorDomain code:CRestBackgroundTaskExpiredError localizedDescription:message];
        [bself operationFailedWithError:error];
    };
    if(!IsOSVersionAtLeast7()) {
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:expirationHandler];
        CLogTrace(@"C_REST_WORKER_BACKGROUND", @"%@ starting background task: %d", self, self.backgroundTaskIdentifier);
    }
}

- (void)operationWillEnd
{
	[super operationWillEnd];
	self.activity = nil;
    if(!IsOSVersionAtLeast7()) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        CLogTrace(@"C_REST_WORKER_BACKGROUND", @"%@ ended background task: %d", self, self.backgroundTaskIdentifier);
    }
}

- (BOOL)isOffline {
	return NO;
}

- (void)performOperationWork {
	if(self.isOffline) {
		CLogTrace(@"C_REST_WORKER", @"%@ failing because offline", self);
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
		[self connection:self.connection didFailWithError:[NSError errorWithDomain:CRestErrorDomain code:CRestOfflineError userInfo:nil]];
	} else {
        if(IsOSVersionAtLeast7()) {
            [self performOperationWorkWithNSURLSession];
        } else {
            [self performOperationWorkWithNSURLConnection];
        }
    }
}

- (NSURLSession *)session {
    static NSURLSession *_session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return _session;
}

- (void)performOperationWorkWithNSURLSession {
	CLogTrace(@"C_REST_WORKER", @"%@ starting NSURLSession: %@", self, self.request);
    
    [self.mutableData setLength:0];
    BSELF;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @synchronized(bself) {
            if(!self.cancelled) {
                if(data != nil) {
                    [bself.mutableData appendData:data];
                }
                if(response != nil) {
                    bself.response = response;
                }
                if(error != nil) {
                    [bself handleError:error];
                } else {
                    [bself handleResponse];
                }
            }
        }
    }];
    [task resume];
}

- (void)performOperationWorkWithNSURLConnection {
	CLogTrace(@"C_REST_WORKER", @"%@ starting NSURLConnection: %@", self, self.request);
	
    self.workerThread = [NSThread currentThread];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
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
        if(self.cancelled) {
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

- (void)handleResponse {
    NSHTTPURLResponse *httpResponse = self.httpResponse;
    if(httpResponse != nil) {
        NSInteger statusCode = httpResponse.statusCode;
        if([self.successStatusCodes containsIndex:statusCode]) {
            NSError *parseError = nil;
            if([self.expectedMIMEType isEqualToString:CRestJSONMIMEType]) {
                [self dataAsJSONWithError:&parseError];
            }
            
            if(parseError == nil) {
                [self operationSucceeded];
            } else {
                [self operationFailedWithError:parseError];
            }
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:statusCode],
                                       CRestErrorFailingURLErrorKey: self.request.URL,
                                       CRestErrorWorkerErrorKey: self};
            NSError *error = [NSError errorWithDomain:CRestErrorDomain code:statusCode userInfo:userInfo];
            [self operationFailedWithError:error];
        }
    } else {
        [self operationSucceeded];
    }
}

- (void)handleError:(NSError *)error {
    [self operationFailedWithError:error];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connection:didReceiveResponse:", self);
		
		if(!self.cancelled) {
			self.response = response;
			[self.mutableData setLength:0];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connection:didReceiveData:", self);

		if(!self.cancelled) {
			[self.mutableData appendData:data];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@synchronized(self) {
		self.connection = nil;
        
        [self handleError:error];

        [self stopWorkerWaitLoop];
	}
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    CLogTrace(@"C_REST_WORKER", @"%@ connection:%@ willSendRequest:%@ redirectResponse:%@ redirectResponseURL:%@", self, connection, request, redirectResponse, redirectResponse.URL);
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connectionDidFinishLoading:", self);
		self.connection = nil;

        [self handleResponse];
        
        [self stopWorkerWaitLoop];
	}
}

#pragma mark - NSURLSessionTaskDelegate

// The x-redirect-auth header gives the server the chance to tell the client what credentials to use to authenticate to the redirected URL. This may frequently (but not necessarily) be the same credentials that were used for the first URL.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSString *authToken = response.allHeaderFields[@"x-redirect-auth"];
    if(authToken != nil) {
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval];
        [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
            if(![name isEqualToString:@"x-redirect-auth"]) {
                [mutableRequest addValue:value forHTTPHeaderField:name];
            }
        }];
        [mutableRequest addValue:authToken forHTTPHeaderField:@"Authorization"];

        request = mutableRequest;
    }

#if 0
#warning DEBUG ONLY
    CLogDebug(nil, @"old URL:%@", task.originalRequest.URL);
    CLogDebug(nil, @"new URL:%@", request.URL);
    CLogDebug(nil, @"old request headers:%@", task.originalRequest.allHTTPHeaderFields);
    CLogDebug(nil, @"new request headers:%@", request.allHTTPHeaderFields);
#endif
    
    completionHandler(request);
}

@end
