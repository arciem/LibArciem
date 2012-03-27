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
#import "CDividerItem.h"
#import "CTableDividerItem.h"

@interface CMultiChoiceItem ()

@end

@implementation CMultiChoiceItem

@synthesize minValidChoices = minValidChoices_;
@synthesize maxValidChoices = maxValidChoices_;
@dynamic choicesCount;

- (void)setup
{
	[super setup];
	[self syncToChoices];
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

 - (void)didSelectSubitem:(CBooleanItem*)item
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

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	NSMutableArray* rowItems = [NSMutableArray array];
	CTableMultiChoiceItem* rowItem = [CTableMultiChoiceItem itemWithKey:self.key title:self.title multiChoiceItem:self];
	[rowItems addObject:rowItem];
	if(!rowItem.requiresDrillDown) {
		for(CItem* item in self.subitems) {
			CTableRowItem* rowItem = nil;
			
			if([item isKindOfClass:[CBooleanItem class]]) {
				CBooleanItem* booleanItem = (CBooleanItem*)item;
				rowItem = [CTableBooleanItem itemWithKey:item.key title:item.title booleanItem:booleanItem];
			} else if([item isKindOfClass:[CDividerItem class]]) {
				CDividerItem* dividerItem = (CDividerItem*)item;
				rowItem = [CTableDividerItem itemWithKey:item.key title:item.title dividerItem:dividerItem];
			} else {
				NSAssert1(false, @"Unknown multichoice item:%@", item);
			}
			
			[rowItems addObject:rowItem];
		}
	}
	return rowItems;
}

@end
