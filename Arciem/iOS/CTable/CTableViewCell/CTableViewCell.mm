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

#import "CTableViewCell.h"
#import "CTableRowItem.h"

@interface CTableViewCell ()

@property (nonatomic) NSMutableDictionary *constraintsGroups;

@end

@implementation CTableViewCell

@synthesize titleLabel = _titleLabel;

- (void)setup
{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.opaque = NO;

    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[self setup];
	}
	return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
//	[self drawCrossedBox:self.bounds color:[UIColor redColor] lineWidth:1.0 originIndicators:YES];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (UILabel *)textLabel {
    CLogWarn(nil, @"%@ Don't use -textLabel, use -titleLabel");
    return [super textLabel];
}

- (void)updateConstraints {
    if(_titleLabel != nil) {
        CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CTableViewCell_titleLabel" owner:self.contentView];
        [group addConstraint:[_titleLabel constrainLeadingGreaterThanOrEqualToLeadingOfItem:self.contentView offset:20]];
        [group addConstraint:[_titleLabel constrainTrailingLessThanOrEqualToTrailingOfItem:self.contentView offset:-20]];
    }
    [super updateConstraints];
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.opaque = NO;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
        _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (CLayoutConstraintsGroup *)resetConstraintsGroupForKey:(NSString *)key owner:(id)owner {
    CLayoutConstraintsGroup *group = self.constraintsGroups[key];
    if(group == nil) {
        group = [CLayoutConstraintsGroup groupWithName:key owner:owner];
        if(self.constraintsGroups == nil) {
            self.constraintsGroups = [NSMutableDictionary new];
        }
        self.constraintsGroups[key] = group;
    } else {
        [group removeAllConstraints];
    }
    return group;
}

@end
