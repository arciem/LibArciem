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

#import "CSwitchTableViewCell.h"

#define kSwitchButtonWidth		94.0
#define kSwitchButtonHeight		27.0

static const CGFloat TOP_MARGIN = 10;
static const CGFloat BOTTOM_MARGIN = TOP_MARGIN;
static const CGFloat LEFT_MARGIN = 10;
static const CGFloat RIGHT_MARGIN = LEFT_MARGIN;

//static const CGFloat INNER_MARGIN = 10;

static const CGFloat FONT_SIZE = 18;

@implementation CSwitchTableViewCell

- (instancetype)initWithLabelText:(NSString*)labelText {
	if((self = [super initWithFrame:CGRectZero])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.label.opaque = YES;
		self.label.textColor = [UIColor blackColor];
		self.label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
		self.label.textAlignment = NSTextAlignmentRight;
		self.label.text = labelText;
		[self.contentView addSubview:self.label];
		
//		_switchCtl = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
		_switchCtl = [[UISwitch alloc] initWithFrame: CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight)];
//	[self.activeSwitch addTarget:self action:@selector(activeSwitchAction:) forControlEvents:UIControlEventValueChanged];
		// in case the parent view draws with a custom color or gradient, use a transparent color
		self.switchCtl.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.switchCtl];
	}
	return self;
}

- (void)addTarget:(id)target action:(SEL)sel {
	[self.switchCtl addTarget:target action:sel forControlEvents:UIControlEventValueChanged];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
	[self.switchCtl setOn:on animated:animated];
}

- (BOOL)isOn {
	return self.switchCtl.on;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)setEnabled:(BOOL)enabled {
	[self.label setEnabled:enabled];
	[self.switchCtl setEnabled:enabled];
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//	CGRect contentRect = [self contentRectForBounds:self.bounds];
	CGRect contentRect = self.contentView.bounds;
	
	CGFloat labelWidth = [self.label textRectForBounds:contentRect limitedToNumberOfLines:1].size.width;
	CGFloat labelLeft = contentRect.origin.x + LEFT_MARGIN;
//	CGFloat labelRight = labelLeft + labelWidth;
	CGFloat fieldRight = CGRectGetMaxX(contentRect) - RIGHT_MARGIN;
	CGFloat fieldLeft = fieldRight - kSwitchButtonWidth;
	CGFloat height = contentRect.size.height - TOP_MARGIN - BOTTOM_MARGIN;
	
	self.label.frame = CGRectMake(labelLeft, contentRect.origin.y + TOP_MARGIN, labelWidth, height);
	self.switchCtl.frame = CGRectMake(fieldLeft, contentRect.origin.y + TOP_MARGIN, kSwitchButtonWidth, kSwitchButtonHeight);
}

@end
