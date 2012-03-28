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

#import "CNotifierBar.h"
#import "CNotifierView.h"
#import "UIViewUtils.h"
#import "ThreadUtils.h"
#import "ObjectUtils.h"

NSString* const kNeedsUpdateItemsNotification = @"kNeedsUpdateItemsNotification";

@interface CNotifierBar ()

@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) NSArray* sortDescriptors;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) NSUInteger rowCapacity;

@end

@implementation CNotifierBar

@synthesize items = items_;
@synthesize sortDescriptors = sortDescriptors_;
@synthesize rowHeight = rowHeight_;
@synthesize rowCapacity = rowCapacity_;
@synthesize notifier = notifier_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_NOTIFIER_BAR", YES);
}

- (void)setup
{
	[super setup];

	self.clipsToBounds = YES;
//	self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];

	NSSortDescriptor* priorityDescendingDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
	NSSortDescriptor* dateDescendingDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
	self.sortDescriptors = [NSArray arrayWithObjects:priorityDescendingDescriptor, dateDescendingDescriptor, nil];

	self.items = [NSArray array];

	self.rowCapacity = 1;
	self.rowHeight = self.height;
	
	[self addObserver:self forKeyPath:@"notifier" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(armUpdateItems) name:kNeedsUpdateItemsNotification object:self];
}

- (void)dealloc
{
	CLogTrace(@"C_NOTIFIER_BAR", @"%@ dealloc", self);
	self.notifier = nil;
	[self removeObserver:self forKeyPath:@"notifier"];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedsUpdateItemsNotification object:self];
}

- (NSString*)description
{
	return [self formatObjectWithValues:[NSArray arrayWithObjects:
										 [self formatValueForKey:@"notifier" compact:NO],
										 nil]];
}

+ (BOOL)automaticallyNotifiesObserversOfNotifier
{
	return NO;
}

- (CNotifier*)notifier
{
	return notifier_;
}

- (void)setNotifier:(CNotifier *)notifier
{
	if(notifier_ != notifier) {
		[self willChangeValueForKey:@"notifier"];
		notifier_ = notifier;
		[self didChangeValueForKey:@"notifier"];
	}
}

- (void)disarmUpdateItems
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateItemsAnimated:) object:[NSNumber numberWithBool:YES]];
}

- (void)armUpdateItems
{
	CLogTrace(@"C_NOTIFIER_BAR", @"%@ armUpdateItems", self);
	[self disarmUpdateItems];
	[self performSelector:@selector(updateItemsAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)updateItemsAnimated:(BOOL)animated
{
	CLogTrace(@"C_NOTIFIER_BAR", @"%@ updateItems", self);

	[self disarmUpdateItems];

	NSArray* oldOrderedItems = self.items;
	NSSet* newItems = self.notifier.items;
	if(newItems == nil) {
		newItems = [NSSet set];
	}

	NSArray* newOrderedItems = [newItems sortedArrayUsingDescriptors:self.sortDescriptors];

	NSMutableSet* visibleItems = [NSMutableSet set];
	NSMutableSet* hiddenItems = [NSMutableSet set];

	for(CNotifierItem* oldItem in oldOrderedItems) {
		if(![newItems containsObject:oldItem]) {
			[hiddenItems addObject:oldItem];
		}
	}

	__block NSUInteger countOfVisibleItemsWithTapHandlers = 0;
	[newOrderedItems enumerateObjectsUsingBlock:^(CNotifierItem* newItem, NSUInteger idx, BOOL *stop) {
		if(idx >= self.rowCapacity) {
			[hiddenItems addObject:newItem];
		} else {
			[visibleItems addObject:newItem];
			if(newItem.tapHandler != NULL) {
				countOfVisibleItemsWithTapHandlers++;
			}
		}
	}];
	
	self.userInteractionEnabled = countOfVisibleItemsWithTapHandlers > 0;
	
	NSArray* exitingViews = [self.subviews objectsAtIndexes:[self.subviews indexesOfObjectsPassingTest:^BOOL(CNotifierView* view, NSUInteger idx, BOOL *stop) {
		return [hiddenItems containsObject:view.item];
	}]];
	
	BOOL willSlideInFromTop = NO;
	
	NSMutableArray* enteringViews = [NSMutableArray array];
	for(CNotifierItem* item in visibleItems) {
		NSUInteger existingIndex = [self.subviews indexOfObjectPassingTest:^BOOL(CNotifierView* view, NSUInteger idx, BOOL *stop) {
			return view.item == item;
		}];
		if(existingIndex == NSNotFound) {
			NSUInteger index = [newOrderedItems indexOfObject:item];
			CGFloat top;
			CGFloat alpha;
			if(index == 0) {
				top = -self.rowHeight;
				alpha = 1.0;
				willSlideInFromTop = YES;
			} else {
				top = self.rowHeight * index;
				alpha = 0.0;
			}
			CNotifierView* view = [[CNotifierView alloc] initWithFrame:CGRectMake(0, top, self.width, self.rowHeight)];
			view.item = item;
			view.alpha = alpha;
			[enteringViews addObject:view];
			[self addSubview:view];
		}
	}

	NSTimeInterval duration = animated ? 0.5 : 0.0;
	[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
		for(CNotifierView* view in self.subviews) {
			if([exitingViews containsObject:view]) {
				NSUInteger index = [oldOrderedItems indexOfObject:view.item];
				if(index == 0 && !willSlideInFromTop) {
					view.cframe.top = -self.rowHeight;
				} else {
					view.alpha = 0.0;
				}
			} else {
				NSUInteger index = [newOrderedItems indexOfObject:view.item];
				if(index != NSNotFound) {
					view.cframe.top = self.rowHeight * index;
				}
				view.alpha = 1.0;
			}
		}
		
		CFrame* myFrame = [CFrame frameWithView:self];
		myFrame.height = fminf(fmaxf(newItems.count, 0), self.rowCapacity) * self.rowHeight;

	} completion:^(BOOL finished) {
		for(CNotifierView* view in exitingViews) {
			[view removeFromSuperview];
		}
	}];
	
	self.items = newOrderedItems;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	if(object == self) {
		if([keyPath isEqualToString:@"notifier"]) {
			CNotifier* oldNotifier = Denull([change objectForKey:NSKeyValueChangeOldKey]);
			[oldNotifier removeObserver:self forKeyPath:@"items"];
			CNotifier* newNotifier = Denull([change objectForKey:NSKeyValueChangeNewKey]);
			[newNotifier addObserver:self forKeyPath:@"items" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
			CLogTrace(@"C_NOTIFIER_BAR", @"%@ notifierChanged", self);
		}
	} if(object == self.notifier) {
		if([keyPath isEqualToString:@"items"]) {
			CLogTrace(@"C_NOTIFIER_BAR", @"%@ itemsChanged", self);
			[NSThread performBlockOnMainThread:^ {
				NSNotification* notification = [NSNotification notificationWithName:kNeedsUpdateItemsNotification object:self];
				[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
				CLogTrace(@"C_NOTIFIER_BAR", @"%@ posted notification:%@ runloopmode:%@", self, notification, [[NSRunLoop currentRunLoop] currentMode]);
			}];
		}
	}
}

@end
