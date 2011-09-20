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


#import "RKClient+Blocks.h"
#import "ObjectUtils.h"
#import "CNetworkActivity.h"

static NSMutableSet* sCallsInFlight = nil;

@interface RKRequestCall : NSObject<RKRequestDelegate>

@property (strong, nonatomic) CNetworkActivity* networkActivity;
@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic) BOOL hasIndicator;
@property (copy, nonatomic) void (^success)(RKResponse*);
@property (copy, nonatomic) void (^failure)(NSError*);
@property (copy, nonatomic) void (^finally)(void);
@property (nonatomic, readonly) NSMutableSet* sharedCallsInFlight;
@property (strong, nonatomic) RKRequest* request;

- (id)initWithIndicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)startCall;
- (void)endCall;

@end

@implementation RKRequestCall

@synthesize networkActivity = networkActivity_;
@synthesize hasIndicator = hasIndicator_;
@synthesize timeoutInterval = timeoutInterval_;
@synthesize success = success_;
@synthesize failure = failure_;
@synthesize finally = finally_;
@synthesize request = request_;
@dynamic sharedCallsInFlight;

- (NSMutableSet*)sharedCallsInFlight
{
	if(sCallsInFlight == nil) {
		sCallsInFlight = [NSMutableSet set];
	}
	return sCallsInFlight;
}

- (id)initWithIndicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	if(self == [super init]) {
		self.hasIndicator = indicator;
		self.timeoutInterval = timeoutInterval;
		self.success = success;
		self.failure = failure;
		self.finally = finally;
	}
	
	return self;
}

- (void)dealloc
{
//	CLogDebug(nil, @"%@ dealloc", self);
}

- (void)startCall
{
	self.networkActivity = [[CNetworkActivity alloc] initWithIndicator:self.hasIndicator];
	if(self.timeoutInterval > 0.0) {
		[self performSelector:@selector(timeoutIntervalElapsed) withObject:nil afterDelay:self.timeoutInterval];
	}
	[self.sharedCallsInFlight addObject:self];
}

- (void)endCall
{
	self.request.delegate = nil;
	self.networkActivity = nil;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if(self.finally != nil) {
		self.finally();
	}
	[self.sharedCallsInFlight removeObject:self];
}

- (void)endCallWithResponse:(RKResponse*)response
{
	if(self.success != nil) {
		self.success(response);
	}
	[self endCall];
}

- (void)endCallWithError:(NSError*)error
{
	if(self.failure != nil) {
		self.failure(error);
	}
	[self endCall];
}

- (void)endCallWithTimeoutError
{
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"The network connection timed out." forKey:NSLocalizedDescriptionKey];
	[self endCallWithError:[NSError errorWithDomain:RKRestKitErrorDomain code:RKBlocksTimeoutError userInfo:userInfo]];
}

- (void)timeoutIntervalElapsed
{
	[self.request cancel];
	[self endCallWithTimeoutError];
}

#pragma mark RKRequestDelegate

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
	[self endCallWithResponse:response];
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
	[self endCallWithError:error];
}

- (void)requestDidStartLoad:(RKRequest*)request
{
//	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)requestDidCancelLoad:(RKRequest*)request
{
}

- (void)request:(RKRequest*)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
}

- (void)requestDidTimeout:(RKRequest*)request
{
	[self endCallWithTimeoutError];
}

@end

@implementation RKClient (Blocks)

- (RKRequest*)getPath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithIndicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:finally];
	[delegate startCall];
	delegate.request = [self get:resourcePath delegate:delegate];
	return delegate.request;
}

- (RKRequest*)getPath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self getPath:resourcePath indicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:nil];
}

- (RKRequest*)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithIndicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:finally];
	[delegate startCall];
	delegate.request = [self post:resourcePath params:params delegate:delegate];
	return delegate.request;
}

- (RKRequest*)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self postPath:resourcePath params:params indicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:nil];
}

- (RKRequest*)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithIndicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:finally];
	[delegate startCall];
	delegate.request = [self put:resourcePath params:params delegate:delegate];
	return delegate.request;
}

- (RKRequest*)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self putPath:resourcePath params:params indicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:nil];
}

- (RKRequest*)deletePath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithIndicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:finally];
	[delegate startCall];
	delegate.request = [self delete:resourcePath delegate:delegate];
	return delegate.request;
}

- (RKRequest*)deletePath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self deletePath:resourcePath indicator:indicator timeoutInterval:timeoutInterval success:success failure:failure finally:nil];
}

@end
