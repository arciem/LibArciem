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

@property (nonatomic) NSString *keyPath;
@property (nonatomic) NSPointerArray *mutableObjects;
@property (copy, nonatomic) CObserverBlock action;
@property (copy, nonatomic) CObserverBlock initial;
@property (copy, nonatomic) CObserverBlock prior;
@property (nonatomic) NSKeyValueObservingOptions options;

@end

@implementation CObserver

+ (void)initialize
{
//	CLogSetTagActive(@"C_OBSERVER", YES);
}

- (instancetype)initWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	if(self = [super init]) {
		self.keyPath = keyPath;
//        self.mutableObjects = [NSPointerArray weakObjectsPointerArray];
        // Can't use strong or we create retain cycles. Can't use weak or we can't remove observers we've added when we're dealloced. So use opaque.
        self.mutableObjects = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
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

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action
{
	return [self newObserverWithKeyPath:keyPath action:action initial:NULL prior:NULL];
}

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial
{
	return [self newObserverWithKeyPath:keyPath action:action initial:initial prior:NULL];
}

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	return [[self alloc] initWithKeyPath:keyPath action:action initial:initial prior:prior];
}

- (NSUInteger)indexOfObject:(id)object
{
	__block NSUInteger foundIndex = NSNotFound;

	[[self.mutableObjects allObjects] enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
		if(value == object) {
			foundIndex = idx;
			*stop = YES;
		}
	}];
	
	return foundIndex;
}

- (void)addObject_:(id)object
{
	[self.mutableObjects addPointer:(void*)object];
	[object addObserver:self forKeyPath:self.keyPath options:self.options context:NULL];
}

- (void)removeObject:(id)object atIndex_:(NSUInteger)index
{
	[self.mutableObjects removePointerAtIndex:index];
	[object removeObserver:self forKeyPath:self.keyPath];
}

- (void)addObject:(id)object
{
	if(object != nil) {
		NSUInteger index = [self indexOfObject:object];
		NSAssert1(index == NSNotFound, @"Attempt to add already-observed object:%@", object);
		[self addObject_:object];
	}
}

- (void)removeObject:(id)object
{
	if(object != nil) {
		NSUInteger index = [self indexOfObject:object];
		NSAssert1(index != NSNotFound, @"Attempt to remove non-observed object:%@", object);
		[self removeObject:object atIndex_:index];
	}
}

- (void)addObjects:(NSArray*)array
{
	for(id object in array) {
		[self addObject:object];
	}
}

- (void)removeObjects:(NSArray*)array
{
	for(id object in array) {
		[self removeObject:object];
	}
}

- (void)removeAllObjects {
    [self removeObjects:self.objects];
}

- (NSArray*)objects
{
	return [self.mutableObjects allObjects];
}

- (void)setObjects:(NSArray*)objects
{
    BSELF;
	[objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		NSUInteger index = [bself indexOfObject:object];
		if(index == NSNotFound) {
			[bself addObject_:object];
		} else {
			[bself removeObject:object atIndex_:index];
		}
	}];
}

- (instancetype)initWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	if(self = [self initWithKeyPath:keyPath action:action initial:initial prior:prior]) {
		NSAssert(object != nil, @"Cannot create observer for nil object");
        if(object != nil) {
            [self addObject:object];
        }
	}
	return self;
}

- (instancetype)initWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action
{
	if(self = [self initWithKeyPath:keyPath ofObject:object action:action initial:NULL prior:NULL]) {
	}
	return self;
}

- (NSString*)description
{
	return [self formatObjectWithValues:@[[self formatValueForKey:@"keyPath" compact:YES],
										 [self formatValueForKey:@"objects" compact:YES]]];
}

- (void)dealloc
{
	CLogTrace(@"C_OBSERVER", @"%@ dealloc", self);
    for(id value in self.mutableObjects) {
		[value removeObserver:self forKeyPath:self.keyPath context:NULL];
    }
	self.mutableObjects = nil;
    self.action = nil;
    self.initial = nil;
    self.prior = nil;
}

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior
{
	return [[self alloc] initWithKeyPath:keyPath ofObject:object action:action initial:initial prior:prior];
}

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action
{
	return [self newObserverWithKeyPath:keyPath ofObject:object action:action initial:NULL prior:NULL];
}

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial
{
	return [self newObserverWithKeyPath:keyPath ofObject:object action:action initial:initial prior:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
	id oldValue = change[NSKeyValueChangeOldKey];
	id newValue = change[NSKeyValueChangeNewKey];
	NSIndexSet* indexes = change[NSKeyValueChangeIndexesKey];
	CLogTrace(@"C_OBSERVER", @"%@ change new:%@ old:%@ kind:%d indexes:%@", self, newValue, oldValue, kind, indexes);
    if([change[NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
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

@end
