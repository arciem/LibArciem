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

#import "CNotifierGroup.h"

@interface CNotifierGroup2 ()

@property (strong, nonatomic) NSMutableSet* notifiers;
@property (strong, nonatomic) NSMutableSet* items;

@end

@implementation CNotifierGroup2

@synthesize notifiers = notifiers_;
@synthesize items = items_;

- (id)init
{
	if(self = [super init]) {
		self.notifiers = [NSMutableSet set];
		self.items = [NSMutableSet set];
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		for(CNotifier* notifier in self.notifiers) {
			[self removeNotifier:notifier];
		}
	}
}

- (void)addNotifier:(CNotifier*)notifier
{
	@synchronized(self) {
		if(![self.notifiers containsObject:notifier]) {
			[self.notifiers addObject:notifier];
			for(CNotifierItem* item in self.items) {
				[notifier addItem:item];
			}
		}
	}
}

- (void)removeNotifier:(CNotifier*)notifier
{
	@synchronized(self) {
		if([self.notifiers containsObject:notifier]) {
			for(CNotifierItem* item in self.items) {
				[notifier removeItem:item];
			}
			[self.notifiers removeObject:notifier];
		}
	}
}

- (void)addItem:(CNotifierItem*)item
{
	@synchronized(self) {
		if(![self.items containsObject:item]) {
			[self.items addObject:item];
			for(CNotifier* notifier in self.notifiers) {
				[notifier addItem:item];
			}
		}
	}
}

- (void)removeItem:(CNotifierItem*)item
{
	@synchronized(self) {
		if([self.items containsObject:item]) {
			for(CNotifier* notifier in self.notifiers) {
				[notifier removeItem:item];
			}
			[self.items removeObject:item];
		}
	}
}

@end
