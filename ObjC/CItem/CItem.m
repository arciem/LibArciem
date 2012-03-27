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

NSString* const CItemErrorDomain = @"CItemErrorDomain";

@interface CItem ()
{
	NSMutableArray* subitems__;
}

@property (weak, readwrite, nonatomic) CItem* superitem;
@property (readonly, nonatomic) NSMutableArray* subitems_;
@property (readonly, nonatomic) NSUInteger currentRevision;
@property (readonly, nonatomic) NSUInteger lastValidatedRevision;
@property (readonly, nonatomic) NSUInteger validationsInProgress;
@property (strong, nonatomic) NSMutableArray* subitemErrors;
@property (readwrite, nonatomic, setter = setValidating:) BOOL isValidating;
@property (strong, nonatomic) CObserver* valueObserver;
@property (readwrite, nonatomic) BOOL isActive;

@end

@implementation CItem

@synthesize dict = dict_;
@synthesize error = error_;
@synthesize subitemErrors = subitemErrors_;

@synthesize superitem = superitem_;

@synthesize currentRevision = currentRevision_;
@synthesize lastValidatedRevision = lastValidatedRevision_;

@synthesize validatesAutomatically = validatesAutomatically_;
@synthesize isRequired = isRequired_;
@synthesize isHidden = isHidden_;
@synthesize isDisabled = isDisabled_;

@synthesize isActive = isActive_;
@synthesize isValidating = isValidating_;
@synthesize validationsInProgress = validationsInProgress_;
@synthesize valueObserver = valueObserver_;

@synthesize printHierarchyAfterValidate = printHierarchyAfterValidate_;

@dynamic subitems_;

#pragma mark - Lifecycle

+ (void)initialize
{
//	CLogSetTagActive(@"C_ITEM", YES);
}

- (void)setup
{
	// behavior provided by subclasses
}

- (id)initWithDictionary:(NSDictionary*)dict
{
	NSMutableDictionary* mutableDict = nil;
	if(dict == nil) {
		mutableDict = [NSMutableDictionary dictionary];
	} else {
		mutableDict = [dict mutableCopy];
	}
	
	NSString* type = [mutableDict objectForKey:@"type"];
	if(!IsEmptyString(type)) {
		NSString* firstChar = [[type substringToIndex:1] uppercaseString];
		NSString* remainingChars = [type substringFromIndex:1];
		NSString* className = [NSString stringWithFormat:@"C%@%@Item", firstChar, remainingChars];
		self = (CItem*)ClassAlloc(className);
		NSAssert1(self != nil, @"Attempt to instantiate undefined class:%@", className);
	}
	[mutableDict removeObjectForKey:@"type"];

	if(self = [super init]) {
		dict_ = mutableDict;
		[self incrementCurrentRevision];
		isRequired_ = [[dict_ objectForKey:@"required"] boolValue];
		isDisabled_ = [[dict_ objectForKey:@"disabled"] boolValue];
		isHidden_ = [[dict_ objectForKey:@"hidden"] boolValue];
		validatesAutomatically_ = [[dict_ objectForKey:@"validatesAutomatically"] boolValue];
		
		NSArray* subdicts = [dict_ objectForKey:@"subitems"];
		subitems__ = [NSMutableArray array];
		for(NSDictionary* subdict in subdicts) {
			[self addSubitem:[CItem itemWithDictionary:subdict]];
		}
		[dict_ removeObjectForKey:@"subitems"];
		[self setup];
		CLogTrace(@"C_ITEM", @"%@ initWithDictionary", self);
	}
	return self;
}

- (id)initWithJSONRepresentation:(NSString *)json
{
	NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
	NSError* error = nil;
	NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSAssert1(error == nil, @"Parsing JSON:%@", error);
	if(self = [self initWithDictionary:dict]) {
		
	}
	return self;
}

- (id)init
{
	if(self = [self initWithDictionary:nil]) {
	}
	
	return self;
}

- (void)dealloc
{
	CLogTrace(@"C_ITEM", @"%@ dealloc", [self formatObjectWithValues:nil]);
	@autoreleasepool {
		[self.subitems removeAllObjects];
		subitems__ = nil;
	}
}

+ (CItem*)itemWithDictionary:(NSDictionary*)dict
{
	return [[self alloc] initWithDictionary:dict];
}

+ (CItem*)itemWithJSONRepresentation:(NSString*)json
{
	return [[self alloc] initWithJSONRepresentation:json];
}

- (id)copyWithZone:(NSZone *)zone
{
	CItem* item = [[[self class] allocWithZone:zone] init];
	
	item->dict_ = [self.dict mutableCopy];
	item->error_ = [self.error copy];
	item->subitemErrors_ = [self.subitemErrors mutableCopy];
	
	item->currentRevision_ = self.currentRevision;
	item->lastValidatedRevision_ = self.lastValidatedRevision;
	
	item->validatesAutomatically_ = self.validatesAutomatically;
	item->isRequired_ = self.isRequired;
	item->isHidden_ = self.isHidden;
	item->isDisabled_ = self.isDisabled;
	
	for(CItem* subitem in self.subitems) {
		CItem* subitemCopy = [subitem copy];
		[item addSubitem:subitemCopy];
	}
	
	return item;
}

+ (CItem*)item
{
	return [self itemWithDictionary:nil];
}

+ (CItem*)itemWithTitle:(NSString*)title key:(NSString*)key value:(id)value
{
	return [self itemWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
											  title, @"title",
											  key, @"key",
											  value, @"value",
											  nil]];
}

#pragma mark - Activation

// Behavior provided by subclasses
- (void)activate
{
	NSAssert1(self.isActive == NO, @"Attempt to activate item that is already active:%@", self);
	self.isActive = YES;
	__weak CItem* self__ = self;
	self.valueObserver = [CObserver observerWithKeyPath:@"value" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		self__.needsValidation = YES;
	}];
}

- (void)activateAll
{
	for(CItem* subitem in self.subitems) {
		[subitem activateAll];
	}
	[self activate];
}

// Behavior provided by subclasses
- (void)deactivate
{
	NSAssert1(self.isActive == YES, @"Attempt to deactivate item that is already inactive:%@", self);
	self.isActive = NO;
	[self disarmValidate];
	self.valueObserver = nil;
}

- (void)deactivateAll
{
	for(CItem* subitem in self.subitems) {
		[subitem deactivateAll];
	}
	[self deactivate];
}

#pragma mark - Utilities

- (void)enumerateItemsToRootUsingBlock:(void (^)(CItem* item, BOOL* stop))block
{
	CItem* item = self;
	BOOL stop = NO;
	while(!stop && item != nil) {
		block(item, &stop);
		item = item.superitem;
	};
}

- (CItem*)rootItem
{
	__block CItem* result = nil;
	
	[self enumerateItemsToRootUsingBlock:^(CItem *item, BOOL *stop) {
		result = item;
	}];
	
	return result;
}

- (NSUInteger)indexOfSubitemForKey:(NSString*)key
{
	NSUInteger result = NSNotFound;
	
	NSUInteger rowIndex = 0;
	for(CItem* subitem in self.subitems) {
		if([key isEqualToString:subitem.key]) {
			result = rowIndex;
			break;
		}
		rowIndex++;
	}
	
	return result;
}

- (CItem*)subitemForKey:(NSString*)key
{
	id result = nil;

	NSUInteger rowIndex = [self indexOfSubitemForKey:key];
	if(rowIndex != NSNotFound) {
		result = [self.subitems objectAtIndex:rowIndex];
	}
	
	return result;
}

- (NSString*)keyPathRelativeToItem:(CItem*)ancestorItem
{
	NSMutableArray* components = [NSMutableArray array];
	[self enumerateItemsToRootUsingBlock:^(CItem *item, BOOL *stop) {
		if([item.key isEqualToString:ancestorItem.key]) {
			*stop = YES;
		} else {
			[components insertObject:item.key atIndex:0];
		}
	}];
	NSString* keyPath = StringByJoiningNonemptyStringsWithString(components, @".");
	return keyPath;
}

- (NSString*)keyPath
{
	return [self keyPathRelativeToItem:nil];
}

#pragma mark - Debugging

- (NSArray*)descriptionStringsCompact:(BOOL)compact
{
	return [NSArray arrayWithObjects:
			[self formatValueForKey:@"title" compact:compact],
			[self formatValueForKey:@"key" compact:compact],
			[self formatValueForKey:@"value" compact:compact],
			[self formatBoolValueForKey:@"isRequired" compact:compact hidingIf:NO],
			[self formatValueForKey:@"currentRevision" compact:compact],
			[self formatValueForKey:@"lastValidatedRevision" compact:compact],
			[self formatValueForKey:@"error" compact:compact],
			[self formatValueForKey:@"subitemErrors" compact:compact],
			[self formatBoolValueForKey:@"validatesAutomatically" compact:compact hidingIf:NO],
			[self formatBoolValueForKey:@"isDisabled" compact:compact hidingIf:NO],
			nil];
}

- (NSString*)descriptionCompact:(BOOL)compact
{
	NSString* content = StringByJoiningNonemptyStringsWithString([self descriptionStringsCompact:compact], @" ");
	return [NSString stringWithFormat:@"%@ = { %@ }", [super description], content];
}

- (NSString*)description
{
	return [self descriptionCompact:NO];
}

- (void)printHierarchy:(CItem*)item indent:(NSString*)indent level:(int)level
{
	NSString* activePrefix = self.isActive ? @"! " : @"  ";
	NSString* statePrefix;
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
	}
	NSString* newPrefix = item.isNew ? @"NEW" : @"   ";
	NSString* reqPrefix = item.isRequired ? @"REQ" : @"   ";
	
	NSArray* prefixes = [NSArray arrayWithObjects:activePrefix, statePrefix, newPrefix, reqPrefix, nil];
	NSString* prefix = [NSString stringWithComponents:prefixes separator:@" "];
	CLogPrint(@"%@%@%3d %@", prefix, indent, level, [item descriptionCompact:YES]);
	if(item.subitems.count > 0) {
		indent = [indent stringByAppendingString:@"  |"];
		for(CItem* subitem in item.subitems) {
			[self printHierarchy:subitem indent:indent level:level+1];
		}
	}
}

- (void)printHierarchy
{
	CLogPrint(@"");
	[self printHierarchy:self indent:@"" level:0];
}

#pragma mark - KVC for subitems

- (id)valueForUndefinedKey:(NSString *)key
{
	id value = nil;
	
	value = [self subitemForKey:key];
	if(value == nil) {
		value = [super valueForUndefinedKey:key];
	}
	
	return value;
}

#pragma mark - @property superitem

+ (BOOL)automaticallyNotifiesObserversOfSuperitem
{
	return NO;
}

- (CItem*)superitem
{
	return superitem_;
}

- (void)setSuperitem:(CItem *)superitem
{
	if(superitem_ != superitem) {
		[self willChangeValueForKey:@"superitem"];
		superitem_ = superitem;
		[self didChangeValueForKey:@"superitem"];
	}
}

#pragma mark - @property subitems

+ (BOOL)automaticallyNotifiesObserversOfSubitems
{
	return NO;
}

+ (BOOL)automaticallyNotifiesObserversOfSubitems_
{
	return NO;
}

- (NSMutableArray*)subitems
{
	return [self mutableArrayValueForKey:@"subitems_"];
}

- (NSUInteger)countOfSubitems_
{
	return subitems__.count;
}

- (CItem*)objectInSubitems_AtIndex:(NSUInteger)index
{
	return (CItem*)[subitems__ objectAtIndex:index];
}

- (void)insertObject:(CItem *)item inSubitems_AtIndex:(NSUInteger)index
{
	[self insertSubitems_:[NSArray arrayWithObject:item] atIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)insertSubitems_:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"subitems"];
	[subitems__ insertObjects:array atIndexes:indexes];
	[array enumerateObjectsUsingBlock:^(CItem* item, NSUInteger idx, BOOL *stop) {
		item.superitem = self;
		if(self.isActive) {
			[item activateAll];
		}
	}];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"subitems"];
	[self setNeedsValidation:YES];
}

- (void)removeObjectFromSubitems_AtIndex:(NSUInteger)index
{
	[self removeSubitems_AtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeSubitems_AtIndexes:(NSIndexSet *)indexes
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"subitems"];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		CItem* item = [subitems__ objectAtIndex:idx];
		if(self.isActive) {
			[item deactivateAll];
		}
		item.superitem = nil;
	}];
	[subitems__ removeObjectsAtIndexes:indexes];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"subitems"];
	[self setNeedsValidation:YES];
}

#pragma mark - hierarchy manipulation

- (void)addSubitem:(CItem*)item
{
	[self.subitems addObject:item];
}

- (void)addSubitems:(NSArray*)items
{
	[self.subitems addObjectsFromArray:items];
}

- (void)removeFromSuperitem
{
	if(self.superitem != nil) {
		NSUInteger index = [self.superitem.subitems indexOfObject:self];
		[self.superitem.subitems removeObjectAtIndex:index];
	}
}

#pragma mark - @property state

+ (NSSet*)keyPathsForValuesAffectingState
{
	return [NSSet setWithObjects:@"needsValidation", @"isValidating", @"error", @"subitemErrors", nil];
}

- (CItemState)state
{
	CItemState result = CItemStateValid;
	
	if(self.isValidating) {
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

- (NSMutableArray*)dependentKeyPaths
{
	return [self.dict objectForKey:@"dependentKeyPaths"];
}

- (void)setDependentKeyPaths:(NSMutableArray *)dependentKeyPaths
{
	[self.dict setObject:[dependentKeyPaths mutableCopy] forKey:@"dependentKeyPaths"];
}

#pragma mark - @property mustEqualKeyPath

- (NSString*)mustEqualKeyPath
{
	return [self.dict objectForKey:@"mustEqualKeyPath"];
}

- (void)setMustEqualKeyPath:(NSString *)keyPath
{
	[self.dict setObject:keyPath forKey:@"mustEqualKeyPath"];
}

#pragma mark - @property needsValidation

+ (NSSet*)keyPathsForValuesAffectingNeedsValidation
{
	return [NSSet setWithObjects:@"currentRevision", @"lastValidatedRevision", nil];
}

- (BOOL)needsValidation
{
	return self.currentRevision != self.lastValidatedRevision;
}

#pragma mark - @property isNew

+ (NSSet*)keyPathsForValuesAffectingIsNew
{
	return [NSSet setWithObjects:@"lastValidatedRevision", nil];
}

- (BOOL)isNew
{
	return self.lastValidatedRevision <= 1;
}

- (void)setNeedsValidation:(BOOL)needsValidation
{
	if(needsValidation) {
		[self incrementCurrentRevision];
		if(self.superitem == nil) {
			[self armValidateIfNeeded];
		} else {
			self.superitem.needsValidation = YES;
		}
		for(NSString* keyPath in self.dependentKeyPaths) {
			CItem* otherItem = [self.rootItem valueForKeyPath:keyPath];
			otherItem.needsValidation = YES;
		}
		
	} else {
		[self syncLastValidatedRevision];
	}
}

#pragma mark - @property currentRevision

+ (BOOL)automaticallyNotifiesObserversOfCurrentRevision
{
	return NO;
}

- (NSUInteger)currentRevision
{
	return currentRevision_;
}

- (void)incrementCurrentRevision
{
	[self willChangeValueForKey:@"currentRevision"];
	currentRevision_++;
	[self didChangeValueForKey:@"currentRevision"];
}

#pragma mark - @property lastValidatedRevision

+ (BOOL)automaticallyNotifiesObserversOfLastValidatedRevision
{
	return NO;
}

- (NSUInteger)lastValidatedRevision
{
	return lastValidatedRevision_;
}

- (void)syncLastValidatedRevision
{
	if(lastValidatedRevision_ != currentRevision_) {
		[self willChangeValueForKey:@"lastValidatedRevision"];
		lastValidatedRevision_ = currentRevision_;
		[self didChangeValueForKey:@"lastValidatedRevision"];
	}
}

#pragma mark - @property validationsInProgress

+ (BOOL)automaticallyNotifiesObserversOfValidationsInProgress
{
	return NO;
}

- (NSUInteger)validationsInProgress
{
	return validationsInProgress_;
}

- (void)incrementValidationsInProgress
{
	[self willChangeValueForKey:@"validationsInProgress"];
	validationsInProgress_++;
	if(validationsInProgress_ == 1) {
		self.isValidating = YES;
	}
	[self.superitem incrementValidationsInProgress];
	[self didChangeValueForKey:@"validationsInProgress"];
}

- (void)decrementValidationsInProgress
{
	NSAssert(validationsInProgress_ > 0, @"validationsInProgress cannot be decremented further.");
	[self willChangeValueForKey:@"validationsInProgress"];
	validationsInProgress_--;
	if(validationsInProgress_ == 0) {
		self.isValidating = NO;
	}
	[self.superitem decrementValidationsInProgress];
	[self didChangeValueForKey:@"validationsInProgress"];
}

#pragma mark - @property isValidating

+ (BOOL)automaticallyNotifiesObserversOfIsValidating
{
	return NO;
}

- (BOOL)isValidating
{
	return isValidating_;
}

- (void)setValidating:(BOOL)isValidating
{
	if(isValidating_ != isValidating) {
		[self willChangeValueForKey:@"isValidating"];
		isValidating_ = isValidating;
		[self didChangeValueForKey:@"isValidating"];
	}
}

#pragma mark - @property title

- (NSString*)title
{
	return Denull([self.dict objectForKey:@"title"]);
}

- (void)setTitle:(NSString *)title
{
	[self.dict setObject:Ennull(title) forKey:@"title"];
}

#pragma mark - @property key

- (NSString*)key
{
	return Denull([self.dict objectForKey:@"key"]);
}

- (void)setKey:(NSString *)key
{
	[self.dict setObject:Ennull(key) forKey:@"key"];
}

#pragma mark - @property value

+ (BOOL)automaticallyNotifiesObserversOfValue
{
	return NO;
}

- (id)denullValue:(id)value
{
	return Denull(value);
}

- (id)ennullValue:(id)value
{
	return Ennull(value);
}

- (id)value
{
	id value = [self denullValue:[self.dict objectForKey:@"value"]];
	if(value == nil) {
		value = self.defaultValue;
	}
	return value;
}

- (void)setValue:(id)newValue
{
	newValue = [self ennullValue:newValue];
	id oldValue = [self ennullValue:[self.dict objectForKey:@"value"]];
	if(!Same(oldValue, newValue)) {
		[self willChangeValueForKey:@"value"];
		[self.dict setObject:newValue forKey:@"value"];
		[self didChangeValueForKey:@"value"];
	}
}

#pragma mark - @property defaultValue

+ (BOOL)automaticallyNotifiesObserversOfDefaultValue
{
	return NO;
}

- (id)defaultValue
{
	return [self denullValue:[self.dict objectForKey:@"defaultValue"]];
}

- (void)setDefaultValue:(id)newDefaultValue
{
	newDefaultValue = [self ennullValue:newDefaultValue];
	id oldDefaultValue = [self ennullValue:[self.dict objectForKey:@"defaultValue"]];
	if(!Same(oldDefaultValue, newDefaultValue)) {
		id oldValue = [self denullValue:[self.dict objectForKey:@"value"]];
		[self willChangeValueForKey:@"defaultValue"];
		if(oldValue != nil) {
			[self willChangeValueForKey:@"value"];
		}
		[self.dict setObject:newDefaultValue forKey:@"defaultValue"];
		if(oldValue != nil) {
			[self didChangeValueForKey:@"value"];
		}
		[self didChangeValueForKey:@"defaultValue"];
	}
}

#pragma mark - @property error

+ (BOOL)automaticallyNotifiesObserversOfError
{
	return NO;
}

- (NSError*)error
{
	return error_;
}

- (void)setError:(NSError *)error
{
	if(error_ != error) {
		[self willChangeValueForKey:@"error"];
		error_ = error;
		[self didChangeValueForKey:@"error"];
	}
}

#pragma mark - @property isEmpty

- (BOOL)isEmpty
{
	return self.value == nil;
}

#pragma mark - @property isValid

- (BOOL)isValid
{
	return self.state == CItemStateValid;
}

#pragma mark - Validation

// may be overridden
- (NSError*)validate
{
	NSError* error = nil;
	
	if(self.isRequired && self.isEmpty) {
		error = [NSError errorWithDomain:CItemErrorDomain code:CItemErrorRequired localizedFormat:@"%@ is required.", self.title];
	}
	
	if(error == nil) {
		if(!IsEmptyString(self.mustEqualKeyPath)) {
			CItem* otherItem = [self.rootItem valueForKeyPath:self.mustEqualKeyPath];
			if(!Same(self.value, otherItem.value)) {
				error = [NSError errorWithDomain:CItemErrorDomain code:CItemErrorNotEqualToOtherItem localizedFormat:@"Must be the same as %@.", otherItem.title];
			}
		}
	}
	return error;
}

// may be overridden
- (void)validateWithCompletion:(void (^)(NSError* error))completion
{
	NSError* error = [self validate];
	completion(error);
}

- (void)addSubitemError:(NSError*)error
{
	if(error != nil) {
		if(self.subitemErrors == nil) {
			self.subitemErrors = [NSMutableArray array];
		}
		
		[self.subitemErrors addObject:error];
		
		[self.superitem addSubitemError:error];
	}
}

- (void)validateSubtree
{
	if(self.needsValidation) {
		self.needsValidation = NO;
		[self incrementValidationsInProgress];
		self.error = nil;
		self.subitemErrors = nil;
		for(CItem* subitem in self.subitems) {
			[subitem validateSubtree];
		}
		__weak CItem* self__ = self;
		[self validateWithCompletion:^(NSError* error) {
			if(error != nil) {
				self__.error = error;
				[self__.superitem addSubitemError:error];
			}
			[self__ decrementValidationsInProgress];
			
			if(self__.printHierarchyAfterValidate) {
				[self__ printHierarchy];
			}
		}];
	} else {
		[self.superitem addSubitemError:self.error];
		for(NSError* subitemError in self.subitemErrors) {
			[self.superitem addSubitemError:subitemError];
		}
	}
}

- (void)validateHierarchy
{
	[self disarmValidate];
	
	if(!self.isValidating) {
#if 0
		static CObserver* observer = nil;
		__weak CItem* self__ = self;
		CObserverBlock action = ^(NSNumber* newValue, NSNumber* oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
			if(oldValue != nil && newValue.boolValue == NO) {
				[self__ printHierarchy];
				observer = nil;
			}
		};
		observer = [CObserver observerWithKeyPath:@"isValidating" ofObject:self action:action initial:action];
#endif

		[self validateSubtree];
	}
}

#pragma mark - Automatic Validation

- (void)disarmValidate
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(validateHierarchy) object:nil];
}

- (void)armValidateIfNeeded
{
	[self disarmValidate];
	if(self.isActive) {
		if(self.validatesAutomatically) {
			if(self.needsValidation) {
				[self performSelector:@selector(validateHierarchy) withObject:nil afterDelay:0.1];
			}
		}
	}
}

#pragma mark - @property isHidden

+ (BOOL)automaticallyNotifiesObserversOfIsHidden
{
	return NO;
}

- (BOOL)isHidden
{
	return isHidden_;
}

- (void)setHidden:(BOOL)isHidden
{
	if(isHidden_ != isHidden) {
		[self willChangeValueForKey:@"isHidden"];
		isHidden_ = isHidden;
		[self didChangeValueForKey:@"isHidden"];
	}
}

- (NSArray*)visibleSubitems
{
	NSMutableArray* result = [NSMutableArray array];
	
	for(CItem* subitem in self.subitems) {
		if(!subitem.isHidden) {
			[result addObject:subitem];
		}
	}
	
	return [result copy];
}

#pragma mark - @property isDisabled

+ (BOOL)automaticallyNotifiesObserversOfIsDisabled
{
	return NO;
}

- (BOOL)isDisabled
{
	return isDisabled_;
}

- (void)setDisabled:(BOOL)isDisabled
{
	if(isDisabled_ != isDisabled) {
		[self willChangeValueForKey:@"isDisabled"];
		isDisabled_ = isDisabled;
		[self didChangeValueForKey:@"isDisabled"];
	}
}

#pragma mark - @property jsonRepresentation

- (NSString*)jsonRepresentation
{
	NSMutableDictionary* outDict = [NSMutableDictionary dictionary];
	
	for(NSString* key in self.dict) {
		id obj = [self.dict objectForKey:key];
		if([obj respondsToSelector:@selector(jsonRepresentation)]) {
			obj = [obj jsonRepresentation];
		}
		[outDict setObject:obj forKey:key];
	}
	NSError* error = nil;
	NSData* outData = [NSJSONSerialization dataWithJSONObject:outDict options:0 error:&error];
	NSAssert2(error == nil, @"Creating JSON Representation of %@: %@", self, error);
	NSString* outString = [NSString stringWithData:outData encoding:NSUTF8StringEncoding];
	return outString;
}

#pragma mark - Selection

// Behavior provided by subclasses
- (BOOL)didSelect
{
	return YES;
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	NSAssert1(false, @"No table row items defined for:%@", self);
	return nil;
}

@end
