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

#import "CWorkerManagerDebugView.h"
#import "CWorker.h"
#import "CWorkerDebugView.h"
#import "UIViewUtils.h"
#import "ThreadUtils.h"
#import "Geom.h"

static const CGFloat kCWorkerDebugViewHeight = 20;
static const CGFloat kRowLeading = 4;
static const CGFloat kRowHeight = kCWorkerDebugViewHeight + kRowLeading;

static const NSTimeInterval kLayoutAnimationDuration = 0.3;
static const NSTimeInterval kRemovalSlideAnimationDuration = 1.0;
static const NSTimeInterval kRemovalFadeDelay = 5.0;
static const NSTimeInterval kRemovalFadeAnimationDuration = 0.4;

@interface CWorkerManagerDebugView ()

@property (strong, nonatomic) NSMutableArray* queuedWorkerViews;
@property (strong, nonatomic) NSMutableArray* finishedWorkerViews;
@property (strong, nonatomic) CWorkerManager* workerManager;
@property (strong, nonatomic) NSMutableSet* workersToAdd;
@property (strong, nonatomic) NSMutableSet* workersToRemove;
@property (nonatomic) BOOL needsAnimatedLayout;
@property (strong, nonatomic) NSArray* notificationRunLoopModes;

@end

@implementation CWorkerManagerDebugView

@synthesize queuedWorkerViews = queuedWorkerViews_;
@synthesize finishedWorkerViews = finishedWorkerViews_;
@synthesize workerManager = workerManager_;
@synthesize workersToAdd = workersToAdd_;
@synthesize workersToRemove = workersToRemove_;
@synthesize needsAnimatedLayout = needsAnimatedLayout_;
@synthesize notificationRunLoopModes = notificationRunLoopModes_;

+ (void)initialize
{
//	CLogSetTagActive(@"WORKER_MANAGER_DEBUG_VIEW", YES);
}

- (void)setup
{
	[super setup];
	
//	self.clipsToBounds = YES;
//	self.debugColor = [UIColor greenColor];
	self.userInteractionEnabled = NO;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.alpha = 0.7;
	
	self.queuedWorkerViews = [NSMutableArray array];
	self.finishedWorkerViews = [NSMutableArray array];
	self.workersToAdd = [NSMutableSet set];
	self.workersToRemove = [NSMutableSet set];
	
	self.notificationRunLoopModes = [NSArray arrayWithObject:NSRunLoopCommonModes];
}

- (id)initWithFrame:(CGRect)frame workerManager:(CWorkerManager*)workerManager
{
	if(self = [self initWithFrame:frame]) {
		self.workerManager = workerManager;
	}
	return self;
}

- (void)beginObservingWorkerManager
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedLayoutIfNeeded) name:@"needsAnimatedLayout" object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncToWorkers) name:@"workerManagerViewNeedsSync" object:self];
	NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
	[self.workerManager addObserver:self forKeyPath:@"workers" options:options context:nil];
}

- (void)endObservingWorkerManager
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"needsAnimatedLayout" object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"workerManagerViewNeedsSync" object:self];
	[self.workerManager removeObserver:self forKeyPath:@"workers"];
}

- (void)sortQueuedWorkerViewsByValues
{
	[self.queuedWorkerViews sortUsingComparator:^NSComparisonResult(CWorkerDebugView* view1, CWorkerDebugView* view2) {
		NSComparisonResult result = NSOrderedSame;
		
		if(result == NSOrderedSame) {
			if(view1.worker.isActive && !view2.worker.isActive) {
				result = NSOrderedAscending;
			} else if(view2.worker.isActive && !view1.worker.isActive) {
				result = NSOrderedDescending;
			}
		}
		
		if(result == NSOrderedSame) {
			if(view1.worker.isReady && !view2.worker.isReady) {
				result = NSOrderedAscending;
			} else if(view2.worker.isReady && !view1.worker.isReady) {
				result = NSOrderedDescending;
			}
		}
		
		if(result == NSOrderedSame) {
			if(view1.worker.queuePriority > view2.worker.queuePriority) {
				result = NSOrderedAscending;
			} else if(view1.worker.queuePriority < view2.worker.queuePriority) {
				result = NSOrderedDescending;
			}
		}
		
		if(result == NSOrderedSame) {
			if(view1.worker.sequenceNumber < view2.worker.sequenceNumber) {
				result = NSOrderedAscending;
			} else if(view1.worker.sequenceNumber > view2.worker.sequenceNumber) {
				result = NSOrderedDescending;
			}
		}
		return result;
	}];
}

- (void)topoVisitNode:(CWorkerDebugView*)node visitedNodes:(NSMutableSet*)visitedNodes allNodes:(NSArray*)allNodes sortedNodes:(NSMutableArray*)sortedNodes
{
	if(![visitedNodes containsObject:node]) {
		[visitedNodes addObject:node];
		
		if(!node.worker.isFinished) {
			for(CWorkerDebugView* mNode in allNodes) {
				if(node != mNode) {
					if([mNode.worker.dependencies containsObject:node.worker]) {
						[self topoVisitNode:mNode visitedNodes:visitedNodes allNodes:allNodes sortedNodes:sortedNodes];
					}
				}
			}
		}
		
		[sortedNodes addObject:node];
	}
}

- (void)sortQueuedWorkerViewsTopologically
{
	// http://en.wikipedia.org/wiki/Topological_sorting
	
	@synchronized(self.workerManager) {
		NSMutableArray* sortedNodes = [NSMutableArray array]; // Empty list that will contain the sorted elements
		
		NSArray* allNodes = self.queuedWorkerViews;
		
		NSMutableArray* startingNodes = [NSMutableArray array]; // Set of all nodes with no outgoing edges
		for(CWorkerDebugView* node in allNodes) {
			BOOL nowReady = YES;
			for(CWorker* predecessorWorker in node.worker.dependencies) {
				if(!predecessorWorker.isFinished) {
					nowReady = NO;
					break;
				}
			}
			if(nowReady) {
				[startingNodes addObject:node];
			}
		}
		
		NSMutableSet* visitedNodes = [NSMutableSet set];
		
		for(CWorkerDebugView* node in startingNodes) {
			[self topoVisitNode:node visitedNodes:visitedNodes allNodes:allNodes sortedNodes:sortedNodes];
		}
		
		self.queuedWorkerViews = [[[sortedNodes reverseObjectEnumerator] allObjects] mutableCopy];
	}
}

- (void)updateQueuedWorkerViewsRows
{
	[self sortQueuedWorkerViewsTopologically];
	[self sortQueuedWorkerViewsByValues];

	NSUInteger row = 0;
	for(CWorkerDebugView* view in self.queuedWorkerViews) {
		view.row = row;
		row++;
	}
}

- (CGFloat)topForView:(CWorkerDebugView*)view
{
	return view.row * kRowHeight;
}

- (void)setNeedsAnimatedLayout
{
	CLogTrace(@"WORKER_MANAGER_DEBUG_VIEW", @"setNeedsAnimatedLayout");
	self.needsAnimatedLayout = YES;
	NSNotification* notification = [NSNotification notificationWithName:@"needsAnimatedLayout" object:self];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:self.notificationRunLoopModes];
}

- (void)beginObservingWorkers:(NSSet*)workers
{
	for(CWorker* worker in workers) {
		[worker addObserver:self forKeyPath:@"isReady" options:0 context:(void*)0x123];
		[worker addObserver:self forKeyPath:@"isActive" options:0 context:(void*)0x123];
	}
}

- (void)endObservingWorkers:(NSSet*)workers
{
	for(CWorker* worker in workers) {
		[worker removeObserver:self forKeyPath:@"isReady" context:(void*)0x123];
		[worker removeObserver:self forKeyPath:@"isActive" context:(void*)0x123];
	}
}

- (void)addWorkers:(NSSet*)addedWorkers
{
	CLogTrace(@"WORKER_MANAGER_DEBUG_VIEW", @"addWorkers:%@", addedWorkers);

	[self beginObservingWorkers:addedWorkers];

	NSMutableArray* addedViews = [NSMutableArray array];
	
	for(CWorker* worker in addedWorkers) {
		CGRect frame = CGRectMake(0, 0, (self.boundsWidth / 2) - 5, kCWorkerDebugViewHeight);
		CWorkerDebugView* view = [[CWorkerDebugView alloc] initWithFrame:frame worker:worker];
		view.alpha = 0.0;
		view.centerX = self.boundsLeft;
		view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[self.queuedWorkerViews addObject:view];
		[self addSubview:view];
		[addedViews addObject:view];
	}

	if(addedWorkers.count > 0) {
		[self updateQueuedWorkerViewsRows];
		for(CWorkerDebugView* view in addedViews) {
			view.top = [self topForView:view];
		}
		[self setNeedsAnimatedLayout];
	}
}

- (void)removeWorkers:(NSSet*)removedWorkers
{
	CLogTrace(@"WORKER_MANAGER_DEBUG_VIEW", @"removeWorkers:%@", removedWorkers);

	[self endObservingWorkers:removedWorkers];

	NSIndexSet* removedViewIndexes = [self.queuedWorkerViews indexesOfObjectsPassingTest:^BOOL(CWorkerDebugView* view, NSUInteger idx, BOOL *stop) {
		return [removedWorkers containsObject:view.worker];
	}];
	NSArray* removedViews = [self.queuedWorkerViews objectsAtIndexes:removedViewIndexes];

	if(removedViews.count > 0) {
		for(CWorkerDebugView* view in removedViews) {
			[self bringSubviewToFront:view];
			view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			view.alpha = 1.0;

			[self.queuedWorkerViews removeObject:view];
			[self.finishedWorkerViews insertObject:view atIndex:0];
			
			[self performSelector:@selector(fadeThenRemoveView:) withObject:view afterDelay:kRemovalFadeDelay];
		}
		
		[self setNeedsAnimatedLayout];
	}
}

- (void)fadeThenRemoveView:(CWorkerDebugView*)view
{
	UIViewAnimationOptions options2 = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionOverrideInheritedCurve;
	[UIView animateWithDuration:kRemovalFadeAnimationDuration delay:0.0 options:options2 animations:^ {
		view.alpha = 0.0;
	} completion:^(BOOL finished){
		[view removeFromSuperview];
		[self.finishedWorkerViews removeObject:view];
	}];
}

- (void)animatedLayout
{
	CLogTrace(@"WORKER_MANAGER_DEBUG_VIEW", @"animatedLayout");
	[self updateQueuedWorkerViewsRows];

	for(CWorkerDebugView* view in self.queuedWorkerViews) {
		[self sendSubviewToBack:view];
	}

	UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut;
	[UIView animateWithDuration:kLayoutAnimationDuration delay:0.0 options:options animations:^{
		for(CWorkerDebugView* view in self.queuedWorkerViews) {
			if(view.alpha != 1.0) {
				view.alpha = 1.0;
			}
			CGRect frame = view.frame;
			if(view.left != self.boundsLeft) {
				frame = [Geom alignRectMinX:frame toX:self.boundsLeft];
			}
			frame = [Geom alignRectMinY:frame toY:[self topForView:view]];
			view.frame = frame;
		}
	} completion:NULL];
	
	UIViewAnimationOptions options2 = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut;
	[UIView animateWithDuration:kRemovalSlideAnimationDuration delay:0.0 options:options2 animations:^{
		NSUInteger row = 0;
		for(CWorkerDebugView* view in self.finishedWorkerViews) {
//			if(view.alpha != 1.0) {
//				view.alpha = 1.0;
//			}
			CGRect frame = view.frame;
			if(row != view.row) {
				view.row = row;
				frame = [Geom alignRectMinY:frame toY:[self topForView:view]];
			}
			if(view.right != self.boundsRight) {
				frame = [Geom alignRectMaxX:frame toX:self.boundsRight];
			}
			view.frame = frame;
			row++;
		}
	} completion:NULL];

	self.needsAnimatedLayout = NO;
}

- (void)animatedLayoutIfNeeded
{
	if(self.needsAnimatedLayout) {
		[self animatedLayout];
	}
}

- (void)syncToWorkers
{
	@synchronized(self) {
		[self addWorkers:self.workersToAdd];
		[self removeWorkers:self.workersToRemove];
		[self.workersToAdd removeAllObjects];
		[self.workersToRemove removeAllObjects];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self.workerManager) {
		if([keyPath isEqualToString:@"workers"]) {
//			CLogTrace(@"WORKER_MANAGER_DEBUG_VIEW", @"workers change: %@", change);
			NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] intValue];
			switch(changeKind) {
				case NSKeyValueChangeInsertion: {
					@synchronized(self) {
						NSSet* addedWorkers = [change objectForKey:NSKeyValueChangeNewKey];
						[self.workersToAdd unionSet:addedWorkers];
					}
					[NSThread performBlockOnMainThread:^{
						NSNotification* notification = [NSNotification notificationWithName:@"workerManagerViewNeedsSync" object:self];
						[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:self.notificationRunLoopModes];
					}];
				}
					break;
				case NSKeyValueChangeRemoval: {
					@synchronized(self) {
						NSSet* removedWorkers = [change objectForKey:NSKeyValueChangeOldKey];
						[self.workersToRemove unionSet:removedWorkers];
					}
					[NSThread performBlockOnMainThread:^{
						NSNotification* notification = [NSNotification notificationWithName:@"workerManagerViewNeedsSync" object:self];
						[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:self.notificationRunLoopModes];
					}];
				}
					break;
			}
		}
	} else if(context == (void*)0x123) {
		[NSThread performBlockOnMainThread:^{
			[self setNeedsAnimatedLayout];
		}];
	}
}

- (void)didMoveToSuperview
{
	if(self.superview != nil) {
		[self beginObservingWorkerManager];
	} else {
		[self endObservingWorkerManager];
	}
}

@end
