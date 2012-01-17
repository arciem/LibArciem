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
#import "CNotifier.h"
#import "CNotifierView.h"
#import "UIViewUtils.h"

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

	[[CNotifier sharedNotifier] addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionInitial context:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateItemsSoon) name:kNeedsUpdateItemsNotification object:self];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedsUpdateItemsNotification object:self];
	[[CNotifier sharedNotifier] removeObserver:self forKeyPath:@"items"];
}

- (void)updateItemsSoon
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateItems) object:nil];
	[self performSelector:@selector(updateItems) withObject:nil afterDelay:0.5];
}

- (void)updateItems
{
//	CLogDebug(nil, @"%@ updateItems", self);

	NSArray* oldOrderedItems = self.items;
	NSSet* newItems = [CNotifier sharedNotifier].items;
	NSArray* newOrderedItems = [newItems sortedArrayUsingDescriptors:self.sortDescriptors];

	NSMutableSet* visibleItems = [NSMutableSet set];
	NSMutableSet* hiddenItems = [NSMutableSet set];

	for(CNotifierItem* oldItem in oldOrderedItems) {
		if(![newItems containsObject:oldItem]) {
			[hiddenItems addObject:oldItem];
		}
	}

	[newOrderedItems enumerateObjectsUsingBlock:^(CNotifierItem* newItem, NSUInteger idx, BOOL *stop) {
		if(idx >= self.rowCapacity) {
			[hiddenItems addObject:newItem];
		} else {
			[visibleItems addObject:newItem];
		}
	}];
	
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

	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
		for(CNotifierView* view in self.subviews) {
			if([exitingViews containsObject:view]) {
				NSUInteger index = [oldOrderedItems indexOfObject:view.item];
				if(index == 0 && !willSlideInFromTop) {
					view.top = -self.rowHeight;
				} else {
					view.alpha = 0.0;
				}
			} else {
				NSUInteger index = [newOrderedItems indexOfObject:view.item];
				if(index != NSNotFound) {
					view.top = self.rowHeight * index;
				}
				view.alpha = 1.0;
			}
		}
		
		self.height = fminf(fmaxf(newItems.count, 0), self.rowCapacity) * self.rowHeight;

	} completion:^(BOOL finished) {
		for(CNotifierView* view in exitingViews) {
			[view removeFromSuperview];
		}
	}];
	
	self.items = newOrderedItems;
}

- (void)setNeedsUpdateItems
{
//	CLogDebug(nil, @"%@ setNeedsUpdateItems", self);

	NSNotification* notification = [NSNotification notificationWithName:kNeedsUpdateItemsNotification object:self];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == [CNotifier sharedNotifier]) {
		if([keyPath isEqualToString:@"items"]) {
			[self setNeedsUpdateItems];
		}
	}
}

@end
