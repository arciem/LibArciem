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
#include "random.hpp"

static CNotifier* sInstance = nil;

@interface CNotifier ()

@property (strong, nonatomic) NSMutableSet* internalItems;

@end

@implementation CNotifier

@synthesize internalItems = internalItems_;
@dynamic items;

+ (void)initialize
{
//	CLogSetTagActive(@"C_NOTIFIER", YES);
}

+ (CNotifier*)sharedNotifier
{
	@synchronized([CNotifier class]) {
		if(sInstance == nil) {
			sInstance = [[CNotifier alloc] init];
		}
	}
	
	return sInstance;
}

- (id)init
{
	@synchronized([CNotifier class]) {
		if(sInstance == nil) {
			if(self = [super init]) {
				self.internalItems = [NSMutableSet set];
			}
		} else {
			self = nil;
		}
	}
	
	return self;
}

- (void)addItem:(CNotifierItem*)item
{
	[NSThread performBlockOnMainThread:^{
		@synchronized(self) {
			if(![self hasItem:item]) {
				NSSet* newItems = [NSSet setWithObject:item];
				[self willChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:newItems];
				[self.internalItems addObject:item];
				if(item.duration > 0.0) {
					[self performSelector:@selector(removeItem:) withObject:item afterDelay:item.duration];
				}
				[self didChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:newItems];
			}
		}
	}];
}

- (void)removeItem:(CNotifierItem*)item
{
	[NSThread performBlockOnMainThread:^{
		@synchronized(self) {
			if([self hasItem:item]) {
				NSSet* oldItems = [NSSet setWithObject:item];
				[self willChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:oldItems];
				[self.internalItems removeObject:item];
				[self didChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:oldItems];
			}
		}
	}];
}

- (BOOL)hasItem:(CNotifierItem*)item
{
	BOOL has = NO;
	@synchronized(self) {
		has = [self.internalItems containsObject:item];
	}
	return has;
}

- (NSSet*)items
{
	NSSet* result = nil;
	@synchronized(self) {
		result = [self.internalItems copy];
	}
	return result;
}

+ (void)test
{
	[NSThread performBlockInBackground:^{
		[NSThread sleepForTimeInterval:3.0];
		NSMutableArray* items = [NSMutableArray array];
		NSInteger nextItem = 1;
		for(int i = 0; i < 100; i++) {
			if(arciem::random_flat() < 0.5) {
				NSString* message = [NSString stringWithFormat:@"Item %d", nextItem++];
				NSInteger priority = arciem::random_range(0, 3);
				
				CNotifierItem* item = [CNotifierItem itemWithMessage:message priority:priority tapHandler:NULL];
				[items addObject:item];
				switch(priority) {
					case 0:
						item.tintColor = [[UIColor greenColor] colorByLighteningFraction:0.1];
						break;
					case 1:
						item.tintColor = [UIColor yellowColor];
						break;
					case 2:
						item.tintColor = [[UIColor redColor] colorByLighteningFraction:0.2];
						item.whiteText = YES;
						break;
					default:
						item.tintColor = [UIColor whiteColor];
						break;
				}
				[[CNotifier sharedNotifier] addItem:item];
				CLogTrace(@"C_NOTIFIER", @"Add: %@", item.message);
			} else {
				if(items.count > 0) {
					NSUInteger index = arciem::random_range(0, items.count);
					CNotifierItem* item = [items objectAtIndex:index];
					CLogTrace(@"C_NOTIFIER", @"Remove: %@", item.message);
					[[CNotifier sharedNotifier] removeItem:item];
					[items removeObject:item];
				}
			}
			[NSThread sleepForTimeInterval:arciem::random_range(0.2, 4.0)];
		}
		for(CNotifierItem* item in items.reverseObjectEnumerator) {
			[[CNotifier sharedNotifier] removeItem:item];
			[NSThread sleepForTimeInterval:1.0];
		}
	}];
}

@end
