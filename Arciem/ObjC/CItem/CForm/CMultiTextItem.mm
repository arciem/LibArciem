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

#import "CMultiTextItem.h"
#import "CTableTextFieldItem.h"

@implementation CMultiTextItem

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	NSAssert1(self.subitems.count == 2, @"count of %d not supported.", self.subitems.count);
	CTableTextFieldItem* rowItem = [CTableTextFieldItem itemWithKey:self.key title:self.title multiTextItem:self];
	return @[rowItem];
}

@end
