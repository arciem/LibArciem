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

#import "CTableMultiChoiceItem.h"

@implementation CTableMultiChoiceItem

- (id)initWithKey:(NSString*)key title:(NSString*)title multiChoiceItem:(CMultiChoiceItem*)item
{
	if(self = [super initWithKey:key title:title model:item]) {
		if(self.model.subitems.count <= 4) {
			self.requiresDrillDown = NO;
		}
	}
	return self;
}

+ (CTableMultiChoiceItem*)itemWithKey:(NSString*)key title:(NSString*)title multiChoiceItem:(CMultiChoiceItem*)item
{
	return [[self alloc] initWithKey:key title:title multiChoiceItem:item];
}

- (NSString*)defaultCellType
{
	return @"CMultiChoiceItemTableViewCell";
}

@end
