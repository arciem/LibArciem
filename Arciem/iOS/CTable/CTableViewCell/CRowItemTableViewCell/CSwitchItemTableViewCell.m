/*******************************************************************************
 
 Copyright 2013 Arciem LLC
 
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

#import "CSwitchItemTableViewCell.h"
#import "CBooleanItem.h"

@interface CSwitchItemTableViewCell ()

@property (readonly, nonatomic) UISwitch *switchControl;

@end

@implementation CSwitchItemTableViewCell

@synthesize switchControl = _switchControl;
@dynamic on;

- (BOOL)isOn {
    return self.switchControl.on;
}

- (void)setOn:(BOOL)on {
    self.switchControl.on = on;
}

- (void)setup
{
	[super setup];
	
	self.titleLabel.font = self.font;

    _switchControl = [UISwitch new];
    _switchControl.translatesAutoresizingMaskIntoConstraints = NO;
    [_switchControl addTarget:self action:@selector(switchTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_switchControl];
}

- (UIFont*)font
{
	return [UIFont systemFontOfSize:self.fontSize];
}

- (void)syncSwitchAnimated:(BOOL)animated
{
	CBooleanItem* model = (CBooleanItem*)self.rowItem.model;
    [self.switchControl setOn:model.booleanValue animated:animated];
}

- (void)syncToRowItem
{
	[super syncToRowItem];
    [self syncTitleLabelToRowItem];
	[self syncSwitchAnimated:NO];
}

- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue
{
	[super model:model valueDidChangeFrom:oldValue to:newValue];
	[self syncSwitchAnimated:YES];
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 20, 0, 20);
    
    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CSwitchTableViewCell_contentView" owner:self.contentView];
    [group addConstraint:[self.titleLabel constrainCenterYEqualToCenterYOfItem:self.contentView]];
    [group addConstraint:[self.switchControl constrainCenterYEqualToCenterYOfItem:self.titleLabel]];

    [group addConstraint:[self.switchControl constrainTrailingEqualToTrailingOfItem:self.contentView offset:-insets.right]];
    [group addConstraint:[self.titleLabel constrainLeadingEqualToLeadingOfItem:self.contentView offset:insets.left]];
    [group addConstraint:[self.titleLabel constrainTrailingLessThanOrEqualToTrailingOfItem:self.switchControl offset:-10]];
}

- (void)switchTapped {
    CBooleanItem *model = (CBooleanItem *)self.rowItem.model;
    model.booleanValue = !model.booleanValue;
}

@end
