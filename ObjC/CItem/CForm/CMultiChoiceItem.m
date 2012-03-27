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
#import "CDividerItem.h"

@interface CMultiChoiceItem ()

@property (strong, nonatomic) CObserver* subitemsObserver;
@property (strong, nonatomic) NSArray* subitemValueObservers;

@end

@implementation CMultiChoiceItem

@synthesize minValidChoices = minValidChoices_;
@synthesize maxValidChoices = maxValidChoices_;
@synthesize selectedSubitems = selectedSubitems_;
@synthesize subitemsObserver = subitemsObserver_;
@synthesize subitemValueObservers = subitemValueObservers_;

@dynamic choicesCount;

- (void)setup
{
	[super setup];
	[self syncToChoices];
	
	self.subitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self syncToSubitems];
	} initial:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self syncToSubitems];
	}];
}

- (NSUInteger)minValidChoices
{
	return [self.dict unsignedIntegerValueForKey:@"minValidChoices" defaultValue:1];
}

- (void)setMinValidChoices:(NSUInteger)minValidChoices
{
	[self.dict setObject:[NSNumber numberWithUnsignedInt:minValidChoices] forKey:@"minValidChoices"];
}

- (NSUInteger)maxValidChoices
{
	return [self.dict unsignedIntegerValueForKey:@"maxValidChoices" defaultValue:1];
}

- (void)setMaxValidChoices:(NSUInteger)maxValidChoices
{
	[self.dict setObject:[NSNumber numberWithUnsignedInt:maxValidChoices] forKey:@"maxValidChoices"];
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
	return NO;
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
	return [self.dict objectForKey:@"choices"];
}

- (void)setChoices:(NSArray *)choices
{
	[self.dict setObject:choices forKey:@"choices"];
	[self syncToChoices];
}

- (void)syncToChoices
{
	[self.subitems removeAllObjects];

	NSArray* choices = self.choices;
	[choices enumerateObjectsUsingBlock:^(NSString* str, NSUInteger idx, BOOL *stop) {
		CItem* item = nil;
		
		if([str isEqualToString:@"-"]) {
			item = [CDividerItem dividerItem];
		} else {
			NSArray* comps = [str componentsSeparatedByString:@"/"];
			NSString* key = [comps objectAtIndex:0];
			NSString* title = [comps objectAtIndex:1];
			BOOL value = NO;
			if([key characterAtIndex:0] == [@"*" characterAtIndex:0]) {
				value = YES;
				key = [key substringFromIndex:1];
			}
			
			item = [CBooleanItem booleanItemWithTitle:title key:key boolValue:value];
		}
		
		[self addSubitem:item];
	}];
}

#pragma mark - @property selectedSubitems

- (NSArray*)selectedSubitems
{
	return selectedSubitems_;
}

- (void)setSelectedSubitems:(NSArray *)selectedSubitems
{
	[self willChangeValueForKey:@"selectedSubitems"];
	selectedSubitems_ = selectedSubitems;
	[self didChangeValueForKey:@"selectedSubitems"];
}

- (void)syncToSubitems
{
	NSMutableArray* selectedSubitems = [NSMutableArray array];
	
	[self.subitems enumerateObjectsUsingBlock:^(CItem* item, NSUInteger idx, BOOL *stop) {
		if([item isKindOfClass:[CBooleanItem class]]) {
			CBooleanItem* booleanItem = (CBooleanItem*)item;
			if(booleanItem.booleanValue) {
				[selectedSubitems addObject:booleanItem];
			}
		}
	}];
	
	self.selectedSubitems = selectedSubitems;
}

#pragma mark - @property selectedSubitem

+ (NSSet*)keyPathsForValuesAffectingSelectedSubitem
{
	return [NSSet setWithObject:@"selectedSubitems"];
}

- (CBooleanItem*)selectedSubitem
{
	CBooleanItem* result = nil;
	
	NSArray* selectedSubitems = self.selectedSubitems;
	if(selectedSubitems.count > 0) {
		result = (CBooleanItem*)[selectedSubitems objectAtIndex:0];
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
			[rowItems addObjectsFromArray:newRowItems];
		}
	}
	return rowItems;
}

@end
