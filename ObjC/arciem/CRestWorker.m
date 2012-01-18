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
#import "ObjectUtils.h"
#import "StringUtils.h"
#import "CNetworkActivity.h"

NSString* const CRestErrorDomain = @"CRestErrorDomain";

NSString* const CRestErrorFailingURLErrorKey = @"CRestErrorFailingURLErrorKey";
NSString* const CRestErrorWorkerErrorKey = @"CRestErrorWorkerErrorKey";

static NSUInteger sNextSequenceNumber = 0;

@interface CRestWorker ()

@property (readwrite, nonatomic) NSUInteger sequenceNumber;
@property (readwrite, nonatomic) BOOL isCancelled;
@property (readwrite, nonatomic) BOOL isExecuting;
@property (readwrite, nonatomic) BOOL isFinished;
@property (readwrite, nonatomic) NSUInteger tryCount;
@property (weak, nonatomic) NSOperation* operation; // zeroing weak reference, operation is owned by the NSOperationQueue
@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSMutableSet* mutableDependencies;
@property (strong, readwrite, nonatomic) NSURLResponse* response;
@property (strong, nonatomic) NSMutableData* mutableData;
@property (copy, nonatomic) void (^success)(CRestWorker*);
@property (copy, nonatomic) void (^failure)(CRestWorker*, NSError*);
@property (copy, nonatomic) void (^finally)(CRestWorker*);

@end

@implementation CRestWorker

@synthesize sequenceNumber = sequenceNumber_;
@synthesize isCancelled = isCancelled_;
@synthesize isExecuting = isExecuting_;
@synthesize isFinished = isFinished_;
@synthesize identifier = identifier_;
@synthesize tryCount = tryCount_;
@synthesize tryLimit = tryLimit_;
@synthesize operation = operation_;
@synthesize request = request_;
@synthesize response = response_;
@synthesize connection = connection_;
@synthesize mutableData = mutableData_;
@synthesize mutableDependencies = mutableDependencies_;
@synthesize queuePriority = queuePriority_;
@synthesize callbackThread = callbackThread_;
@synthesize success = success_;
@synthesize failure = failure_;
@synthesize finally = finally_;
@synthesize successStatusCodes = successStatusCodes_;
@synthesize retryDelayInterval = retryDelayInterval_;
@synthesize showsNetworkActivityIndicator = showsNetworkActivityIndicator_;
@dynamic data;
@dynamic dependencies;
@dynamic httpResponse;
@dynamic dataAsString;
@dynamic dataAsJSON;

+ (void)initialize
{
//	CLogSetTagActive(@"C_REST_WORKER", YES);
}

- (id)init
{
	if(self = [super init]) {
		self.sequenceNumber = sNextSequenceNumber++;
		self.tryCount = 0;
		self.tryLimit = 3;
		self.retryDelayInterval = 1.0;
		self.mutableData = [NSMutableData data];
		self.mutableDependencies = [NSMutableSet set];
		self.callbackThread = [NSThread currentThread];
		self.successStatusCodes = [NSIndexSet indexSetWithIndex:200];
		self.showsNetworkActivityIndicator = YES;
	}
	
	return self;
}

- (void)dealloc
{
	CLogDebug(@"C_REST_WORKER", @"%@ dealloc", self);
}

- (id)initWithRequest:(NSURLRequest*)request identifier:(NSString*)identifier
{
	if(self = [self init]) {
		self.request = request;
		self.identifier = identifier;
	}

	return self;
}

+ (CRestWorker*)worker
{
	return [[CRestWorker alloc] init];
}

+ (CRestWorker*)workerWithRequest:(NSURLRequest*)request identifier:(NSString*)identifier
{
	return [[CRestWorker alloc] initWithRequest:request identifier:identifier];
}

- (NSString*)description
{
	return [self formatObjectWithValues:[NSArray arrayWithObjects:
				  [self formatValueForKey:@"sequenceNumber" compact:NO],
				  [self formatValueForKey:@"tryCount" compact:NO],
				  nil]];
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
		CLogError(nil, @"%@ Parsing JSON: %@", self, error);
	}
	return json;
}

- (id)dataAsJSON
{
	return [self dataAsJSONWithError:nil];
}

- (NSArray*)dependencies
{
	NSArray* dependencies = nil;
	@synchronized(self) {
		dependencies = [self.mutableDependencies allObjects];
	}
	return dependencies;
}

- (void)addDependency:(CRestWorker *)worker
{
	@synchronized(self) {
		[self.mutableDependencies addObject:worker];
	}
}

- (void)removeDependency:(CRestWorker *)worker
{
	@synchronized(self) {
		[self.mutableDependencies removeObject:worker];
	}
}

- (NSHTTPURLResponse*)httpResponse
{
	NSHTTPURLResponse* httpResponse = nil;
	if([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
		httpResponse = (NSHTTPURLResponse*)self.response;
	}
	return httpResponse;
}

- (BOOL)canRetry
{
	return self.tryLimit == 0 || self.tryCount < self.tryLimit;
}

- (NSOperation*)createOperationForTry
{
	NSAssert(self.operation == nil, @"operation must not exist");
	NSAssert(self.connection == nil, @"connection must not exist");
	NSAssert(self.request != nil, @"request must exist");

	if(self.canRetry) {
		++self.tryCount;
		__weak CRestWorker* worker_ = self;
		self.operation = [NSBlockOperation blockOperationWithBlock:^{
			CLogTrace(@"C_REST_WORKER", @"%@ entered NSBlockOperation", worker_);
			CNetworkActivity* activity = [CNetworkActivity activityWithIndicator:worker_.showsNetworkActivityIndicator];
			if(!worker_.isCancelled) {
				if(worker_.tryCount > 1) {
					CLogTrace(@"C_REST_WORKER", @"%@ starting retry delay: %f sec", worker_, worker_.retryDelayInterval);
					// Here we block the thread, as we're not currently waiting on any run loop sources
					[NSThread sleepForTimeInterval:worker_.retryDelayInterval];
					CLogTrace(@"C_REST_WORKER", @"%@ ending retry delay", worker_, worker_.retryDelayInterval);
				}
				if(!worker_.isCancelled) {
					CLogTrace(@"C_REST_WORKER", @"%@ starting NSURLConnection", worker_);
					worker_.connection = [[NSURLConnection alloc] initWithRequest:worker_.request delegate:worker_ startImmediately:YES];
					
					// Here we don't want to block the thread as the NSURLConnection will call our delegate methods on the same thread we're on.
					// So run the run loop until it is out of sources, at which point the callbacks will all be done.
					CLogTrace(@"C_REST_WORKER", @"%@ entering runloop", worker_);
					while(!worker_.isCancelled && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
						CLogTrace(@"C_REST_WORKER", @"%@ ran runloop", worker_);
					}
					CLogTrace(@"C_REST_WORKER", @"%@ runloop exited", worker_);
				}
			}
			activity = nil;
			CLogTrace(@"C_REST_WORKER", @"%@ exiting NSBlockOperation", worker_);
		}];
		
		[self.operation setQueuePriority:self.queuePriority];
	}

	return self.operation;
}

- (void)cancel
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ cancel", self);
		if(!self.isFinished && !self.isCancelled) {
			self.isCancelled = YES;
			[self.connection cancel];
			[self.operation cancel];
			[self.callbackThread performBlock:^{
				if(self.finally != NULL) {
					self.finally(self);
				}
			}];
		}
	}
}

- (BOOL)isReady
{
	BOOL ready = YES;
	
	@synchronized(self) {
		if(self.isFinished) {
			ready = NO;
		} else if(self.isExecuting) {
			ready = NO;
		} else {
			for(CRestWorker* predecessorWorker in self.mutableDependencies) {
				if(!predecessorWorker.isFinished) {
					ready = NO;
					break;
				}
			}
		}
	}

	return ready;
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
		CLogTrace(@"C_REST_WORKER", @"%@ connection:didFailWithError:", self);
		self.connection = nil;
		self.operation = nil;
		
		__weak CRestWorker* worker_ = self;
		
		[self.callbackThread performBlock:^{
			if(!worker_.isCancelled) {
				if(worker_.failure != NULL) {
					worker_.failure(worker_, error);
				}
			}
			if(worker_.finally != NULL) {
				worker_.finally(worker_);
			}
		}];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@synchronized(self) {
		CLogTrace(@"C_REST_WORKER", @"%@ connectionDidFinishLoading:", self);
		self.connection = nil;
		self.operation = nil;

		__weak CRestWorker* worker_ = self;

		[self.callbackThread performBlock:^{
			if(!worker_.isCancelled) {
				NSHTTPURLResponse* httpResponse = worker_.httpResponse;
				if(httpResponse != nil) {
					NSInteger statusCode = httpResponse.statusCode;
					if([worker_.successStatusCodes containsIndex:statusCode]) {
						if(worker_.success != NULL) {
							worker_.success(worker_);
						}
					} else {
						if(worker_.failure != NULL) {
							NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
													  [NSHTTPURLResponse localizedStringForStatusCode:statusCode], NSLocalizedDescriptionKey,
													  worker_.request.URL, CRestErrorFailingURLErrorKey,
													  worker_, CRestErrorWorkerErrorKey,
													  nil];
							NSError* error = [NSError errorWithDomain:CRestErrorDomain code:statusCode userInfo:userInfo];
							worker_.failure(worker_, error);
						}
					}
				} else {
					if(worker_.success != NULL) {
						worker_.success(worker_);
					}
				}
			}
			if(worker_.finally != NULL) {
				worker_.finally(worker_);
			}
		}];
	}
}

@end
