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

#import "CAddRepeatingItemTableViewCell.h"
#import "CRepeatingItem.h"
#import "StringUtils.h"
#import "DeviceUtils.h"

@implementation CAddRepeatingItemTableViewCell

- (void)setup
{
	[super setup];
	
	UIFont* font;
	if(IsPad()) {
		font = [UIFont boldSystemFontOfSize:20];
	} else {
		font = [UIFont boldSystemFontOfSize:14];
	}
	self.textLabel.font = font;
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	CRepeatingItem* item = (CRepeatingItem*)self.rowItem.model;
	NSString* prompt = item.addAnotherPrompt;
	if(IsEmptyString(prompt)) {
		prompt = @"Add Another...";
	}
	self.textLabel.text = prompt;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	if(IsPhone()) {
		size.height = 30;
	}
	
	return size;
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

@end
