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

#import "CSetupOptionTableViewCell.h"

@implementation CSetupOptionTableViewCell

@synthesize option = option_;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
		self.textLabel.adjustsFontSizeToFitWidth = YES;
		self.textLabel.minimumScaleFactor = 0.5;
		self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	}
	
	return self;
}

- (void)syncToOption
{
	// behavior provided by subclasses
}

- (CItem*)option
{
	return option_;
}

- (void)setOption:(CItem *)option
{
	option_ = option;
	self.textLabel.text = option.title;
	[self syncToOption];
}

@end
