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

#import "CRestManager.h"

static CRestManager* sSharedInstance = nil;

@interface CRestManager ()

@property (strong, readwrite, nonatomic) NSOperationQueue* queue;
@property (strong, nonatomic) NSMutableSet* workers;

@end

@implementation CRestManager

@synthesize queue = queue_;
@synthesize workers = workers_;

- (id)init
{
	if(self = [super init]) {
		CLogSetTagActive(@"C_REST_MANAGER", YES);
		self.queue = [[NSOperationQueue alloc] init];
		self.queue.maxConcurrentOperationCount = 1;		// Make the framework user set it to something higher
		
		self.workers = [NSMutableSet set];
	}

	return self;
}

+ (CRestManager*)sharedInstance
{
	@synchronized(self) {
		if(sSharedInstance == nil) {
			sSharedInstance = [[CRestManager alloc] init];
		}
	}
	
	return sSharedInstance;
}

- (void)startWorker:(CRestWorker*)worker
{
	NSOperation* operation = [worker createOperationForTry];
	if(operation != nil) {
		[self.queue addOperation:operation];
	}
}

- (void)startReadyWorkers
{
	@synchronized(self) {
		for(CRestWorker* worker in self.workers) {
			if(worker.isReady) {
				worker.isExecuting = YES;
				[self startWorker:worker];
			}
		}
	}
}

- (void)addWorker:(CRestWorker*)worker success:(void (^)(CRestWorker*))success shouldRetry:(BOOL (^)(NSError*))shouldRetry failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	@synchronized(self) {
		NSAssert1(![self.workers containsObject:worker], @"worker already added: %@", worker);
		
		[self.workers addObject:worker];

		__weak CRestWorker* worker_ = worker;

		worker.success = ^(CRestWorker* worker) {
			CLogTrace(@"C_REST_MANAGER", @"%@ success:%@", self, worker);
			worker_.isExecuting = NO;
			worker_.isFinished = YES;
			if(success != NULL) {
				success(worker);
			}
		};
		
		worker.failure = ^(NSError* error) {
			CLogTrace(@"C_REST_MANAGER", @"%@ failure:%@", self, error);
			BOOL retry = NO;
			if(worker_.canRetry && shouldRetry != NULL) {
				retry = shouldRetry(error);
			}
			if(retry) {
				[self startWorker:worker_];
			} else {
				worker_.isExecuting = NO;
				worker_.isFinished = YES;
				if(failure != NULL) {
					failure(error);
				}
			}
		};

		worker.finally = ^{
			CLogTrace(@"C_REST_MANAGER", @"%@ finally", self);
			if(!worker_.isCancelled) {
				if(finally != NULL) {
					finally();
				}
			}
			[self.workers removeObject:worker_];
			[self startReadyWorkers];
		};

		[self startReadyWorkers];
	}
}

@end
