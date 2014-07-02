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

#import "CCheckboxTableViewCell.h"
#import "CBooleanItem.h"

@implementation CCheckboxTableViewCell

@synthesize checkboxButton = _checkboxButton;

- (void)setup
{
	[super setup];
	
	self.titleLabel.font = self.font;
}

- (UIFont*)font
{
	return [UIFont systemFontOfSize:self.fontSize];
}

- (void)syncCheckbox
{
	CBooleanItem* item = (CBooleanItem*)self.rowItem.model;
	self.checkboxButton.selected = item.booleanValue;
}

- (void)syncToRowItem
{
	[super syncToRowItem];
    [self syncTitleLabelToRowItem];
	[self syncCheckbox];
}

- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue
{
	[super model:model valueDidChangeFrom:oldValue to:newValue];
	[self syncCheckbox];
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (void)updateConstraints {
    [super updateConstraints];

    UIEdgeInsets insets = self.contentInset;
    
    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CCheckboxTableViewCell_contentView" owner:self.contentView];
    [group addConstraint:[self.checkboxButton constrainCenterYEqualToCenterYOfItem:self.titleLabel]];
    [group addConstraint:[self.checkboxButton constrainLeadingEqualToLeadingOfItem:self.contentView offset:insets.left]];
    [group addConstraint:[self.titleLabel constrainLeadingEqualToTrailingOfItem:self.checkboxButton offset:8]];
    [group addConstraint:[self.titleLabel constrainCenterYEqualToCenterYOfItem:self.contentView]];
}

#pragma mark - @property checkboxButton

- (UIButton*)checkboxButton
{
	if(_checkboxButton == nil) {
		self.checkboxButton = [[self class] newCheckboxButton];
	}
	
	return _checkboxButton;
}

- (void)setCheckboxButton:(UIButton *)checkboxButton
{
	if(_checkboxButton != checkboxButton) {
		[_checkboxButton removeFromSuperview];
		_checkboxButton = checkboxButton;
		if(_checkboxButton != nil) {
			[self.contentView addSubview:_checkboxButton];
			_checkboxButton.userInteractionEnabled = NO;
		}
		[self setNeedsUpdateConstraints];
	}
}

@end
