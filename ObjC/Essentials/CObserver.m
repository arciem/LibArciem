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
@property (strong, nonatomic) NSMutableArray* objects;
@property (copy, nonatomic) CObserverBlock action;
@property (copy, nonatomic) CObserverBlock initial;
@property (copy, nonatomic) CObserverBlock prior;
@property (nonatomic) NSKeyValueObservingOptions options;

@end

@implementation CObserver

@synthesize keyPath = keyPath_;
@synthesize objects = objects_;
@synthesize action = action_;
@synthesize initial = initial_;
@synthesize prior = prior_;
@synthesize options = options_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_OBSERVER", YES);
}

- (id)initWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	if(self = [super init]) {
		self.keyPath = keyPath;
		self.objects = [NSMutableArray array];
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
		
		self.options = options;
		
		CLogTrace(@"C_OBSERVER", @"%@ init", self);
	}
	return self;
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action
{
	return [self observerWithKeyPath:keyPath action:action initial:NULL prior:NULL];
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial
{
	return [self observerWithKeyPath:keyPath action:action initial:initial prior:NULL];
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	return [[self alloc] initWithKeyPath:keyPath action:action initial:initial prior:prior];
}

- (NSUInteger)indexOfObject:(id)object
{
	__block NSUInteger foundIndex = NSNotFound;

	[self.objects enumerateObjectsUsingBlock:^(NSValue* value, NSUInteger idx, BOOL *stop) {
		if([value nonretainedObjectValue] == object) {
			foundIndex = idx;
			*stop = YES;
		}
	}];
	
	return foundIndex;
}

- (void)addObject:(id)object
{
	NSUInteger index = [self indexOfObject:object];
	NSAssert1(index == NSNotFound, @"Attempt to add already-observed object:%@", object);
	[self.objects addObject:[NSValue valueWithNonretainedObject:object]];
	[object addObserver:self forKeyPath:self.keyPath options:self.options context:NULL];
}

- (void)removeObject:(id)object
{
	NSUInteger index = [self indexOfObject:object];
	NSAssert1(index != NSNotFound, @"Attempt to remove non-observed object:%@", object);
	[self.objects removeObjectAtIndex:index];
	[object removeObserver:self forKeyPath:self.keyPath];
}

- (id)initWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	if(self = [self initWithKeyPath:keyPath action:action initial:initial prior:prior]) {
		NSAssert(object != nil, @"Cannot create observer for nil object");
		[self addObject:object];
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
										 [self formatValueForKey:@"objects" compact:YES],
										 nil]];
}

- (void)dealloc
{
	CLogTrace(@"C_OBSERVER", @"%@ dealloc", self);
//	NSAssert1(self.object != nil, @"object deallocated before observer for keyPath:%@", self.keyPath);
	[self.objects enumerateObjectsUsingBlock:^(NSValue* value, NSUInteger idx, BOOL *stop) {
		id object = [value nonretainedObjectValue];
		[object removeObserver:self forKeyPath:self.keyPath context:NULL];
	}];
	self.objects = nil;
}

+ (CObserver*)observerWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	return [[self alloc] initWithKeyPath:keyPath ofObject:object action:action initial:initial prior:prior];
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
				self.prior(object, newValue, oldValue, kind, indexes);
			}
		} else if(oldValue == nil && kind == NSKeyValueChangeSetting) {
			if(self.initial != NULL) {
				// oldValue will always be nil
				self.initial(object, newValue, oldValue, kind, indexes);
			}
		} else {
			if(self.action != NULL) {
				self.action(object, newValue, oldValue, kind, indexes);
			}
		}
	}
}

@end
