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
#import "UIViewUtils.h"
#import "CObserver.h"

@interface CAddRepeatingItemTableViewCell ()

@property (readonly, nonatomic) CRepeatingItem *repeatingItem;
@property (nonatomic) CObserver *modelSubitemsObserver;

@end

@implementation CAddRepeatingItemTableViewCell


- (void)setup
{
	[super setup];
	
	self.titleLabel.font = self.font;
}

- (CRepeatingItem *)repeatingItem {
    return (CRepeatingItem *)self.rowItem.model;
}

- (void)syncPrompt {
	NSString* prompt = @"Add…";
    NSUInteger count = self.repeatingItem.subitems.count;
    if(count > 0 && !IsEmptyString(self.repeatingItem.addAnotherPrompt)) {
        prompt = self.repeatingItem.addAnotherPrompt;
    } else if(count == 0 && !IsEmptyString(self.repeatingItem.addFirstPrompt)) {
        prompt = self.repeatingItem.addFirstPrompt;
    }
    self.accessoryType = self.repeatingItem.addRequiresDrillDown ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.titleLabel.text = prompt;
    [self setNeedsUpdateConstraints];
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	self.modelSubitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self.repeatingItem action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
        [self syncPrompt];
    }];
    [self syncPrompt];
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (void)updateConstraints {
    [super updateConstraints];

    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CAddRepeatingItemTableViewCell_contentView" owner:self.contentView];
    [group addConstraints:[self.titleLabel constrainCenterEqualToCenterOfItem:self.contentView]];
    [group addConstraint:[self.titleLabel constrainTopEqualToTopOfItem:self.contentView offset:8]];
    [group addConstraint:[self.titleLabel constrainBottomEqualToBottomOfItem:self.contentView offset:-8]];
    [group addConstraint:[self.titleLabel constrainLeadingGreaterThanOrEqualToLeadingOfItem:self.contentView offset:20]];
    [group addConstraint:[self.titleLabel constrainTrailingLessThanOrEqualToTrailingOfItem:self.contentView offset:-20]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(IsOSVersionAtLeast7()) {
        self.titleLabel.textColor = self.tintColor;
    }
}

@end
