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

#import "CWorker.h"
#import "ObjectUtils.h"
#import "StringUtils.h"
#import "ThreadUtils.h"

static NSUInteger sNextSequenceNumber = 0;

@interface CWorker ()

@property (readwrite, nonatomic) NSUInteger sequenceNumber;
@property (readwrite, nonatomic) NSUInteger tryCount;
@property (weak, nonatomic) NSOperation* operation; // zeroing weak reference, operation is owned by the NSOperationQueue
@property (strong, nonatomic) NSMutableSet* mutableDependencies;

@end

@implementation CWorker

@synthesize sequenceNumber = sequenceNumber_;
@synthesize isExecuting = isExecuting_;
@synthesize isReady = isReady_;
@synthesize isActive = isActive_;
@synthesize isFinished = isFinished_;
@synthesize isCancelled = isCancelled_;
@synthesize identifier = identifier_;
@synthesize tryCount = tryCount_;
@synthesize tryLimit = tryLimit_;
@synthesize operation = operation_;
@synthesize mutableDependencies = mutableDependencies_;
@synthesize queuePriority = queuePriority_;
@synthesize callbackThread = callbackThread_;
@synthesize success = success_;
@synthesize failure = failure_;
@synthesize finally = finally_;
@synthesize retryDelayInterval = retryDelayInterval_;
@dynamic dependencies;

+ (void)initialize
{
//	CLogSetTagActive(@"C_WORKER", YES);
}

- (id)init
{
	if(self = [super init]) {
		self.sequenceNumber = sNextSequenceNumber++;
		self.tryCount = 0;
		self.tryLimit = 3;
		self.retryDelayInterval = 1.0;
		self.mutableDependencies = [NSMutableSet set];
		self.callbackThread = [NSThread currentThread];
	}
	
	return self;
}

- (NSString*)identifier
{
	if(identifier_ == nil) {
		identifier_ = [NSString stringWithFormat:@"%d", self.sequenceNumber];
	}
	
	return identifier_;
}

- (void)setIdentifier:(NSString *)identifier
{
	identifier_ = identifier;
}

- (void)dealloc
{
	CLogDebug(@"C_WORKER", @"%@ dealloc", self);
}

- (NSString*)description
{
	@synchronized(self) {
		return [self formatObjectWithValues:[NSArray arrayWithObjects:
											 [self formatValueForKey:@"sequenceNumber" compact:NO],
											 [self formatValueForKey:@"tryCount" compact:NO],
											 nil]];
	}
}

- (NSSet*)dependencies
{
	@synchronized(self) {
		return [self.mutableDependencies copy];
	}
}

- (BOOL)addDependency:(CWorker*)worker
{
	@synchronized(self) {
		BOOL added = NO;
		
		NSAssert1(!self.isExecuting, @"may not add dependencies to executing worker: %@", self);
		NSAssert1(!self.isFinished, @"may not add dependencies to finished worker: %@", self);
		if(![self.mutableDependencies containsObject:worker]) {
			added = YES;
			[self willChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
			[self.mutableDependencies addObject:worker];
			[self didChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
		}
		return added;
	}
}

- (BOOL)removeDependency:(CWorker*)worker
{
	@synchronized(self) {
		BOOL removed = NO;
		NSAssert1(!self.isExecuting, @"may not remove dependencies from executing worker: %@", self);
		NSAssert1(!self.isFinished, @"may not remove dependencies from finished worker: %@", self);
		if([self.mutableDependencies containsObject:worker]) {
			removed = YES;
			[self willChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
			[self.mutableDependencies removeObject:worker];
			[self didChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
		}
		return removed;
	}
}

- (BOOL)canRetry
{
	return self.tryLimit == 0 || self.tryCount < self.tryLimit;
}

- (void)performRetryDelay
{
	CLogTrace(@"C_WORKER", @"%@ starting retry delay: %f sec", self, self.retryDelayInterval);
	// Here we block the thread, which is OK if we're not currently waiting on any run loop sources
	[NSThread sleepForTimeInterval:self.retryDelayInterval];
	CLogTrace(@"C_WORKER", @"%@ ending retry delay", self, self.retryDelayInterval);
}

- (NSOperation*)createOperationForTry
{
	NSAssert(self.operation == nil, @"operation must not exist");
	
	if(self.canRetry) {
		++self.tryCount;
		__weak CWorker* worker_ = self;
		self.operation = [NSBlockOperation blockOperationWithBlock:^{
			CLogTrace(@"C_WORKER", @"%@ entered NSBlockOperation", worker_);
			worker_.isActive = YES;
			[worker_ operationDidBegin];
			if(!worker_.isCancelled) {
				if(worker_.tryCount > 1) {
					[worker_ performRetryDelay];
				}
				if(!worker_.isCancelled) {
					[worker_ performOperationWork];
				}
			}
			[worker_ operationWillEnd];
			worker_.isActive = NO;
			CLogTrace(@"C_WORKER", @"%@ exiting NSBlockOperation", worker_);
		}];
		
		[self.operation setQueuePriority:self.queuePriority];
	}
	
	return self.operation;
}

- (void)cancel
{
	@synchronized(self) {
		CLogTrace(@"C_WORKER", @"%@ cancel", self);
		if(!self.isFinished && !self.isCancelled) {
			self.isCancelled = YES;
			[self didCancel];
			[self.operation cancel];
			[self.callbackThread performBlock:^{
				self.finally(self);
			}];
		}
	}
}

- (void)operationDidBegin
{
	// behavior provided by subclasses
}

- (void)operationWillEnd
{
	// behavior provided by subclasses
}

- (void)didCancel
{
	// behavior provided by subclasses
}

- (void)performOperationWork
{
	// behavior provided by subclasses
}

- (void)operationFailedWithError:(NSError*)error
{
	@synchronized(self) {
		CLogTrace(@"C_WORKER", @"%@ operationFailedWithError:%@", self, error);
		self.operation = nil;
		
		__weak CWorker* worker_ = self;
		
		[self.callbackThread performBlock:^{
			if(!worker_.isCancelled) {
				worker_.failure(worker_, error);
			}
			worker_.finally(worker_);
		}];
	}
}

- (void)operationSucceeded
{
	@synchronized(self) {
		CLogTrace(@"C_WORKER", @"%@ operationSucceeded", self);
		self.operation = nil;
		
		__weak CWorker* worker_ = self;
		
		[self.callbackThread performBlock:^{
			if(!worker_.isCancelled) {
				worker_.success(worker_);
			}
			worker_.finally(worker_);
		}];
	}
}

@end
