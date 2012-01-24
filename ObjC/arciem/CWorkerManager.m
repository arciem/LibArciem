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

#import "CWorkerManager.h"

@interface CWorkerManager ()

@property (strong, readwrite, nonatomic) NSOperationQueue* queue;
@property (strong, readwrite, nonatomic) NSMutableSet* mutableWorkers;

@end

@implementation CWorkerManager

@synthesize queue = queue_;
@synthesize mutableWorkers = mutableWorkers_;
@dynamic workers;

+ (void)initialize
{
//	CLogSetTagActive(@"C_WORKER_MANAGER", YES);
}

- (id)init
{
	if(self = [super init]) {
		self.queue = [[NSOperationQueue alloc] init];
		self.queue.maxConcurrentOperationCount = 1;		// Make the framework user set it to something higher
		
		self.mutableWorkers = [NSMutableSet set];
	}
	
	return self;
}

- (NSMutableSet*)workers
{
	return [self mutableSetValueForKey:@"mutableWorkers"];
}

+ (BOOL)automaticallyNotifiesObserversOfWorkers
{
	return NO;
}

- (NSUInteger)countOfMutableWorkers
{
	return self.mutableWorkers.count;
}

- (NSEnumerator*)enumeratorOfMutableWorkers
{
	return [self.mutableWorkers objectEnumerator];
}

- (id)memberOfMutableWorkers:(id)worker
{
	return [self.mutableWorkers member:worker];
}

- (void)addMutableWorkersObject:(id)worker
{
	@synchronized(self) {
		[self willChangeValueForKey:@"workers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
		[self.mutableWorkers addObject:worker];
		[self didChangeValueForKey:@"workers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
	}
}

- (void)removeMutableWorkersObject:(id)worker
{
	@synchronized(self) {
		[self willChangeValueForKey:@"workers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
		[self.mutableWorkers removeObject:worker];
		[self didChangeValueForKey:@"workers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
	}
}

- (void)startWorker:(CWorker*)worker
{
	@synchronized(self) {
		NSOperation* operation = [worker createOperationForTry];
		if(operation != nil) {
			[self.queue addOperation:operation];
		}
	}
}

- (BOOL)workerIsNowReady:(CWorker*)worker
{
	@synchronized(worker) {
		BOOL nowReady = YES;

		if(!worker.isExecuting) {
			nowReady = NO;
		} else if(worker.isFinished) {
			nowReady = NO;
		} else if(worker.isReady) {
			nowReady = NO;
		} else {
			for(CWorker* predecessorWorker in worker.dependencies) {
				if(!predecessorWorker.isFinished) {
					nowReady = NO;
					break;
				}
			}
		}

		return nowReady;
	}
}

- (void)startReadyWorkers
{
	@synchronized(self) {
		for(CWorker* worker in self.workers) {
			if([self workerIsNowReady:worker]) {
				[self startWorker:worker];
				worker.isReady = YES;
			}
		}
	}
}

- (void)addWorker:(CWorker*)worker success:(void (^)(CWorker*))success shouldRetry:(BOOL (^)(CWorker*, NSError*))shouldRetry failure:(void (^)(CWorker*, NSError*))failure finally:(void (^)(CWorker*))finally
{
	NSAssert(success != nil, @"success may not be nil");
	NSAssert(shouldRetry != nil, @"shouldRetry may not be nil");
	NSAssert(failure != nil, @"failure may not be nil");
	NSAssert(finally != nil, @"finally may not be nil");
	
	@synchronized(self) {
		NSAssert1(!worker.isExecuting, @"worker already executing: %@", worker);
		NSAssert1(!worker.isFinished, @"worker already finished: %@", worker);
		
		__weak CWorkerManager* manager_ = self;
		
		worker.success = ^(CWorker* worker) {
			@synchronized(worker) {
				CLogTrace(@"C_WORKER_MANAGER", @"success:%@", worker);
				success(worker);
			}
		};
		
		worker.failure = ^(CWorker* worker, NSError* error) {
			@synchronized(worker) {
				CLogTrace(@"C_WORKER_MANAGER", @"failure:%@", error);
				BOOL retry = NO;
				if(worker.canRetry) {
					retry = shouldRetry(worker, error);
				}
				if(retry) {
					[manager_ startWorker:worker];
				} else {
					failure(worker, error);
				}
			}
		};
		
		worker.finally = ^(CWorker* worker) {
			@synchronized(worker) {
				CLogTrace(@"C_WORKER_MANAGER", @"finally:%@", worker);
				worker.isFinished = YES;
				if(!worker.isCancelled) {
					finally(worker);
				}
				@synchronized(manager_) {
					[manager_.workers removeObject:worker];
					worker.isExecuting = NO;
					[manager_ startReadyWorkers];
				}
			}
		};

		[self.workers addObject:worker];
		worker.isExecuting = YES;
		
		[self startReadyWorkers];
	}
}

@end
