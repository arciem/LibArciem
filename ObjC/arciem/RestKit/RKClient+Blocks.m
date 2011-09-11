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

static NSMutableSet* sCallsInFlight = nil;

@interface RKRequestCall : NSObject<RKRequestDelegate>

@property(nonatomic, copy) void (^success)(RKResponse*);
@property(nonatomic, copy) void (^failure)(NSError*);
@property(nonatomic, copy) void (^finally)(void);
@property (strong, nonatomic) NSMutableSet* callsInFlight;

- (id)initWithSuccess:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)startCall;
- (void)endCall;

@end

@implementation RKRequestCall

@synthesize success = success_;
@synthesize failure = failure_;
@synthesize finally = finally_;
@synthesize callsInFlight = callsInFlight_;

- (NSMutableSet*)callsInFlight
{
	if(sCallsInFlight == nil) {
		sCallsInFlight = [NSMutableSet set];
	}
	return sCallsInFlight;
}

- (id)initWithSuccess:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	if(self == [super init]) {
		self.success = success;
		self.failure = failure;
		self.finally = finally;
	}
	
	return self;
}

- (void)startCall
{
	[self.callsInFlight addObject:self];
}

- (void)endCall
{
	[self.callsInFlight removeObject:self];
}

- (void)endCallWithResponse:(RKResponse*)response
{
	if(self.success != nil) {
		self.success(response);
	}
	if(self.finally != nil) {
		self.finally();
	}
	[self endCall];
}

- (void)endCallWithError:(NSError*)error
{
	if(self.failure != nil) {
		self.failure(error);
	}
	if(self.finally != nil) {
		self.finally();
	}
	[self endCall];
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
}

- (void)request:(RKRequest*)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
}

@end

@implementation RKClient (Blocks)

- (RKRequest*)getPath:(NSString*)resourcePath success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithSuccess:success failure:failure finally:finally];
	[delegate startCall];
	return [self get:resourcePath delegate:delegate];
}

- (RKRequest*)getPath:(NSString*)resourcePath success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self getPath:resourcePath success:success failure:failure finally:nil];
}

- (RKRequest*)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithSuccess:success failure:failure finally:finally];
	[delegate startCall];
	return [self post:resourcePath params:params delegate:delegate];
}

- (RKRequest*)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self postPath:resourcePath params:params success:success failure:failure finally:nil];
}

- (RKRequest*)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithSuccess:success failure:failure finally:finally];
	[delegate startCall];
	return [self put:resourcePath params:params delegate:delegate];
}

- (RKRequest*)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self putPath:resourcePath params:params success:success failure:failure finally:nil];
}

- (RKRequest*)deletePath:(NSString*)resourcePath success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	RKRequestCall* delegate = [[RKRequestCall alloc] initWithSuccess:success failure:failure finally:finally];
	[delegate startCall];
	return [self delete:resourcePath delegate:delegate];
}

- (RKRequest*)deletePath:(NSString*)resourcePath success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure
{
	return [self deletePath:resourcePath success:success failure:failure finally:nil];
}

@end
