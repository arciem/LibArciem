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
#import "UIViewUtils.h"
#import "ThreadUtils.h"

@interface CBooleanTableViewCell ()

@end

@implementation CBooleanTableViewCell

@synthesize checkmarkButton = _checkmarkButton;

- (void)setup
{
	[super setup];
	
	self.titleLabel.font = self.font;
}

- (UIFont*)font
{
	return [UIFont systemFontOfSize:self.fontSize];
}

- (void)syncCheckMark
{
	CBooleanItem* item = (CBooleanItem*)self.rowItem.model;
	self.checkmarkButton.selected = item.booleanValue;
}

- (void)syncToRowItem
{
	[super syncToRowItem];
    [self syncTitleLabelToRowItem];
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

- (void)updateConstraints {
    [super updateConstraints];

    UIEdgeInsets insets = self.contentInset;
    
    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CBooleanTableViewCell_contentView" owner:self.contentView];
    [group addConstraint:[self.checkmarkButton constrainCenterYEqualToCenterYOfItem:self.titleLabel]];
    [group addConstraint:[self.checkmarkButton constrainLeadingEqualToLeadingOfItem:self.contentView offset:insets.left]];
    [group addConstraint:[self.titleLabel constrainLeadingEqualToTrailingOfItem:self.checkmarkButton offset:8]];
    [group addConstraint:[self.titleLabel constrainCenterYEqualToCenterYOfItem:self.contentView]];
}

#pragma mark - @property checkmarkButton

- (UIButton*)checkmarkButton
{
	if(_checkmarkButton == nil) {
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		UIImage* selectedImage = [UIImage imageNamed:@"SurveyCheckYes"];
		[button setImage:selectedImage forState:UIControlStateSelected];
		UIImage* unselectedImage = [UIImage imageNamed:@"SurveyCheckNo"];
		[button setImage:unselectedImage forState:UIControlStateNormal];
		self.checkmarkButton = button;
	}
	
	return _checkmarkButton;
}

- (void)setCheckmarkButton:(UIButton *)checkmarkButton
{
	if(_checkmarkButton != checkmarkButton) {
		[_checkmarkButton removeFromSuperview];
		_checkmarkButton = checkmarkButton;
		if(_checkmarkButton != nil) {
			[self.contentView addSubview:_checkmarkButton];
			_checkmarkButton.userInteractionEnabled = NO;
		}
		[self setNeedsUpdateConstraints];
	}
}
@end
