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

#import "CActionItemTableViewCell.h"
#import "StringUtils.h"

@implementation CActionItemTableViewCell

- (void)syncToRowItem {
	[super syncToRowItem];

    [self syncTitleLabelToRowItem];

	self.accessoryType = IsEmptyString(self.tableActionItem.actionItem.actionValue) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
//    self.accessoryView.hidden = self.rowItem.disabled;
}

- (CActionTableRowItem*)tableActionItem {
	return (CActionTableRowItem*)self.rowItem;
}

- (void)setTableActionItem:(CActionTableRowItem *)tableActionItem {
	self.rowItem = tableActionItem;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CActionItemTableViewCell_contentView" owner:self.contentView];
    [group addConstraint:[self.titleLabel constrainLeadingEqualToLeadingOfItem:self.contentView offset:20]];
    [group addConstraint:[self.titleLabel constrainCenterYEqualToCenterYOfItem:self.contentView]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.accessoryView.alpha = self.rowItem.disabled ? 0.5 : 1.0;
}

- (NSUInteger)validationViewsNeeded {
	return 0;
}

@end
