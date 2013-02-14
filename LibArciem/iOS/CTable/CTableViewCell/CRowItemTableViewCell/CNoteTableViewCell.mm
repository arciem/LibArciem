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
		self.labelInsets = UIEdgeInsetsMake(8, 10, 8, 10);
	} else {
		self.labelInsets = UIEdgeInsetsMake(8, 100, 8, 100);
	}

	UILabel* label = self.textLabel;
	label.textColor = [UIColor grayColor];
	label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
	label.shadowOffset = CGSizeMake(0, 1);
	label.font = [UIFont boldSystemFontOfSize:14];
	label.textAlignment = NSTextAlignmentCenter;
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	label.numberOfLines = 0;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size.height = self.textLabel.bottom + self.labelInsets.bottom;
	return size;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect bounds = self.bounds;
	CGRect insetBounds = UIEdgeInsetsInsetRect(bounds, self.labelInsets);
	CFrame* textLabelFrame = self.textLabel.cframe;
	textLabelFrame.frame = [self convertRect:insetBounds toView:self.contentView];
	CGFloat originalWidth = textLabelFrame.width;
	[textLabelFrame sizeToFit];
	textLabelFrame.width = originalWidth;
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

@end
