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
#import "ObjectUtils.h"
#import "CSerializer.h"
#import "ThreadUtils.h"

@interface CWorkerManager ()

@property (readonly, nonatomic) NSMutableSet *mutableWorkers;

@end

@implementation CWorkerManager

@synthesize queue = _queue;
@synthesize mutableWorkers = _mutableWorkers;
@dynamic workers;

+ (CWorkerManager*)sharedWorkerManager
{
    static CWorkerManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [CWorkerManager new];
    });
    return instance;
}

- (CSerializer *)serializer {
    static CSerializer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CSerializer newSerializerWithName:@"WorkerManager Serializer"];
    });
    return instance;
}

- (instancetype)init
{
	if(self = [super init]) {
		_queue = [NSOperationQueue new];
		_queue.maxConcurrentOperationCount = 1;		// Make the framework user set it to something higher
		
		_mutableWorkers = [NSMutableSet set];
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
//    [NSThread performBlockOnMainThread:^{
		[self willChangeValueForKey:@"workers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
		[self.mutableWorkers addObject:worker];
		[self didChangeValueForKey:@"workers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
//    } waitUntilDone:YES];
}

- (void)removeMutableWorkersObject:(id)worker
{
//    [NSThread performBlockOnMainThread:^{
		[self willChangeValueForKey:@"workers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
		[self.mutableWorkers removeObject:worker];
		[self didChangeValueForKey:@"workers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
//	} waitUntilDone:YES];
}

- (void)startWorker:(CWorker*)worker
{
    NSOperation* operation = [worker newOperationForTry];
    if(operation != nil) {
        [self.queue addOperation:operation];
    }
    CLogTrace(@"C_WORKER_MANAGER", @"started:%@ operation:%@", worker, operation);
}

- (BOOL)workerIsNowReady:(CWorker*)worker
{
    BOOL nowReady = YES;

    if(!worker.executing) {
        nowReady = NO;
    } else if(worker.finished) {
        nowReady = NO;
    } else if(worker.ready) {
        nowReady = NO;
    } else {
        for(CWorker* predecessorWorker in worker.dependencies) {
            if(!predecessorWorker.finished) {
                nowReady = NO;
                break;
            }
        }
    }

    return nowReady;
}

- (void)startReadyWorkers
{
    for(CWorker* worker in self.workers) {
        if([self workerIsNowReady:worker]) {
            [self startWorker:worker];
            worker.ready = YES;
        }
    }
}

- (void)addWorker:(CWorker*)worker success:(void (^)(CWorker*))success failure:(void (^)(CWorker*, NSError*))failure finally:(void (^)(CWorker*))finally
{
    [self addWorker:worker success:success shouldRetry:NULL failure:failure finally:finally];
}

- (void)addWorker:(CWorker*)worker success:(void (^)(CWorker*))success shouldRetry:(BOOL (^)(CWorker*, NSError*))shouldRetry failure:(void (^)(CWorker*, NSError*))failure finally:(void (^)(CWorker*))finally
{
    [self.serializer dispatch:^{
		NSAssert1(!worker.isExecuting, @"worker already executing: %@", worker);
		NSAssert1(!worker.finished, @"worker already finished: %@", worker);
		
		BSELF;
		
		worker.success = ^(CWorker* worker) {
            CLogTrace(@"C_WORKER_MANAGER", @"success:%@", worker);
            if(success != NULL) {
                success(worker);
            }
		};
		
		worker.failure = ^(CWorker* worker, NSError* error) {
            CLogTrace(@"C_WORKER_MANAGER", @"failure:%@", error);
            BOOL retry = NO;
            if(worker.canRetry) {
                if(shouldRetry != NULL) {
                    retry = shouldRetry(worker, error);
                }
            }
            if(retry) {
                [bself startWorker:worker];
            } else {
                if(failure != NULL) {
                    failure(worker, error);
                }
            }
		};
		
		worker.finally = ^(CWorker* worker) {
            CLogTrace(@"C_WORKER_MANAGER", @"finally:%@", worker);
            worker.finished = YES;
            if(!worker.cancelled) {
                if(finally != NULL) {
                    finally(worker);
                }
            }
            [bself.serializer dispatch:^{
                [bself.workers removeObject:worker];
                worker.executing = NO;
                [bself startReadyWorkers];
            }];
		};

		[self.workers addObject:worker];
		worker.executing = YES;
        CLogTrace(@"C_WORKER_MANAGER", @"added:%@", worker);
		
		[self startReadyWorkers];
	}];
}

@end
