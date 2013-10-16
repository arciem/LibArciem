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

#import "CMultiChoiceItem.h"
#import "CObserver.h"
#import "CBooleanItem.h"
#import "ObjectUtils.h"
#import "CTableMultiChoiceItem.h"
#import "CTableBooleanItem.h"
#import "CSpacerItem.h"
#import "ErrorUtils.h"

NSString* const CMultiChoiceItemErrorDomain = @"CMultiChoiceItemErrorDomain";

@interface CMultiChoiceItem ()

@property (nonatomic) CObserver* subitemsObserver;
@property (nonatomic) CObserver* subitemsValueObserver;

@end

@implementation CMultiChoiceItem

@synthesize minValidChoices = minValidChoices_;
@synthesize maxValidChoices = maxValidChoices_;
@synthesize subitemsObserver = subitemsObserver_;
@synthesize subitemsValueObserver = subitemsValueObserver_;

@dynamic choicesCount;

- (void)setup
{
	[super setup];
	[self setupChoices];

    BSELF;
	self.subitemsValueObserver = [CObserver observerWithKeyPath:@"value" action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself updateValue];
	} initial:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself updateValue];
	}];

	self.subitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self action:^(id object, NSArray* newSubitems, NSArray* oldSubitems, NSKeyValueChange kind, NSIndexSet *indexes) {
		NSAssert1(newSubitems == nil || [newSubitems isKindOfClass:[NSArray class]], @"newSubitems not of expected type:%@", newSubitems);
		NSAssert1(oldSubitems == nil || [oldSubitems isKindOfClass:[NSArray class]], @"oldSubitems not of expected type:%@", oldSubitems);
		switch(kind) {
			case NSKeyValueChangeSetting:
				bself.subitemsValueObserver.objects = newSubitems;
				break;
			case NSKeyValueChangeInsertion:
				[bself.subitemsValueObserver addObjects:newSubitems];
				break;
			case NSKeyValueChangeRemoval:
				[bself.subitemsValueObserver removeObjects:oldSubitems];
				break;
			case NSKeyValueChangeReplacement:
				[bself.subitemsValueObserver removeObjects:oldSubitems];
				[bself.subitemsValueObserver addObjects:newSubitems];
				break;
		}
	} initial:^(id object, NSArray* newSubitems, NSArray* oldSubitems, NSKeyValueChange kind, NSIndexSet *indexes) {
		NSAssert1(newSubitems == nil || [newSubitems isKindOfClass:[NSArray class]], @"newSubitems not of expected type:%@", newSubitems);
		bself.subitemsValueObserver.objects = newSubitems;
	}];
}

- (NSUInteger)minValidChoices
{
	return [self.dict unsignedIntegerValueForKey:@"minValidChoices" defaultValue:1];
}

- (void)setMinValidChoices:(NSUInteger)minValidChoices
{
	(self.dict)[@"minValidChoices"] = @(minValidChoices);
}

- (NSUInteger)maxValidChoices
{
	return [self.dict unsignedIntegerValueForKey:@"maxValidChoices" defaultValue:1];
}

- (void)setMaxValidChoices:(NSUInteger)maxValidChoices
{
	(self.dict)[@"maxValidChoices"] = @(maxValidChoices);
}


- (id)copyWithZone:(NSZone *)zone
{
	CMultiChoiceItem* item = [super copyWithZone:zone];
	
	item.minValidChoices = self.minValidChoices;
	item.maxValidChoices = self.maxValidChoices;
	
	return item;
}

- (BOOL)isEmpty
{
	return self.choicesCount == 0;
}

- (NSError*)validate
{
	NSError* error = [super validate];
	
	if(error == nil) {
		NSUInteger choicesCount = self.choicesCount;
		if(self.minValidChoices > 0 && self.maxValidChoices > 0 && choicesCount != self.minValidChoices) {
			error = [NSError errorWithDomain:CMultiChoiceItemErrorDomain code:CMultiChoiceItemErrorWrongChoiceCount localizedFormat:@"Choose only %d %@.", self.minValidChoices, self.title];
		} else if(self.minValidChoices > 0 && choicesCount < self.minValidChoices) {
			error = [NSError errorWithDomain:CMultiChoiceItemErrorDomain code:CMultiChoiceItemErrorWrongChoiceCount localizedFormat:@"Choose at least %d %@.", self.minValidChoices, self.title];
		} else if(self.maxValidChoices > 0 && choicesCount > self.maxValidChoices) {
			error = [NSError errorWithDomain:CMultiChoiceItemErrorDomain code:CMultiChoiceItemErrorWrongChoiceCount localizedFormat:@"Choose at most %d %@.", self.maxValidChoices, self.title];
		}
	}
	
	return error;
}

- (NSUInteger)choicesCount
{
	__block NSUInteger count = 0;
	
	[self.subitems enumerateObjectsUsingBlock:^(CBooleanItem* subitem, NSUInteger idx, BOOL *stop) {
		if([subitem isKindOfClass:[CBooleanItem class]]) {
			CBooleanItem* booleanSubitem = (CBooleanItem*)subitem;
			if(booleanSubitem.booleanValue) {
				count++;
			}
		}
	}];
	return count;
}

 - (void)selectSubitem:(CBooleanItem*)item
{
	BOOL oldValue = item.booleanValue;
	BOOL newValue = !oldValue;

	if(self.minValidChoices == 1 && self.maxValidChoices == 1) {
		[self.subitems enumerateObjectsUsingBlock:^(CItem* otherItem, NSUInteger idx, BOOL *stop) {
			if([otherItem isKindOfClass:[CBooleanItem class]]) {
				CBooleanItem* otherBooleanItem = (CBooleanItem*)otherItem;
				if(otherBooleanItem != item) {
					otherBooleanItem.booleanValue = NO;
				}
			}
		}];
	}
	
	if(newValue) {
		if(self.choicesCount >= self.maxValidChoices) {
			newValue = oldValue;
		}
	} else {
		if(self.choicesCount <= self.minValidChoices) {
			newValue = oldValue;
		}
	}

	item.booleanValue = newValue;
}

#pragma mark - @property choices

- (NSArray*)choices
{
	return (self.dict)[@"choices"];
}

- (void)setChoices:(NSArray *)choices
{
	(self.dict)[@"choices"] = choices;
	[self setupChoices];
}

- (void)setupChoices
{
	[self.subitems removeAllObjects];

	NSArray* choices = self.choices;
	[choices enumerateObjectsUsingBlock:^(NSString* str, NSUInteger idx, BOOL *stop) {
		CItem* item = nil;
		
		if([str isEqualToString:@"-"]) {
			item = [CSpacerItem spacerItem];
		} else {
			NSArray* comps = [str componentsSeparatedByString:@"/"];
			NSString* key = comps[0];
			NSString* title = comps[1];
			BOOL value = NO;
			if([key characterAtIndex:0] == [@"*" characterAtIndex:0]) {
				value = YES;
				key = [key substringFromIndex:1];
			}
			
			item = [CBooleanItem booleanItemWithTitle:title key:key boolValue:value];
		}
		
		[self addSubitem:item];
	}];
	
	self.isNew = YES;
}

#pragma mark - @property selectedSubitemIndexes

- (NSIndexSet*)selectedSubitemIndexes
{
	return (NSIndexSet*)self.value;
}

- (void)setSelectedSubitemIndexes:(NSIndexSet *)selectedSubitemIndexes
{
	self.value = selectedSubitemIndexes;
//	CLogDebug(nil, @"%@ selectedSubitemIndexes:%@", self, self.value);
}

- (void)updateValue
{
	self.selectedSubitemIndexes = [self.subitems indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		BOOL result = NO;
		if([obj isKindOfClass:[CBooleanItem class]]) {
			CBooleanItem* booleanItem = (CBooleanItem*)obj;
			if(booleanItem.booleanValue) {
				result = YES;
			}
		}
		return result;
	}];
}

#pragma mark - @property selectedSubitem

+ (NSSet*)keyPathsForValuesAffectingSelectedSubitem
{
	return [NSSet setWithObject:@"value"];
}

- (CBooleanItem*)selectedSubitem
{
	CBooleanItem* result = nil;
	
    if(self.selectedSubitemIndexes != nil) {
        NSUInteger index = self.selectedSubitemIndexes.firstIndex;
        if(index != NSNotFound) {
            result = (self.subitems)[index];
        }
    }
	
	return result;
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	NSMutableArray* rowItems = [NSMutableArray array];
	CTableMultiChoiceItem* rowItem = [CTableMultiChoiceItem itemWithKey:self.key title:self.title multiChoiceItem:self];
	[rowItems addObject:rowItem];
	if(!rowItem.requiresDrillDown) {
		for(CItem* item in self.subitems) {
			NSArray* newRowItems = [item tableRowItems];
			for(CTableRowItem* rowItem in newRowItems) {
				rowItem.indentationLevel = 1;
//				CLogDebug(nil, @"%@ created", rowItem);
			}
			[rowItems addObjectsFromArray:newRowItems];
		}
	}
	return rowItems;
}

@end
