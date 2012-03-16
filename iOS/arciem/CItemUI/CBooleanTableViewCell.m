/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CBooleanTableViewCell.h"
#import "DeviceUtils.h"
#import "CBooleanItem.h"

@implementation CBooleanTableViewCell

- (void)setup
{
	[super setup];
	
	self.indentationLevel = 1;
	
	UIFont* font;
	if(IsPad()) {
		font = [UIFont systemFontOfSize:20];
	} else {
		font = [UIFont systemFontOfSize:14];
	}
	self.textLabel.font = font;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	if(IsPhone()) {
		size.height = 30;
	}
	
	return size;
}

- (void)syncCheckMark
{
	CBooleanItem* item = (CBooleanItem*)self.rowItem.model;
	self.accessoryType = item.booleanValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)syncToRowItem
{
	[super syncToRowItem];
	[self syncCheckMark];
}

- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue
{
	[super model:model valueDidChangeFrom:oldValue to:newValue];
	[self syncCheckMark];
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

@end
