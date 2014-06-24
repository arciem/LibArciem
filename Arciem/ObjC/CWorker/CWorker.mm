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
@property (nonatomic) NSMutableSet* mutableDependencies;
@property (nonatomic) NSMutableArray* _titleItems;
@property (strong, readwrite, nonatomic) NSString* title;
@property (readonly, nonatomic) NSSet *_dependencies;
@property (readwrite, nonatomic) CSerializer *serializer;

@end

@implementation CWorker

@synthesize title = _title;
@synthesize _titleItems = __titleItems;
@dynamic dependencies;
@dynamic _dependencies;

- (instancetype)init
{
	if(self = [super init]) {
		self.sequenceNumber = sNextSequenceNumber++;
        self.serializer = [CSerializer newSerializerWithName:[NSString stringWithFormat:@"Worker %d Serializer", self.sequenceNumber]];
		self.tryCount = 0;
		self.tryLimit = 3;
		self.retryDelayInterval = 1.0;
		self.mutableDependencies = [NSMutableSet set];
		self.callbackThread = [NSThread currentThread];
		
		[self addObserver:self forKeyPath:@"titleItems" options:0 context:NULL];
		self.titleItems = [NSMutableArray arrayWithObject:@(self.sequenceNumber)];
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
	return [self mutableArrayValueForKey:@"_titleItems"];
}

- (void)setTitleItems:(NSMutableArray *)titleItems
{
	__titleItems = [titleItems mutableCopy];
    _title = nil;
}

- (NSUInteger)countOf_titleItems
{
	return __titleItems.count;
}

- (id)objectIn_titleItemsAtIndex:(NSUInteger)index
{
	return __titleItems[index];
}

- (void)insertObject:(id)object in_titleItemsAtIndex:(NSUInteger)index
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
	[__titleItems insertObject:object atIndex:index];
    _title = nil;
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
}

- (void)removeObjectFrom_titleItemsAtIndex:(NSUInteger)index
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
	[__titleItems removeObjectAtIndex:index];
    _title = nil;
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"titleItems"];
}

- (NSString*)title
{
	if(_title == nil) {
		_title = StringByJoiningNonemptyDescriptionsWithString(self._titleItems, @" ");
	}
	
	return _title;
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self) {
		if([keyPath isEqualToString:@"titleItems"]) {
			_title = nil;
		}
	}
}

- (NSString*)description
{
    return [self.serializer performWithResult:^{
		return [self formatObjectWithValues:@[[self formatValueForKey:@"title" compact:NO],
                                              [self formatValueForKey:@"sequenceNumber" compact:NO],
                                              [self formatValueForKey:@"tryCount" compact:NO]]];
    }];
}

- (NSSet*)dependencies
{
	return [self.serializer performWithResult:^{
		return [self _dependencies];
	}];
}

- (NSSet*)_dependencies
{
    return [self.mutableDependencies copy];
}

- (BOOL)addDependency:(CWorker*)worker
{
	return [[self.serializer performWithResult:^{
		BOOL added = NO;
		
		NSAssert1(!self.executing, @"may not add dependencies to executing worker: %@", self);
		NSAssert1(!self.finished, @"may not add dependencies to finished worker: %@", self);
		if(![self.mutableDependencies containsObject:worker]) {
			added = YES;
			[self willChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
			[self.mutableDependencies addObject:worker];
			[self didChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:worker]];
		}
		return @(added);
	}] boolValue];
}

- (BOOL)removeDependency:(CWorker*)worker
{
	return [[self.serializer performWithResult:^{
		BOOL removed = NO;
		NSAssert1(!self.executing, @"may not remove dependencies from executing worker: %@", self);
		NSAssert1(!self.finished, @"may not remove dependencies from finished worker: %@", self);
		if([self.mutableDependencies containsObject:worker]) {
			removed = YES;
			[self willChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
			[self.mutableDependencies removeObject:worker];
			[self didChangeValueForKey:@"dependencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:worker]];
		}
		return @(removed);
	}] boolValue];
}

- (BOOL)canRetry
{
	return self.tryLimit == 0 || self.tryCount < self.tryLimit;
}

- (void)performDelay:(NSTimeInterval)delay
{
	if(!self.cancelled && delay > 0.0) {
		CLogTrace(nil, @"%@ starting delay: %f sec", self, delay);
		NSDate* endDate = [NSDate dateWithTimeIntervalSinceNow:delay];
		while(!self.cancelled && [endDate timeIntervalSinceNow] > 0.0) {
			[NSThread sleepForTimeInterval:0.1];
		}
		CLogTrace(nil, @"%@ ending delay", self);
	}
}

- (void)performRetryDelay
{
	CLogTrace(@"C_WORKER", @"%@ starting retry delay: %f sec", self, self.retryDelayInterval);
	// Here we block the thread, which is OK if we're not currently waiting on any run loop sources
	[self performDelay:self.retryDelayInterval];
	CLogTrace(@"C_WORKER", @"%@ ending retry delay", self, self.retryDelayInterval);
}

- (NSOperation*)newOperationForTry
{
	NSAssert(self.operation == nil, @"operation must not exist");
	
	if(self.canRetry) {
		++self.tryCount;
		BSELF;
		self.operation = [NSBlockOperation blockOperationWithBlock:^{
			CLogTrace(@"C_WORKER", @"%@ entered NSBlockOperation currentRunLoop:0x%08x", bself, [NSRunLoop currentRunLoop]);
			bself.active = YES;
			[bself operationDidBegin];
			[bself performDelay:bself.startDelay];
			if(!bself.cancelled) {
				if(bself.tryCount > 1) {
					[bself performRetryDelay];
				}
				if(!bself.cancelled) {
					[bself performOperationWork];
				}
			}
			[bself operationWillEnd];
			bself.active = NO;
			CLogTrace(@"C_WORKER", @"%@ exiting NSBlockOperation", bself);
		}];
		
		[self.operation setQueuePriority:self.queuePriority];
	}
	
	return self.operation;
}

- (void)cancel
{
	[self.serializer perform:^{
		CLogTrace(@"C_WORKER", @"%@ cancel", self);
		if(!self.finished && !self.cancelled) {
			self.cancelled = YES;
			[self didCancel];
			[self.operation cancel];
			[self.callbackThread performBlock:^{
				self.finally(self);
			}];
		}
	}];
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
    BSELF;
	[self.serializer perform:^{
		CLogTrace(@"C_WORKER", @"%@ operationFailedWithError:%@", bself, error);
		bself.operation = nil;
		
        if(!bself.cancelled) {
            bself.error = error;
            [bself updateTitleForError];
            
            [bself.callbackThread performBlock:^{
                if(!bself.cancelled) {
                    bself.failure(bself, error);
                }
                bself.finally(bself);
            }];
        }
	}];
}

- (void)operationSucceeded
{
    BSELF;
	[self.serializer perform:^{
		CLogTrace(@"C_WORKER", @"%@ operationSucceeded", bself);
		bself.operation = nil;
		
        if(!bself.cancelled) {
            bself.error = nil;
            [bself updateTitleForError];
            
            [bself.callbackThread performBlock:^{
                if(!bself.cancelled) {
                    bself.success(bself);
                }
                bself.finally(bself);
            }];
        }
	}];
}

- (NSString*)formattedSequenceNumber
{
	return [NSString stringWithFormat:@"%lu", (unsigned long)self.sequenceNumber];
}

- (NSString*)formattedQueuePriority
{
	return [NSString stringWithFormat:@"(%ld)", (long)self.queuePriority];
}

- (NSString*)formattedDependencies
{
	return [self.serializer performWithResult:^{
		NSMutableArray* dependentSeqNums = [NSMutableArray array];
		for(CWorker* predecessorWorker in self.mutableDependencies) {
			[dependentSeqNums addObject:@(predecessorWorker.sequenceNumber)];
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
	}];
}

- (NSString*)formattedErrorCode
{
	NSString* result = @"";
	
	if(self.error != nil) {
		result = [NSString stringWithFormat:@"=%ld", (long)self.error.code];
	}
	
	return result;
}

@end
