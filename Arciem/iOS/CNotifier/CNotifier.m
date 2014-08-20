/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CNotifier.h"
#import "ThreadUtils.h"
#import "UIColorUtils.h"
#include "random.h"
#import "ObjectUtils.h"
#import "CSerializer.h"
#import "DispatchUtils.h"

@interface CNotifier ()

@property (nonatomic) NSMutableSet* subscriptions;
@property (nonatomic) NSMutableSet* internalItems;
@property (nonatomic) CSerializer *serializer;

@end

@implementation CNotifier

@synthesize subscriptions = subscriptions_;
@synthesize internalItems = internalItems_;
@synthesize name = name_;
@dynamic items;

+ (void)initialize
{
//	CLogSetTagActive(@"C_NOTIFIER", YES);
}

- (instancetype)init
{
	if(self = [super init]) {
		self.subscriptions = [NSMutableSet set];
		self.internalItems = [NSMutableSet set];
        self.serializer = [CSerializer newSerializerWithName:@"CNotifier Serializer"];
	}
	
	return self;
}

- (void)dealloc
{
	[self.serializer dispatch:^{
		CLogTrace(@"C_NOTIFIER", @"%@ dealloc", self);
		for(CNotifier* notifier in [self.subscriptions copy]) {
			[self unsubscribeFromNotifier:notifier];
		}
	}];
}

- (NSString*)description
{
	return [self.serializer dispatchWithResult:^{
		return [self formatObjectWithValues:@[[self formatValueForKey:@"name" compact:NO]]];
	}];
}

- (void)subscribeToNotifier:(CNotifier*)notifier
{
	[self.serializer dispatch:^{
		CLogTrace(@"C_NOTIFIER", @"%@ subscribeToNotifier:%@", self, notifier);
		if(![self.subscriptions containsObject:notifier]) {
			[self.subscriptions addObject:notifier];
			[notifier addObserver:self forKeyPath:@"items" options:(NSKeyValueObservingOptions)(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
		}
	}];
}

- (void)unsubscribeFromNotifier:(CNotifier*)notifier
{
	[self.serializer dispatch:^{
		CLogTrace(@"C_NOTIFIER", @"%@ unsubscribeFromNotifier:%@", self, notifier);
		if([self.subscriptions containsObject:notifier]) {
			[self.subscriptions removeObject:notifier];
			[notifier removeObserver:self forKeyPath:@"items"];
		}
	}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self.serializer dispatch:^{
		if([self.subscriptions containsObject:object]) {
			if([keyPath isEqualToString:@"items"]) {
				NSUInteger changeKind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
				switch(changeKind) {
					case NSKeyValueChangeSetting: {
						NSSet* newItems = change[NSKeyValueChangeNewKey];
						[self addItems:newItems withExpiry:NO];
					} break;
					case NSKeyValueChangeInsertion: {
						NSSet* newItems = change[NSKeyValueChangeNewKey];
						[self addItems:newItems withExpiry:NO];
					} break;
					case NSKeyValueChangeRemoval: {
						NSSet* oldItems = change[NSKeyValueChangeOldKey];
						[self removeItems:oldItems];
					} break;
					default: {
						NSAssert1(NO, @"Unimplemented change kind:%ld", (unsigned long)changeKind);
					} break;
				}
			}
		}
	}];
}

+ (BOOL)automaticallyNotifiesObserversOfItems
{
	return NO;
}

- (void)addItems:(NSSet*)items withExpiry:(BOOL)expire
{
	[self.serializer dispatch:^{
		NSSet* newItems = [items objectsPassingTest:^BOOL(CNotifierItem *item, BOOL *stop) {
			return ![self.items containsObject:item];
		}];
		if(newItems.count > 0) {
			CLogTrace(@"C_NOTIFIER", @"%@ adding: %@", self, newItems);
			[self willChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:newItems];
			[self.internalItems unionSet:newItems];
			[self didChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:newItems];
            [newItems enumerateObjectsUsingBlock:^(CNotifierItem *item, BOOL *stop) {
                [item incrementVisible];
                if(expire && item.duration > 0.0) {
                    [self performSelector:@selector(removeItem:) withObject:item afterDelay:item.duration];
                }
            }];
		}
	}];
}

- (void)addItems:(NSSet*)items
{
	[self addItems:items withExpiry:YES];
}

- (void)addItem:(CNotifierItem*)item
{
	if(item != nil) {
		[self addItems:[NSSet setWithObject:item]];
	}
}

- (void)removeItems:(NSSet*)items
{
	[self.serializer dispatch:^{
		NSSet* oldItems = [items objectsPassingTest:^BOOL(CNotifierItem *item, BOOL *stop) {
			return [self.items containsObject:item];
		}];
		if(oldItems.count > 0) {
			CLogTrace(@"C_NOTIFIER", @"%@ removing: %@", self, oldItems);
            [oldItems enumerateObjectsUsingBlock:^(CNotifierItem *item, BOOL *stop) {
				if(item.duration > 0.0) {
					[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeItem:) object:item];
				}
                [item decrementVisible];
            }];
			[self willChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:oldItems];
			[self.internalItems minusSet:oldItems];
			[self didChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:oldItems];
		}
	}];
}

- (void)removeItem:(CNotifierItem*)item
{
	if(item != nil) {
		[self removeItems:[NSSet setWithObject:item]];
	}
}

- (BOOL)hasItem:(CNotifierItem*)item
{
	BOOL has = NO;
	has = [[self.serializer dispatchWithResult:^{
		return @([self.internalItems containsObject:item]);
	}] boolValue];
	return has;
}

- (NSSet*)items
{
	NSSet* result = nil;
	result = [self.serializer dispatchWithResult:^{
		return [self.internalItems copy];
	}];
	return result;
}

+ (void)testWithNotifier:(CNotifier*)notifier
{
	dispatchOnBackground(^{
		[NSThread sleepForTimeInterval:3.0];
		NSMutableArray* items = [NSMutableArray array];
		NSInteger nextItem = 1;
		for(int i = 0; i < 100; i++) {
			if(random_flat() < 0.5) {
				NSString* message = [NSString stringWithFormat:@"Item %ld", (long)nextItem++];
				NSInteger priority = random_range(0, 3);
				
				CNotifierItem* item = [CNotifierItem itemWithMessage:message priority:priority tapHandler:NULL];
				[items addObject:item];
				switch(priority) {
					case 0:
						item.tintColor = [[UIColor greenColor] newColorByLighteningFraction:0.1];
						break;
					case 1:
						item.tintColor = [UIColor yellowColor];
						break;
					case 2:
						item.tintColor = [[UIColor redColor] newColorByLighteningFraction:0.2];
						item.whiteText = YES;
						break;
					default:
						item.tintColor = [UIColor whiteColor];
						break;
				}
				[notifier addItem:item];
				CLogTrace(@"C_NOTIFIER", @"Add: %@", item.message);
			} else {
				if(items.count > 0) {
					NSUInteger index = random_range(0, items.count);
					CNotifierItem* item = items[index];
					CLogTrace(@"C_NOTIFIER", @"Remove: %@", item.message);
					[notifier removeItem:item];
					[items removeObject:item];
				}
			}
			[NSThread sleepForTimeInterval:random_range(0.2, 4.0)];
		}
		for(CNotifierItem* item in items.reverseObjectEnumerator) {
			[notifier removeItem:item];
			[NSThread sleepForTimeInterval:1.0];
		}
	});
}

@end