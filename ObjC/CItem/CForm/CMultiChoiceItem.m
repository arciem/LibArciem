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

@interface CMultiChoiceItem ()

@end

@implementation CMultiChoiceItem

@synthesize minValidChoices = minValidChoices_;
@synthesize maxValidChoices = maxValidChoices_;
@dynamic choicesCount;

- (void)setup
{
	[super setup];
	self.minValidChoices = [self.dict unsignedIntegerValueForKey:@"minValidChoices" defaultValue:1];
	self.maxValidChoices = [self.dict unsignedIntegerValueForKey:@"maxValidChoices" defaultValue:1];
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
		if(subitem.booleanValue) {
			count++;
		}
	}];
	return count;
}

 - (void)didSelectSubitem:(CBooleanItem*)item
{
	BOOL oldValue = item.booleanValue;
	BOOL newValue = !oldValue;

	if(self.minValidChoices == 1 && self.maxValidChoices == 1) {
		[self.subitems enumerateObjectsUsingBlock:^(CBooleanItem* otherItem, NSUInteger idx, BOOL *stop) {
			if(otherItem != item) {
				otherItem.booleanValue = NO;
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

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	NSMutableArray* rowItems = [NSMutableArray array];
	CTableMultiChoiceItem* rowItem = [CTableMultiChoiceItem itemWithKey:self.key title:self.title multiChoiceItem:self];
	[rowItems addObject:rowItem];
	for(CBooleanItem* item in self.subitems) {
		CTableBooleanItem* rowItem = [CTableBooleanItem itemWithKey:item.key title:item.title booleanItem:item];
		[rowItems addObject:rowItem];
	}
	return rowItems;
}

@end
