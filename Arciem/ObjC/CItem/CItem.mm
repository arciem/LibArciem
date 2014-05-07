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

#import "CItem.h"
#import "ObjectUtils.h"
#import "StringUtils.h"
#import "ErrorUtils.h"
#import "CObserver.h"
#import "random.hpp"

NSString *const CItemErrorDomain = @"CItemErrorDomain";

@interface CItem () {
	NSMutableArray *subitems__;
}

@property (weak, readwrite, nonatomic) CItem *superitem;
@property (readonly, nonatomic) NSMutableArray *subitems_;
@property (nonatomic) NSUInteger currentRevision;
@property (nonatomic) NSUInteger lastValidatedRevision;
@property (readonly, nonatomic) NSUInteger validationsInProgress;
@property (nonatomic) NSMutableArray *subitemErrors;
@property (readwrite, nonatomic) BOOL validating;
@property (nonatomic) CObserver *valueObserver;
@property (readwrite, nonatomic) BOOL active;
@property (copy, readwrite, nonatomic) NSMutableDictionary *dict;

@end

@implementation CItem

@synthesize dict = _dict;
@synthesize error = _error;
@synthesize subitemErrors = _subitemErrors;
@synthesize superitem = _superitem;
@synthesize currentRevision = _currentRevision;
@synthesize lastValidatedRevision = _lastValidatedRevision;
@synthesize validatesAutomatically = _validatesAutomatically;
@synthesize required = _required;
@synthesize hidden = _hidden;
@synthesize enabled = _enabled;
@synthesize selectable = _selectable;
@synthesize selected = _selected;
@synthesize validating = _validating;
@synthesize editing = _editing;
@synthesize validationsInProgress = _validationsInProgress;

@dynamic subitems_;

#pragma mark - Lifecycle

+ (void)initialize {
//	CLogSetTagActive(@"C_ITEM", YES);
}

- (void)setup {
	// behavior provided by subclasses
}

- (instancetype)initWithDictionary:(NSDictionary*)dict NS_RETURNS_RETAINED {
	NSMutableDictionary *mutableDict = nil;
	if(dict == nil) {
		mutableDict = [NSMutableDictionary dictionary];
	} else {
		mutableDict = [dict mutableCopy];
	}
	
	NSString *type = mutableDict[@"type"];
	if(!IsEmptyString(type)) {
		NSString *firstChar = [[type substringToIndex:1] uppercaseString];
		NSString *remainingChars = [type substringFromIndex:1];
		NSString *className = [NSString stringWithFormat:@"C%@%@Item", firstChar, remainingChars];
		self = (CItem*)[NSObject newInstanceOfClassNamed:className];
		NSAssert1(self != nil, @"Attempt to instantiate undefined class:%@", className);
		CLogTrace(@"C_ITEM", @"%@ alloc", self);
	}
	[mutableDict removeObjectForKey:@"type"];

	if(self = [super init]) {
		_dict = mutableDict;
		[self incrementCurrentRevision];
		_required = [_dict[@"required"] boolValue];
		_enabled = ![_dict[@"disabled"] boolValue];
		_hidden = [_dict[@"hidden"] boolValue];
        _selectable = [_dict[@"selectable"] boolValue];
        _selected = [_dict[@"selected"] boolValue];
		_validatesAutomatically = [_dict[@"validatesAutomatically"] boolValue];
		
		NSArray *subdicts = _dict[@"subitems"];
		subitems__ = [NSMutableArray array];
		for(NSDictionary *subdict in subdicts) {
            CItem *subitem = [CItem newItemWithDictionary:subdict];
			[self addSubitem:subitem];
            CLogTrace(@"C_ITEM", @"%@ added as subitem of %@", subitem, self);
		}
		[_dict removeObjectForKey:@"subitems"];
		[self setup];
		CLogTrace(@"C_ITEM", @"%@ initWithDictionary", self);
	}
	return self;
}

- (instancetype)initWithJSONRepresentation:(NSString *)json NS_RETURNS_RETAINED {
	NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSAssert1(error == nil, @"Parsing JSON:%@", error);
	if(self = [self initWithDictionary:dict]) {
		
	}
	return self;
}

+ (CItem*)newItemForResourceName:(NSString*)resourceName withExtension:(NSString*)extension {
	NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:extension];
	NSData *data = [NSData dataWithContentsOfURL:url];
	NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	CItem *item = [CItem newItemWithJSONRepresentation:json];
	return item;
}

+ (CItem*)newItemForResourceName:(NSString*)resourceName {
	return [self newItemForResourceName:resourceName withExtension:@"json"];
}

- (instancetype)init {
	if(self = [self initWithDictionary:nil]) {
	}
	
	return self;
}

- (void)dealloc {
	CLogTrace(@"C_ITEM", @"%@ dealloc", [self formatObjectWithValues:nil]);
}

+ (CItem*)newItemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

+ (CItem*)newItemWithJSONRepresentation:(NSString*)json {
	return [[self alloc] initWithJSONRepresentation:json];
}

- (id)copyWithZone:(NSZone *)zone {
	CItem *item = [[[self class] allocWithZone:zone] init];
	
	item->_dict = [self.dict mutableCopy];
	item->_error = [self.error copy];
	item->_subitemErrors = [self.subitemErrors mutableCopy];
	
	item->_currentRevision = self.currentRevision;
	item->_lastValidatedRevision = self.lastValidatedRevision;
	
	item->_validatesAutomatically = self.validatesAutomatically;
	item->_required = self.required;
	item->_hidden = self.hidden;
	item->_enabled = self.enabled;
	
    item->_selectable = self.selectable;
    item->_selected = self.selected;
    
	for(CItem *subitem in self.subitems) {
		CItem *subitemCopy = [subitem copy];
		[item addSubitem:subitemCopy];
	}
	
	return item;
}

+ (CItem*)newItem {
	return [self newItemWithDictionary:nil];
}

+ (CItem*)newItemWithTitle:(NSString*)title key:(NSString*)key value:(id)value {
	return [self newItemWithDictionary:@{@"title": title,
											  @"key": key,
											  @"value": value}];
}

#pragma mark - Activation

// Behavior provided by subclasses
- (void)activate {
	NSAssert1(self.active == NO, @"Attempt to activate item that is already active:%@", self);
	self.active = YES;
	BSELF;
	self.valueObserver = [CObserver newObserverWithKeyPath:@"value" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		bself.needsValidation = YES;
	}];
}

- (void)activateAll {
	for(CItem *subitem in self.subitems) {
		[subitem activateAll];
	}
	[self activate];
}

// Behavior provided by subclasses
- (void)deactivate {
	NSAssert1(self.active == YES, @"Attempt to deactivate item that is already inactive:%@", self);
	self.active = NO;
	[self disarmValidate];
	self.valueObserver = nil;
}

- (void)deactivateAll {
	for(CItem *subitem in self.subitems) {
		[subitem deactivateAll];
	}
	[self deactivate];
}

#pragma mark - Utilities

- (void)enumerateItemsToRootUsingBlock:(void (^)(CItem *item, BOOL *stop))block {
	CItem *item = self;
	BOOL stop = NO;
	while(!stop && item != nil) {
		block(item, &stop);
		item = item.superitem;
	};
}

- (CItem*)rootItem {
	__block CItem *result = nil;
	
	[self enumerateItemsToRootUsingBlock:^(CItem *item, BOOL *stop) {
		result = item;
	}];
	
	return result;
}

- (NSUInteger)indexOfSubitemForKey:(NSString*)key {
	NSUInteger result = NSNotFound;
	
	NSUInteger rowIndex = 0;
	for(CItem *subitem in self.subitems) {
		if([key isEqualToString:subitem.key]) {
			result = rowIndex;
			break;
		}
		rowIndex++;
	}
	
	return result;
}

- (CItem*)subitemForKey:(NSString*)key {
	id result = nil;

	NSUInteger rowIndex = [self indexOfSubitemForKey:key];
	if(rowIndex != NSNotFound) {
		result = (self.subitems)[rowIndex];
	}
	
	return result;
}

- (NSString*)keyPathRelativeToItem:(CItem*)ancestorItem {
	NSMutableArray *components = [NSMutableArray array];
	[self enumerateItemsToRootUsingBlock:^(CItem *item, BOOL *stop) {
		if([item.key isEqualToString:ancestorItem.key]) {
			*stop = YES;
		} else {
			[components insertObject:item.key atIndex:0];
		}
	}];
	NSString *keyPath = StringByJoiningNonemptyStringsWithString(components, @".");
	return keyPath;
}

- (NSString*)keyPath {
	return [self keyPathRelativeToItem:nil];
}

- (NSIndexSet *)indexesOfSelectedSubitems {
    return [self.subitems indexesOfObjectsPassingTest:^BOOL(CItem *subitem, NSUInteger idx, BOOL *stop) {
        return subitem.selected;
    }];
}

- (NSArray *)selectedSubitems {
    return [self.subitems objectsAtIndexes:self.indexesOfSelectedSubitems];
}

#pragma mark - Debugging

- (NSArray*)descriptionStringsCompact:(BOOL)compact {
	return @[[self formatValueForKey:@"title" compact:compact],
             [self formatValueForKey:@"key" compact:compact],
             [self formatValueForKey:@"analyticsName" compact:compact],
             [self formatValueForKey:@"value" compact:compact],
             [self formatBoolValueForKey:@"required" compact:compact hidingIf:NO],
             [self formatBoolValueForKey:@"hidden" compact:compact hidingIf:NO],
             [self formatValueForKey:@"currentRevision" compact:compact],
             [self formatValueForKey:@"lastValidatedRevision" compact:compact],
             [self formatValueForKey:@"error" compact:compact],
             [self formatCountForKey:@"subitems" hidingIfZero:YES],
             [self formatValueForKey:@"subitemErrors" compact:compact],
             [self formatBoolValueForKey:@"validatesAutomatically" compact:compact hidingIf:NO],
             [self formatBoolValueForKey:@"enabled" compact:compact hidingIf:YES],
             [self formatBoolValueForKey:@"selectable" compact:compact hidingIf:NO],
             [self formatBoolValueForKey:@"selected" compact:compact hidingIf:NO]];
}

- (NSString*)descriptionCompact:(BOOL)compact {
	NSString *content = StringByJoiningNonemptyStringsWithString([self descriptionStringsCompact:compact], @" ");
	return [NSString stringWithFormat:@"%@ = { %@ }", [super description], content];
}

- (NSString*)description {
	return [self descriptionCompact:NO];
}

- (void)printHierarchy:(CItem*)item indent:(NSString*)indent level:(int)level {
#ifdef DEBUG
	NSString *activePrefix = self.active ? @"! " : @"  ";
	NSString *statePrefix;
	switch(item.state) {
		case CItemStateNeedsValidation:
			statePrefix = @"?    ";
			break;
		case CItemStateValidating:
			statePrefix = @">>>>>";
			break;
		case CItemStateValid:
			statePrefix = @"OK   ";
			break;
		case CItemStateInvalid:
			statePrefix = @"ERROR";
			break;
        default:
            statePrefix = @"?????";
            break;
	}
	NSString *newPrefix = item.fresh ? @"FRS" : @"   ";
	NSString *reqPrefix = item.required ? @"REQ" : @"   ";

	NSArray *prefixes = @[activePrefix, statePrefix, newPrefix, reqPrefix];
	NSString *prefix = [NSString stringWithComponents:prefixes separator:@" "];
	CLogPrint(@"%@%@%3d %@", prefix, indent, level, [item descriptionCompact:YES]);
	if(item.subitems.count > 0) {
		indent = [indent stringByAppendingString:@"  |"];
		for(CItem *subitem in item.subitems) {
			[self printHierarchy:subitem indent:indent level:level+1];
		}
	}
#endif
}

- (void)printHierarchy {
	CLogPrint(@"");
	[self printHierarchy:self indent:@"" level:0];
}

#pragma mark - KVC for subitems

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    CItem *subitem = [self subitemForKey:key];
    if(subitem == nil) {
        [super setValue:value forUndefinedKey:key];
    } else {
        [subitem setValue:value forKey:key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
	id value = nil;
	
	value = [self subitemForKey:key];
	if(value == nil) {
		value = [super valueForUndefinedKey:key];
	}
	
	return value;
}

#pragma mark - @property superitem

+ (BOOL)automaticallyNotifiesObserversOfSuperitem {
	return NO;
}

- (CItem*)superitem {
	return _superitem;
}

- (void)setSuperitem:(CItem *)superitem {
	if(_superitem != superitem) {
		[self willChangeValueForKey:@"superitem"];
		_superitem = superitem;
		[self didChangeValueForKey:@"superitem"];
	}
}

#pragma mark - @property subitems

+ (BOOL)automaticallyNotifiesObserversOfSubitems {
	return NO;
}

+ (BOOL)automaticallyNotifiesObserversOfSubitems_ {
	return NO;
}

- (NSMutableArray*)subitems {
	return [self mutableArrayValueForKey:@"subitems_"];
}

- (NSUInteger)countOfSubitems_ {
	return subitems__.count;
}

- (CItem*)objectInSubitems_AtIndex:(NSUInteger)index {
	return (CItem*)subitems__[index];
}

- (void)insertObject:(CItem *)item inSubitems_AtIndex:(NSUInteger)index {
	[self insertSubitems_:@[item] atIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)insertSubitems_:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"subitems"];
	[subitems__ insertObjects:array atIndexes:indexes];
    BSELF;
	[array enumerateObjectsUsingBlock:^(CItem *item, NSUInteger idx, BOOL *stop) {
		item.superitem = self;
		if(bself.active) {
			[item activateAll];
		}
	}];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"subitems"];
	[self setNeedsValidation:YES];
}

- (void)removeObjectFromSubitems_AtIndex:(NSUInteger)index {
	[self removeSubitems_AtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeSubitems_AtIndexes:(NSIndexSet *)indexes {
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"subitems"];
    BSELF;
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		CItem *item = self->subitems__[idx];
		if(bself.active) {
			[item deactivateAll];
		}
		item.superitem = nil;
	}];
	[subitems__ removeObjectsAtIndexes:indexes];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"subitems"];
	[self setNeedsValidation:YES];
}

#pragma mark - hierarchy manipulation

- (void)addSubitem:(CItem*)item {
	[self.subitems addObject:item];
}

- (void)addSubitems:(NSArray*)items {
	[self.subitems addObjectsFromArray:items];
}

- (void)insertSubitem:(CItem *)item atIndex:(NSUInteger)index {
    [self.subitems insertObject:item atIndex:index];
}

- (void)removeFromSuperitem {
	if(self.superitem != nil) {
		NSUInteger index = [self.superitem.subitems indexOfObject:self];
		[self.superitem.subitems removeObjectAtIndex:index];
	}
}

#pragma mark - @property state

+ (NSSet*)keyPathsForValuesAffectingState {
	return [NSSet setWithObjects:@"needsValidation", @"validating", @"error", @"subitemErrors", nil];
}

- (CItemState)state {
	CItemState result = CItemStateValid;
	
	if(self.validating) {
		result = CItemStateValidating;
	} else {
		if(self.needsValidation) {
			result = CItemStateNeedsValidation;
		} else if(self.error != nil || self.subitemErrors.count > 0) {
			result = CItemStateInvalid;
		}
	}
	
	return result;
}

#pragma mark - @property dependentKeyPaths

- (NSMutableArray*)dependentKeyPaths {
	return (self.dict)[@"dependentKeyPaths"];
}

- (void)setDependentKeyPaths:(NSMutableArray *)dependentKeyPaths {
	(self.dict)[@"dependentKeyPaths"] = [dependentKeyPaths mutableCopy];
}

#pragma mark - @property mustEqualKeyPath

- (NSString*)mustEqualKeyPath {
	return (self.dict)[@"mustEqualKeyPath"];
}

- (void)setMustEqualKeyPath:(NSString *)keyPath {
	(self.dict)[@"mustEqualKeyPath"] = keyPath;
}

#pragma mark - @property needsValidation

+ (NSSet*)keyPathsForValuesAffectingNeedsValidation {
	return [NSSet setWithObjects:@"currentRevision", @"lastValidatedRevision", nil];
}

- (BOOL)needsValidation {
	return self.currentRevision != self.lastValidatedRevision;
}

#pragma mark - @property fresh

+ (NSSet*)keyPathsForValuesAffectingFresh {
	return [NSSet setWithObjects:@"lastValidatedRevision", nil];
}

- (BOOL)isFresh {
	return self.lastValidatedRevision <= 1;
}

- (void)setFresh:(BOOL)fresh {
	if(fresh) {
		self.currentRevision = 1;
		self.lastValidatedRevision = 0;
	} else {
		[self syncLastValidatedRevision];
	}
}

- (void)setNeedsValidation:(BOOL)needsValidation {
	if(needsValidation) {
		[self incrementCurrentRevision];
		if(self.superitem == nil) {
			[self armValidateIfNeeded];
		} else {
			self.superitem.needsValidation = YES;
		}
		for(NSString *keyPath in self.dependentKeyPaths) {
			CItem *otherItem = [self.rootItem valueForKeyPath:keyPath];
//            if(!otherItem.fresh) {
                otherItem.needsValidation = YES;
//            }
		}
		
	} else {
		[self syncLastValidatedRevision];
	}
}

#pragma mark - @property currentRevision

+ (BOOL)automaticallyNotifiesObserversOfCurrentRevision {
	return NO;
}

- (NSUInteger)currentRevision {
	return _currentRevision;
}

- (void)setCurrentRevision:(NSUInteger)currentRevision {
	if(_currentRevision != currentRevision) {
		[self willChangeValueForKey:@"currentRevision"];
		_currentRevision = currentRevision;
		[self didChangeValueForKey:@"currentRevision"];
	}
}

- (void)incrementCurrentRevision {
	self.currentRevision = _currentRevision + 1;
}

#pragma mark - @property lastValidatedRevision

+ (BOOL)automaticallyNotifiesObserversOfLastValidatedRevision {
	return NO;
}

- (NSUInteger)lastValidatedRevision {
	return _lastValidatedRevision;
}

- (void)setLastValidatedRevision:(NSUInteger)lastValidatedRevision {
	if(_lastValidatedRevision != lastValidatedRevision) {
		[self willChangeValueForKey:@"lastValidatedRevision"];
		_lastValidatedRevision = lastValidatedRevision;
		[self didChangeValueForKey:@"lastValidatedRevision"];
	}
}

- (void)syncLastValidatedRevision {
	self.lastValidatedRevision = _currentRevision;
}

#pragma mark - @property validationsInProgress

+ (BOOL)automaticallyNotifiesObserversOfValidationsInProgress {
	return NO;
}

- (NSUInteger)validationsInProgress {
	return _validationsInProgress;
}

- (void)incrementValidationsInProgress {
	[self willChangeValueForKey:@"validationsInProgress"];
	_validationsInProgress++;
	if(_validationsInProgress == 1) {
		self.validating = YES;
	}
	[self.superitem incrementValidationsInProgress];
	[self didChangeValueForKey:@"validationsInProgress"];
}

- (void)decrementValidationsInProgress {
	NSAssert(_validationsInProgress > 0, @"validationsInProgress cannot be decremented further.");
	[self willChangeValueForKey:@"validationsInProgress"];
	_validationsInProgress--;
	if(_validationsInProgress == 0) {
		self.validating = NO;
	}
	[self.superitem decrementValidationsInProgress];
	[self didChangeValueForKey:@"validationsInProgress"];
}

#pragma mark - @property validating

+ (BOOL)automaticallyNotifiesObserversOfValidating {
	return NO;
}

- (BOOL)validating {
	return _validating;
}

- (void)setValidating:(BOOL)validating {
	if(_validating != validating) {
		[self willChangeValueForKey:@"validating"];
		_validating = validating;
		[self didChangeValueForKey:@"validating"];
	}
}

#pragma mark - @property editing

+ (BOOL)automaticallyNotifiesObserversOfEditing {
	return NO;
}

- (BOOL)isEditing {
	return _editing;
}

- (void)setEditing:(BOOL)editing {
	if(_editing != editing) {
		[self willChangeValueForKey:@"editing"];
		_editing = editing;
		[self didChangeValueForKey:@"editing"];
	}
}

#pragma mark - @property title

- (NSString*)title {
	return Denull((self.dict)[@"title"]);
}

- (void)setTitle:(NSString *)title {
	(self.dict)[@"title"] = Ennull(title);
}

#pragma mark - @property key

- (NSString*)key {
	return Denull((self.dict)[@"key"]);
}

- (void)setKey:(NSString *)key {
	(self.dict)[@"key"] = Ennull(key);
}

#pragma mark - @property analyticsName

- (NSString*)analyticsName {
	return Denull((self.dict)[@"analyticsName"]);
}

- (void)setAnalyticsName:(NSString *)analyticsName {
	(self.dict)[@"analyticsName"] = Ennull(analyticsName);
}

#pragma mark - @property value

+ (BOOL)automaticallyNotifiesObserversOfValue {
	return NO;
}

- (id)denullValue:(id)value {
	return Denull(value);
}

- (id)ennullValue:(id)value {
	return Ennull(value);
}

- (id)value {
	id value = [self denullValue:(self.dict)[@"value"]];
	if(value == nil) {
		value = self.defaultValue;
	}
	return value;
}

- (void)setValue:(id)newValue {
	newValue = [self ennullValue:newValue];
	id oldValue = [self ennullValue:(self.dict)[@"value"]];
	if(!Same(oldValue, newValue)) {
		[self willChangeValueForKey:@"value"];
		(self.dict)[@"value"] = newValue;
		[self didChangeValueForKey:@"value"];
	}
}

#pragma mark - @property defaultValue

+ (BOOL)automaticallyNotifiesObserversOfDefaultValue {
	return NO;
}

- (id)defaultValue {
	return [self denullValue:(self.dict)[@"defaultValue"]];
}

- (void)setDefaultValue:(id)newDefaultValue {
	newDefaultValue = [self ennullValue:newDefaultValue];
	id oldDefaultValue = [self ennullValue:(self.dict)[@"defaultValue"]];
	if(!Same(oldDefaultValue, newDefaultValue)) {
		id oldValue = [self denullValue:(self.dict)[@"value"]];
		[self willChangeValueForKey:@"defaultValue"];
		if(oldValue != nil) {
			[self willChangeValueForKey:@"value"];
		}
		(self.dict)[@"defaultValue"] = newDefaultValue;
		if(oldValue != nil) {
			[self didChangeValueForKey:@"value"];
		}
		[self didChangeValueForKey:@"defaultValue"];
	}
}

#pragma mark - @property dummyValues

+ (BOOL)automaticallyNotifiesObserversOfDummyValues {
    return NO;
}

- (NSArray *)dummyValues {
    id values = (self.dict)[@"dummyValues"];
    if(values == nil || values == [NSNull null]) values = [NSArray new];
    return values;
}

- (void)setDummyValues:(NSArray *)newDummyValues {
	newDummyValues = [self ennullValue:newDummyValues];
	NSArray *oldDummyValues = [self ennullValue:(self.dict)[@"dummyValues"]];
	if(!Same(oldDummyValues, newDummyValues)) {
		[self willChangeValueForKey:@"dummyValues"];
		(self.dict)[@"dummyValues"] = newDummyValues;
		[self didChangeValueForKey:@"dummyValues"];
	}
}

- (id)transformDummyValue:(id)dummyValue {
    if([dummyValue isKindOfClass:[NSString class]]) {
        NSString *originalDummyValue = (NSString *)dummyValue;
        NSMutableString *modifiedDummyValue = [originalDummyValue mutableCopy];
        for(NSUInteger i = 0; i < originalDummyValue.length; i++) {
            NSRange r = NSMakeRange(i, 1);
            NSString *c = [originalDummyValue substringWithRange:r];
            if([c isEqualToString:@"#"]) {
                NSString *s = [NSString stringWithFormat:@"%d", (int)arciem::random_range(0, 10)];
                [modifiedDummyValue replaceCharactersInRange:r withString:s];
            }
        }
        dummyValue = [modifiedDummyValue copy];
    }
    return dummyValue;
}

- (void)setValuesFromDummyValuesHierarchical:(BOOL)hierarchical {
    if(self.dummyValues.count > 0) {
        id dummyValue = self.dummyValues[0];
        self.value = [self transformDummyValue:dummyValue];
    }
    if(hierarchical) {
        for(CItem *subitem in self.subitems) {
            [subitem setValuesFromDummyValuesHierarchical:YES];
        }
    }
}


#pragma mark - @property error

+ (BOOL)automaticallyNotifiesObserversOfError {
	return NO;
}

- (NSError*)error {
	return _error;
}

- (void)setError:(NSError *)error {
	if(_error != error) {
		[self willChangeValueForKey:@"error"];
		_error = error;
		[self didChangeValueForKey:@"error"];
	}
}

#pragma mark - @property empty

- (BOOL)isEmpty {
	return self.value == nil;
}

#pragma mark - @property valid

- (BOOL)isValid {
	return self.state == CItemStateValid;
}

#pragma mark - Validation

// may be overridden
- (NSError*)validateValue {
	[self disarmValidate];
    self.needsValidation = NO;

	NSError *error = nil;
	
	if(self.required && self.empty) {
		error = [NSError errorWithDomain:CItemErrorDomain code:CItemErrorRequired localizedFormat:@"%@ is required.", self.title];
	}
	
	if(error == nil) {
		if(!IsEmptyString(self.mustEqualKeyPath)) {
			CItem *otherItem = [self.rootItem valueForKeyPath:self.mustEqualKeyPath];
			if(!Same(self.value, otherItem.value)) {
				error = [NSError errorWithDomain:CItemErrorDomain code:CItemErrorNotEqualToOtherItem localizedFormat:@"Must be the same as %@.", otherItem.title];
			}
		}
	}
	return error;
}

// may be overridden
- (void)validateWithCompletion:(void (^)(NSError *error))completion {
	NSError *error = [self validateValue];
	completion(error);
}

- (void)addSubitemError:(NSError*)error {
	if(error != nil) {
		if(self.subitemErrors == nil) {
			self.subitemErrors = [NSMutableArray array];
		}
		
		[self.subitemErrors addObject:error];
		
		[self.superitem addSubitemError:error];
	}
}

- (void)validateSubtree {
	if(self.needsValidation) {
//		self.needsValidation = NO;
		[self incrementValidationsInProgress];
		self.error = nil;
		self.subitemErrors = nil;
		for(CItem *subitem in self.subitems) {
			[subitem validateSubtree];
		}
		BSELF;
		[self validateWithCompletion:^(NSError *error) {
			if(error != nil) {
				bself.error = error;
				[bself.superitem addSubitemError:error];
			}
			[bself decrementValidationsInProgress];
			
			if(bself.printHierarchyAfterValidate) {
				[bself printHierarchy];
			}
		}];
	} else {
		[self.superitem addSubitemError:self.error];
		for(NSError *subitemError in self.subitemErrors) {
			[self.superitem addSubitemError:subitemError];
		}
	}
}

- (void)validateHierarchy {
//	[self disarmValidate];
	
	if(!self.validating) {
		[self validateSubtree];
	}
}

#pragma mark - Automatic Validation

- (void)disarmValidate {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(validateHierarchy) object:nil];
}

- (void)armValidateIfNeeded {
	[self disarmValidate];
	if(self.active) {
		if(self.validatesAutomatically) {
			if(self.needsValidation) {
				[self performSelector:@selector(validateHierarchy) withObject:nil afterDelay:0.1];
			}
		}
	}
}

#pragma mark - @property hidden

+ (BOOL)automaticallyNotifiesObserversOfHidden {
	return NO;
}

- (BOOL)isHidden {
	return _hidden;
}

- (void)setHidden:(BOOL)hidden {
	if(_hidden != hidden) {
		[self willChangeValueForKey:@"hidden"];
		_hidden = hidden;
		[self didChangeValueForKey:@"hidden"];
	}
}

- (NSArray*)visibleSubitems {
	NSMutableArray *result = [NSMutableArray array];
	
	for(CItem *subitem in self.subitems) {
		if(!subitem.hidden) {
			[result addObject:subitem];
		}
	}
	
	return [result copy];
}

#pragma mark - @property enabled

+ (BOOL)automaticallyNotifiesObserversOfEnabled {
	return NO;
}

- (BOOL)isEnabled {
	return _enabled;
}

- (void)setEnabled:(BOOL)enabled {
	if(_enabled != enabled) {
		[self willChangeValueForKey:@"enabled"];
		_enabled = enabled;
		[self didChangeValueForKey:@"enabled"];
	}
}

#pragma mark - @propery selectable

+ (BOOL)automaticallyNotifiesObserversOfSelectable {
    return NO;
}

- (BOOL)isSelectable {
    return _selectable;
}

- (void)setSelectable:(BOOL)selectable {
    if(_selectable != selectable) {
        [self willChangeValueForKey:@"selectable"];
        _selectable = selectable;
        [self didChangeValueForKey:@"selectable"];
    }
}

#pragma mark - @propery selected

+ (BOOL)automaticallyNotifiesObserversOfSelected {
    return NO;
}

- (BOOL)isSelected {
    return _selected;
}

- (void)setSelected:(BOOL)selected {
    if(_selected != selected) {
        [self willChangeValueForKey:@"selected"];
        _selected = selected;
        [self didChangeValueForKey:@"selected"];
    }
}

#pragma mark - @property jsonRepresentation

- (NSString*)jsonRepresentation {
	NSMutableDictionary *outDict = [NSMutableDictionary dictionary];
	
	for(NSString *key in self.dict) {
		id obj = (self.dict)[key];
		if([obj respondsToSelector:@selector(jsonRepresentation)]) {
			obj = [obj jsonRepresentation];
		}
		outDict[key] = obj;
	}
	NSError *error = nil;
	NSData *outData = [NSJSONSerialization dataWithJSONObject:outDict options:0 error:&error];
	NSAssert2(error == nil, @"Creating JSON Representation of %@: %@", self, error);
	NSString *outString = [NSString stringWithData:outData encoding:NSUTF8StringEncoding];
	return outString;
}

#pragma mark - Selection

// Behavior provided by subclasses
- (BOOL)didSelect {
	return YES;
}

#pragma mark - Table Support

- (NSArray*)tableRowItems {
	NSAssert1(false, @"No table row items defined for:%@", self);
	return nil;
}

@end
