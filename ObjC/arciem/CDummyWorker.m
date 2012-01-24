//
//  CDummyWorker.m
//  QP2
//
//  Created by Robert McNally on 1/23/12.
//  Copyright (c) 2012 QP Corp. All rights reserved.
//

#import "CDummyWorker.h"
#import "ThreadUtils.h"
#import "random.hpp"
#import "StringUtils.h"

@interface CDummyWorker ()

@property (nonatomic) NSTimeInterval workTimeInterval;

@end

@implementation CDummyWorker

@synthesize workTimeInterval = workTimeInterval_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_DUMMY_WORKER", YES);
}

- (id)initWithWorkTimeInterval:(NSTimeInterval)workTimeInterval
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
	while(!self.isCancelled && [(NSDate*)[NSDate date] compare:endDate] == NSOrderedAscending) {
		[NSThread sleepForTimeInterval:0.1];
	}
	[self operationSucceeded];
	CLogTrace(@"C_DUMMY_WORKER", @"%@ leaving performOperationWork", self);
}

+ (CWorker*)randomWorkerForWorkerManager:(CWorkerManager*)workerManager
{
	CWorker* worker = nil;
	@synchronized(workerManager) {
		NSArray* workers = [workerManager.workers allObjects];
		if(workers.count > 0) {
			NSInteger index = arciem::random_range(0, workers.count);
			worker = [workers objectAtIndex:index];
		}
	}
	return worker;
}

+ (void)testWithWorkerManager:(CWorkerManager*)workerManager
{
	workerManager.queue.maxConcurrentOperationCount = 4;

	[NSThread performBlockInBackground:^ {
		for(NSUInteger i = 0; i < 20; i++) {
			[NSThread performBlockOnMainThread:^ {
				for(NSUInteger j = 0; j < 1; j++) {
					NSTimeInterval workTimeInterval = arciem::random_range(0.2, 3.0);
//					NSTimeInterval workTimeInterval = arciem::random_range(4, 6);
					CDummyWorker* worker = [[CDummyWorker alloc] initWithWorkTimeInterval:workTimeInterval];
					
					NSMutableArray* idStrings = [NSMutableArray array];
					[idStrings addObject:[NSString stringWithFormat:@"%d", worker.sequenceNumber]];
					
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

					NSUInteger priIndex = arciem::random_range(0, 9);
					NSInteger pri = pris[priIndex];
					worker.queuePriority = pri;
					
					[idStrings addObject:[NSString stringWithFormat:@"(%d)", worker.queuePriority]];
#endif

#if 1
					@synchronized(workerManager) {
						NSMutableArray* dependentSeqNums = [NSMutableArray array];
						static NSUInteger links[] = {0, 0, 1, 2, 3};
						NSUInteger n = arciem::random_range(0, 5);
						for(NSUInteger k = 0; k < links[n]; k++) {
							CWorker* predecessorWorker = [self randomWorkerForWorkerManager:workerManager];
							if(predecessorWorker != nil) {
								if([worker addDependency:predecessorWorker]) {
									[dependentSeqNums addObject:[NSNumber numberWithInt:predecessorWorker.sequenceNumber]];
								}
							}
						}
						
						[dependentSeqNums sortUsingSelector:@selector(compare:)];
						NSMutableArray* dependentSeqStrs = [NSMutableArray arrayWithCapacity:dependentSeqNums.count];
						for(NSNumber* num in dependentSeqNums) {
							[dependentSeqStrs addObject:[num description]];
						}
						
						NSString* deps = StringByJoiningNonemptyStringsWithString(dependentSeqStrs, @",");
						if(!IsEmptyString(deps)) {
							deps = [NSString stringWithFormat:@"{%@}", deps];
							[idStrings addObject:deps];
						}
					}
#endif
					worker.identifier = StringByJoiningNonemptyStringsWithString(idStrings, @" ");
					
					[workerManager addWorker:worker success:^(CWorker *) {
					} shouldRetry:^BOOL(CWorker *, NSError *) {
						return NO;
					} failure:^(CWorker *, NSError *) {
					} finally:^(CWorker *) {
					}];
				}
			}];
			[NSThread sleepForTimeInterval:arciem::random_range(0.0, 2.0)];
		}
	}];

#if 1
	static BOOL hasReaper = NO;
	
	@synchronized(self) {
		if(!hasReaper) {
			hasReaper = YES;
			[NSThread performBlockInBackground:^ {
				while(YES) {
					[NSThread sleepForTimeInterval:10.0];
					@synchronized(workerManager) {
						CWorker* workerToCancel = [self randomWorkerForWorkerManager:workerManager];
						[workerToCancel cancel];
					}
				}
			}];
		}
	}
#endif
}

@end
