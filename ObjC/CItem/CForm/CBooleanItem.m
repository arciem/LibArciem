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

#import "CBooleanItem.h"
#import "CMultiChoiceItem.h"
#import "CTableBooleanItem.h"

@implementation CBooleanItem

@dynamic booleanValue;

+ (CBooleanItem*)booleanItem
{
	return [[self alloc] init];
}

+ (CBooleanItem*)booleanItemWithDictionary:(NSDictionary*)dict
{
	return [[self alloc] initWithDictionary:dict];
}

+ (CBooleanItem*)booleanItemWithTitle:(NSString*)title key:(NSString*)key boolValue:(BOOL)boolValue
{
	NSNumber* value = [NSNumber numberWithBool:boolValue];
	return [[self alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
											 title, @"title",
											 key, @"key",
											 value, @"value",
											 @"boolean", @"type",
											 nil]];
}

- (BOOL)booleanValue
{
	return [(NSNumber*)self.value boolValue];
}

- (void)setBooleanValue:(BOOL)boolValue
{
	self.value = [NSNumber numberWithBool:boolValue];
}

- (BOOL)didSelect
{
	BOOL shouldDeselect = [super didSelect];

	if([self.superitem isKindOfClass:[CMultiChoiceItem class]]) {
		CMultiChoiceItem* parent = (CMultiChoiceItem*)self.superitem;
		[parent selectSubitem:self];
	} else {
		self.booleanValue = !self.booleanValue;
	}

	shouldDeselect = YES;

	return shouldDeselect;
}

- (NSArray*)tableRowItems
{
	CTableBooleanItem* item = [CTableBooleanItem itemWithKey:self.key title:self.title booleanItem:self];
	return [NSArray arrayWithObject:item];
}

@end
