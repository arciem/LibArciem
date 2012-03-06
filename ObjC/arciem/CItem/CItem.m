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
@property (readwrite, nonatomic) BOOL needsValidation;

@end

@implementation CItem

@synthesize title = title_;
@synthesize key = key_;
@synthesize value = value_;
@synthesize userInfo = userInfo_;
@synthesize error = error_;
@synthesize required = required_;
@synthesize currentRevision = currentRevision_;
@synthesize lastValidatedRevision = lastValidatedRevision_;
@synthesize subitemErrors = subitemErrors_;
@synthesize validationsInProgress = validationsInProgress_;
@synthesize validatesAutomatically = validatesAutomatically_;
@synthesize isValidating = isValidating_;

@synthesize superitem = superitem_;
@dynamic subitems;
@dynamic subitems_;
@dynamic needsValidation;
@dynamic isValid;
@dynamic keyPath;
@dynamic state;

#pragma mark - Lifecycle

- (id)initWithDictionary:(NSDictionary*)dict
{
	if(self = [super init]) {
		subitems__ = [NSMutableArray array];
		if(dict != nil) {
			title_ = Denull([dict objectForKey:@"title"]);
			key_ = Denull([dict objectForKey:@"key"]);
			currentRevision_ = 1;
			value_ = Denull([dict objectForKey:@"value"]);
			userInfo_ = Denull([dict objectForKey:@"userInfo"]);
			required_ = [[dict objectForKey:@"required"] boolValue];
			validatesAutomatically_ = [[dict objectForKey:@"validatesAutomatically"] boolValue];
			[self addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
			NSArray* subdicts = [dict objectForKey:@"subitems"];
			for(NSDictionary* subdict in subdicts) {
				[self addSubitem:[CItem itemWithDictionary:subdict]];
			}
		}
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
	[self disarmValidate];
	[self removeObserver:self forKeyPath:@"value"];
}

+ (CItem*)itemWithDictionary:(NSDictionary*)dict
{
	CItem* item = nil;

	NSString* className = @"CItem";
	
	if(dict != nil) {
		NSString* type = [dict objectForKey:@"type"];
		if(!IsEmptyString(type)) {
			NSString* firstChar = [[type substringToIndex:1] uppercaseString];
			NSString* remainingChars = [type substringFromIndex:1];
			className = [NSString stringWithFormat:@"C%@%@Item", firstChar, remainingChars];
		}
	}

	item = ClassAlloc(className);

	return [item initWithDictionary:dict];
}

+ (CItem*)itemForResourceName:(NSString*)resourceName withExtension:(NSString*)extension
{
	NSURL* url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:extension];
	NSData* data = [NSData dataWithContentsOfURL:url];
	NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	CItem* item = [CItem itemWithDictionary:dict];
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

- (CItem*)subitemForKey:(NSString*)key
{
	id result = nil;

	for(CItem* subitem in self.subitems) {
		if([key isEqualToString:subitem.key]) {
			result = subitem;
			break;
		}
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
			[self formatValueForKey:@"userInfo" compact:compact],
			[self formatBoolValueForKey:@"required" compact:compact hidingIf:NO],
			[self formatValueForKey:@"currentRevision" compact:compact],
			[self formatValueForKey:@"lastValidatedRevision" compact:compact],
			[self formatValueForKey:@"error" compact:compact],
			[self formatValueForKey:@"subitemErrors" compact:compact],
			[self formatBoolValueForKey:@"validatesAutomatically" compact:compact hidingIf:NO],
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
	NSString* reqPrefix = item.required ? @"REQ" : @"   ";
	
	NSArray* prefixes = [NSArray arrayWithObjects:statePrefix, reqPrefix, nil];
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

#pragma  mark - KVC for item keys

- (id)valueForUndefinedKey:(NSString *)key
{
	id value = [self subitemForKey:key];
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
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"subitems"];
	[subitems__ insertObject:item atIndex:index];
	item.superitem = self;
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"subitems"];
}

- (void)insertSubitems_:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"subitems"];
	[subitems__ insertObjects:array atIndexes:indexes];
	[array enumerateObjectsUsingBlock:^(CItem* item, NSUInteger idx, BOOL *stop) {
		item.superitem = self;
	}];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"subitems"];
}

- (void)removeObjectFromSubitems_AtIndex:(NSUInteger)index
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"subitems"];
	CItem* item = [subitems__ objectAtIndex:index];
	item.superitem = nil;
	[subitems__ removeObjectAtIndex:index];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"subitems"];
}

- (void)removeSubitems_AtIndexes:(NSIndexSet *)indexes
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"subitems"];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		CItem* item = [subitems__ objectAtIndex:idx];
		item.superitem = nil;
	}];
	[subitems__ removeObjectsAtIndexes:indexes];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"subitems"];
}

#pragma mark - hierarchy manipulation

- (void)addSubitem:(CItem*)item
{
	[self.subitems addObject:item];
}

- (void)removeFromSuperitem
{
	if(self.superitem != nil) {
		NSUInteger index = [self.superitem.subitems indexOfObject:self];
		[self.subitems removeObjectAtIndex:index];
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

#pragma mark - @property needsValidation

+ (NSSet*)keyPathsForValuesAffectingNeedsValidation
{
	return [NSSet setWithObjects:@"currentRevision", @"lastValidatedRevision", nil];
}

- (BOOL)needsValidation
{
	return self.currentRevision != self.lastValidatedRevision;
}

- (void)setNeedsValidation:(BOOL)needsValidation
{
//	if(self.needsValidation != needsValidation) {
		if(needsValidation) {
			[self incrementCurrentRevision];
			if(self.superitem != nil) {
				self.superitem.needsValidation = YES;
			} else {
				if(self.state != CItemStateValidating) {
					[self armValidateIfNeeded];
				}
			}
		} else {
			[self syncLastValidatedRevision];
		}
//	}
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
	if(currentRevision_ == lastValidatedRevision_) {
		[self willChangeValueForKey:@"currentRevision"];
		currentRevision_++;
		[self didChangeValueForKey:@"currentRevision"];
	}
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

#pragma mark - @property value

+ (BOOL)automaticallyNotifiesObserversOfValue
{
	return NO;
}

- (id)value
{
	return value_;
}

- (void)setValue:(id)value
{
	if(!Same(value_, value)) {
		[self willChangeValueForKey:@"value"];
		value_ = value;
		[self didChangeValueForKey:@"value"];
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
	if(self.required && self.isEmpty) {
		error = [NSError errorWithDomain:CItemErrorDomain code:CItemErrorRequired localizedFormat:@"%@ is required.", self.title];
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

- (void)validateHierarchy
{
	[self disarmValidate];

	if(!self.isValidating) {
		if(self.needsValidation) {
			self.needsValidation = NO;
			[self incrementValidationsInProgress];
			self.error = nil;
			self.subitemErrors = nil;
			for(CItem* subitem in self.subitems) {
				[subitem validateHierarchy];
			}
			__weak CItem* self__ = self;
			[self validateWithCompletion:^(NSError* error) {
				if(error != nil) {
					self__.error = error;
					[self__.superitem addSubitemError:error];
				}
				[self__ decrementValidationsInProgress];
			}];
		} else {
			[self.superitem addSubitemError:self.error];
		}
	}
}

#pragma mark - Automatic Validation

- (void)disarmValidate
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(validateHierarchy) object:nil];
}

- (void)armValidate
{
	[self disarmValidate];
	[self performSelector:@selector(validateHierarchy) withObject:nil afterDelay:0.1];
}

- (void)armValidateIfNeeded
{
	if(self.needsValidation) {
		if(self.validatesAutomatically) {
			[self armValidate];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	CLogDebug(nil, @"observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
	if(object == self) {
		if([keyPath isEqualToString:@"value"]) {
			self.needsValidation = YES;
		}
	}
}

@end

#pragma mark -

@implementation CItemTest

+ (void)initialize
{
	CLogSetLevel(kLogAll);
}

- (void)test
{
	CItem* item = [CItem itemForResourceName:@"CItemTest1" withExtension:@"json"];
	[item printHierarchy];
	[item validateHierarchy];
	[item printHierarchy];
	[item setValue:@"rose" forKeyPath:@"head.nose.value"];
	[item printHierarchy];
	[item validateHierarchy];
	[item printHierarchy];
	CLogDebug(nil, @"done");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	CLogDebug(nil, @"observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
}

@end
