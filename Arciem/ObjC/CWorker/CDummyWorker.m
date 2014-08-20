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

#import "CDummyWorker.h"
#import "ThreadUtils.h"
#import "random.h"
#import "StringUtils.h"
#import "CLog.h"
#import "DispatchUtils.h"

@interface CDummyWorker ()

@property (nonatomic) NSTimeInterval workTimeInterval;

@end

@implementation CDummyWorker

@synthesize workTimeInterval = workTimeInterval_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_DUMMY_WORKER", YES);
}

- (instancetype)initWithWorkTimeInterval:(NSTimeInterval)workTimeInterval
{
	if(self = [super init]) {
		self.workTimeInterval = workTimeInterval;
	}
	
	return self;
}

- (void)performOperationWork
{
	CLogTrace(@"C_DUMMY_WORKER", @"%@ entering performOperationWork", self);
	NSDate* endDate = [NSDate dateWithTimeIntervalSinceNow:self.workTimeInterval];
	while(!self.cancelled && [(NSDate*)[NSDate date] compare:endDate] == NSOrderedAscending) {
		[NSThread sleepForTimeInterval:0.1];
	}
	if(random_flat() < 0.9) {
		[self operationSucceeded];
	} else {
		NSError* error = [NSError errorWithDomain:@"CDummyWorkerDomain" code:404 userInfo:nil];
		[self operationFailedWithError:error];
	}
	CLogTrace(@"C_DUMMY_WORKER", @"%@ leaving performOperationWork", self);
}

+ (CWorker*)randomWorkerForWorkerManager:(CWorkerManager*)workerManager
{
	return [workerManager.serializer dispatchWithResult:^{
        CWorker* worker = nil;
		NSArray* workers = [workerManager.workers allObjects];
		if(workers.count > 0) {
			NSInteger index = random_range(0, workers.count);
			worker = workers[index];
		}
        return worker;
	}];
}

+ (void)testWithWorkerManager:(CWorkerManager*)workerManager
{
	workerManager.queue.maxConcurrentOperationCount = 4;

	dispatchOnBackground(^{
		for(NSUInteger i = 0; i < 20; i++) {
			dispatchOnMain(^{
				for(NSUInteger j = 0; j < 1; j++) {
					NSTimeInterval workTimeInterval = random_range(0.2, 3.0);
//					NSTimeInterval workTimeInterval = random_range(4, 6);
					CDummyWorker* worker = [[CDummyWorker alloc] initWithWorkTimeInterval:workTimeInterval];
					
					NSMutableArray* idItems = [NSMutableArray array];
					
#if 1
					static NSOperationQueuePriority pris[] = {
						NSOperationQueuePriorityVeryLow,
						NSOperationQueuePriorityLow,
						NSOperationQueuePriorityLow,
						NSOperationQueuePriorityNormal,
						NSOperationQueuePriorityNormal,
						NSOperationQueuePriorityNormal,
						NSOperationQueuePriorityHigh,
						NSOperationQueuePriorityHigh,
						NSOperationQueuePriorityVeryHigh
					};

					NSUInteger priIndex = random_range(0, 9);
					NSOperationQueuePriority pri = pris[priIndex];
					worker.queuePriority = pri;
					
					[idItems addObject:worker.formattedQueuePriority];
#endif

#if 1
					static NSUInteger links[] = {0, 0, 1, 2, 3};
					NSUInteger n = random_range(0, 5);
					for(NSUInteger k = 0; k < links[n]; k++) {
						CWorker* predecessorWorker = [self randomWorkerForWorkerManager:workerManager];
						if(predecessorWorker != nil) {
							[worker addDependency:predecessorWorker];
						}
					}
					
					[idItems addObject:worker.formattedDependencies];
#endif

					[worker.titleItems addObjectsFromArray:idItems];
					
					[workerManager addWorker:worker success:^(CWorker *worker) {
					} shouldRetry:^BOOL(CWorker *worker, NSError *error) {
						return NO;
					} failure:^(CWorker *worker, NSError *error) {
					} finally:^(CWorker *worker) {
					}];
				}
			});
			[NSThread sleepForTimeInterval:random_range(0.0, 2.0)];
		}
	});

#if 1
	static BOOL hasReaper = NO;
	
	[workerManager.serializer dispatch:^{
		if(!hasReaper) {
			hasReaper = YES;
			dispatchOnBackground(^ __attribute__((noreturn)) {
				while(YES) {
					[NSThread sleepForTimeInterval:10.0];
					[workerManager.serializer dispatch:^{
						CWorker* workerToCancel = [self randomWorkerForWorkerManager:workerManager];
						[workerToCancel cancel];
					}];
				}
			});
		}
	}];
#endif
}

@end