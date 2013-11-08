//
//  CTextFieldTableViewCell.mm
//  Arciem
//
//  Created by Robert McNally on 10/12/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CTextFieldTableViewCell.h"

#import "UIViewUtils.h"
#import "Geom.h"

//#define DEBUG_LAYOUT

@interface CTextFieldTableViewCell ()

@property(readwrite, nonatomic) UITextField *textField;

@end

@implementation CTextFieldTableViewCell

@synthesize textField = textField_;
@synthesize textFieldLeft = textFieldLeft_;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textFieldLeft = 50;
	}
	return self;
}

- (UITextField*)textField
{
	if(textField_ == nil) {
		textField_ = [[UITextField alloc] initWithFrame:self.textLabel.frame];
		textField_.placeholder = @"Placeholder";
		[self.contentView addSubview:textField_];
#ifdef DEBUG_LAYOUT
		self.textField.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.25];
#endif
	}
	
	return textField_;
}

#ifdef DEBUG_LAYOUT
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.textLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
}
#endif

- (void)setTextField:(UITextField *)textField
{
	[textField_ removeFromSuperview];
	textField_ = textField;
	if(textField_) {
		[self.contentView addSubview:textField_];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
	[self.textLabel sizeToFit];
	self.textLabel.frame = CGRectIntegral([Geom alignRectMidY:self.textLabel.frame toY:CGRectGetMidY(self.contentView.bounds)]);
    
	CFrame* textFieldFrame = self.textField.cframe;
	textFieldFrame.frame = self.textLabel.frame;
	textFieldFrame.flexibleRight = self.contentView.boundsRight - 10;
	textFieldFrame.flexibleLeft = self.textFieldLeft;
}

@end
