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

@property (strong, readwrite, nonatomic) NSError* error;
@property (readwrite, nonatomic) NSUInteger sequenceNumber;
@property (readwrite, nonatomic) NSUInteger tryCount;
@property (weak, nonatomic) NSOperation* operation; // zeroing weak reference, operation is owned by the NSOperationQueue
@property (strong, nonatomic) NSMutableSet* mutableDependencies;
@property (strong, nonatomic) NSMutableArray* titleItems_;
@property (strong, readwrite, nonatomic) NSString* title;

@end

@implementation CWorker

@synthesize sequenceNumber = sequenceNumber_;
@synthesize isExecuting = isExecuting_;
@synthesize isReady = isReady_;
@synthesize isActive = isActive_;
@synthesize isFinished = isFinished_;
@synthesize isCancelled = isCancelled_;
@synthesize title = title_;
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
@synthesize error = error_;
@synthesize titleItems_ = titleItems__;
@dynamic dependencies;
@dynamic titleItems;

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
		
		[self addObserver:self forKeyPath:@"titleItems" options:0 context:NULL];
		self.titleItems = [NSMutableArray arrayWithObject:[NSNumber numberWithUnsignedInt:self.sequenceNumber]];
	}
	
	return self;
}

- (void)dealloc
{
	CLogDebug(@"C_WORKER", @"%@ dealloc", self);
	[self removeObserver:self forKeyPath:@"titleItems"];
}

#pragma mark - KVC/KVO for titleItems

+ (NSSet*)keyPathsForValuesAffectingTitle
{
	return [NSSet setWithObjects:@"titleItems", nil];
}

- (NSMutableArray*)titleItems
{
	return [self mutableArrayValueForKey:@"titleItems_"];
}

- (void)setTitleItems:(NSMutableArray *)titleItems
{
	titleItems__ = [titleItems mutableCopy];
}

- (NSUInteger)countOfTitleItems_
{
	return titleItems__.count;
}

- (id)objectInTitleItems_AtIndex:(NSUInteger)index
{
	return [titleItems__ objectAtIndex:index];
}

- (void)insertObject:(id)object inTitleItems_AtIndex:(NSUInteger)index
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
	[titleItems__ insertObject:object atIndex:index];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
}

- (void)removeObjectFromTitleItems_AtIndex:(NSUInteger)index
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
	[titleItems__ removeObjectAtIndex:index];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
}

- (NSString*)title
{
	if(title_ == nil) {
		title_ = StringByJoiningNonemptyDescriptionsWithString(self.titleItems_, @" ");
	}
	
	return title_;
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self) {
		if([keyPath isEqualToString:@"titleItems"]) {
			title_ = nil;
		}
	}
}

- (NSString*)description
{
	@synchronized(self) {
		return [self formatObjectWithValues:[NSArray arrayWithObjects:
											 [self formatValueForKey:@"title" compact:NO],
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

// may be overridden
- (void)updateTitleForError
{
	if(self.error != nil) {
		[self.titleItems addObject:self.formattedErrorCode];
	}
}

- (void)operationFailedWithError:(NSError*)error
{
	@synchronized(self) {
		CLogTrace(@"C_WORKER", @"%@ operationFailedWithError:%@", self, error);
		self.operation = nil;
		
		self.error = error;
		[self updateTitleForError];
		
		__weak CWorker* worker_ = self;
		
		[self.callbackThread performBlock:^{
			@synchronized(worker_) {
				if(!worker_.isCancelled) {
					worker_.failure(worker_, error);
				}
				worker_.finally(worker_);
			}
		}];
	}
}

- (void)operationSucceeded
{
	@synchronized(self) {
		CLogTrace(@"C_WORKER", @"%@ operationSucceeded", self);
		self.operation = nil;
		
		self.error = nil;
		[self updateTitleForError];
		
		__weak CWorker* worker_ = self;
		
		[self.callbackThread performBlock:^{
			@synchronized(worker_) {
				if(!worker_.isCancelled) {
					worker_.success(worker_);
				}
				worker_.finally(worker_);
			}
		}];
	}
}

- (NSString*)formattedSequenceNumber
{
	return [NSString stringWithFormat:@"%d", self.sequenceNumber];
}

- (NSString*)formattedQueuePriority
{
	return [NSString stringWithFormat:@"(%d)", self.queuePriority];
}

- (NSString*)formattedDependencies
{
	@synchronized(self) {
		NSMutableArray* dependentSeqNums = [NSMutableArray array];
		for(CWorker* predecessorWorker in self.mutableDependencies) {
			[dependentSeqNums addObject:[NSNumber numberWithInt:predecessorWorker.sequenceNumber]];
		}

		[dependentSeqNums sortUsingSelector:@selector(compare:)];
		NSMutableArray* dependentSeqStrs = [NSMutableArray arrayWithCapacity:dependentSeqNums.count];
		for(NSNumber* num in dependentSeqNums) {
			[dependentSeqStrs addObject:[num description]];
		}
		
		NSString* deps = StringByJoiningNonemptyStringsWithString(dependentSeqStrs, @",");
		if(!IsEmptyString(deps)) {
			deps = [NSString stringWithFormat:@"{%@}", deps];
		}
		return deps;
	}
}

- (NSString*)formattedErrorCode
{
	NSString* result = @"";
	
	if(self.error != nil) {
		result = [NSString stringWithFormat:@"=%d", self.error.code];
	}
	
	return result;
}

@end
