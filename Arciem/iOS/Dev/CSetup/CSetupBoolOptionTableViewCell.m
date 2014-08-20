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

#import "CSetupBoolOptionTableViewCell.h"
#import "CBooleanItem.h"

@interface CSetupBoolOptionTableViewCell ()

@property (nonatomic) UISwitch* switchView;
@property (readonly, nonatomic) CBooleanItem* boolOption;

@end

@implementation CSetupBoolOptionTableViewCell

@dynamic boolOption;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithReuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.switchView = [UISwitch new];
		[self.switchView addTarget:self action:@selector(switchStateChanged) forControlEvents:UIControlEventValueChanged];
		self.accessoryView = self.switchView;
		self.textLabel.font = [UIFont boldSystemFontOfSize:12];
	}
	
	return self;
}

- (CBooleanItem*)boolOption
{
	return (CBooleanItem*)self.option;
}

- (void)syncToOption
{
	self.switchView.on = self.boolOption.booleanValue;
}

- (void)switchStateChanged
{
	self.boolOption.booleanValue = self.switchView.on;
}

@end
