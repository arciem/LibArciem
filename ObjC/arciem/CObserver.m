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

#import "CObserver.h"
#import "ObjectUtils.h"

@interface CObserver ()

@property (strong, nonatomic) NSString* keyPath;
@property (weak, nonatomic) id object;
@property (copy, nonatomic) CObserverBlock action;
@property (copy, nonatomic) CObserverBlock initial;
@property (copy, nonatomic) CObserverBlock prior;

@end

@implementation CObserver

@synthesize keyPath = keyPath_;
@synthesize object = object_;
@synthesize action = action_;
@synthesize initial = initial_;
@synthesize prior = prior_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_OBSERVER", YES);
}

- (id)initWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	if(self = [super init]) {
		self.keyPath = keyPath;
		NSAssert(object != nil, @"Cannot create observer for nil object");
		self.object = object;
		self.action = action;
		self.initial = initial;
		self.prior = prior;
		
		NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
		
		if(self.initial != NULL) {
			options |= NSKeyValueObservingOptionInitial;
		}
		
		if(self.prior != NULL) {
			options |= NSKeyValueObservingOptionPrior;
		}

		[object addObserver:self forKeyPath:keyPath options:options context:NULL];
		CLogTrace(@"C_OBSERVER", @"%@ init", self);
	}
	return self;
}

- (id)initWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action
{
	if(self = [self initWithKeyPath:keyPath ofObject:object action:action initial:NULL prior:NULL]) {
	}
	return self;
}

- (NSString*)description
{
	return [self formatObjectWithValues:[NSArray arrayWithObjects:
										 [self formatValueForKey:@"keyPath" compact:YES],
										 [self formatValueForKey:@"object" compact:YES],
										 nil]];
}

- (void)dealloc
{
	CLogTrace(@"C_OBSERVER", @"%@ dealloc", self);
	NSAssert1(self.object != nil, @"object deallocated before observer for keyPath:%@", self.keyPath);
	[self.object removeObserver:self forKeyPath:self.keyPath context:NULL];
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	return [[[self class] alloc] initWithKeyPath:keyPath ofObject:object action:action initial:initial prior:prior];
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action
{
	return [self observerWithKeyPath:keyPath ofObject:object action:action initial:NULL prior:NULL];
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial
{
	return [self observerWithKeyPath:keyPath ofObject:object action:action initial:initial prior:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
	CLogTrace(@"C_OBSERVER", @"%@ change new:%@ old:%@ kind:%d indexes:%@", self, newValue, oldValue, kind, indexes);
	if(!Same(newValue, oldValue)) {
		if([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
			if(self.prior != NULL) {
				// newValue will always be nil
				self.prior(newValue, oldValue, kind, indexes);
			}
		} else if(oldValue == nil && kind == NSKeyValueChangeSetting) {
			if(self.initial != NULL) {
				// oldValue will always be nil
				self.initial(newValue, oldValue, kind, indexes);
			}
		} else {
			if(self.action != NULL) {
				self.action(newValue, oldValue, kind, indexes);
			}
		}
	}
}

@end
