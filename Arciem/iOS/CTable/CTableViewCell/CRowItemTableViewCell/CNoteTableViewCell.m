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

#import "CNoteTableViewCell.h"
#import "UIViewUtils.h"
#import "DeviceUtils.h"

@interface CNoteTableViewCell ()

@property (nonatomic) UIEdgeInsets labelInsets;
@end

@implementation CNoteTableViewCell

@synthesize labelInsets = labelInsets_;

- (void)setup
{
	[super setup];
	
	if(IsPhone()) {
		self.labelInsets = UIEdgeInsetsMake(8, 20, 8, 20);
	} else {
		self.labelInsets = UIEdgeInsetsMake(8, 100, 8, 100);
	}

    self.titleLabel.text = @"Hello World";
	self.titleLabel.textColor = [UIColor darkGrayColor];
	self.titleLabel.font = [UIFont systemFontOfSize:14];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.numberOfLines = 0;
}

- (void)updateConstraints {
    [super updateConstraints];

    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CNoteTableViewCell_contentView" owner:self.contentView];
    
    [group addConstraint:[self.titleLabel constrainTopEqualToTopOfItem:self.contentView offset:self.labelInsets.top]];
    [group addConstraint:[self.titleLabel constrainBottomEqualToBottomOfItem:self.contentView offset:-self.labelInsets.bottom]];
    [group addConstraint:[self.titleLabel constrainCenterXEqualToCenterXOfItem:self.contentView]];
    [group addConstraint:[self.titleLabel constrainLeadingEqualToLeadingOfItem:self.contentView offset:self.labelInsets.left]];
    [group addConstraint:[self.titleLabel constrainTrailingEqualToTrailingOfItem:self.contentView offset:-self.labelInsets.right]];
}


- (void)syncToRowItem {
    [super syncToRowItem];
    [self syncTitleLabelToRowItem];
    [self setNeedsUpdateConstraints];
}

- (NSUInteger)validationViewsNeeded {
	return 0;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = size;
    self.titleLabel.cframe.height = 1000;
    [self.titleLabel sizeToFit];
    return CGSizeMake(s.width, self.titleLabel.height);
}

@end
