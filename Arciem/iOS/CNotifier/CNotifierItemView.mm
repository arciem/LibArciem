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

#import "CNotifierItemView.h"
#import "UIViewUtils.h"
#import "UIColorUtils.h"
#import "CGUtils.h"
#import "UIImageUtils.h"

@interface CNotifierItemView ()

@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UIImageView* backgroundImageView;
@property (strong, nonatomic) UIView* rightAccessoryView;
@property (strong, nonatomic) UITapGestureRecognizer* tapRecognizer;

@end

@implementation CNotifierItemView

@synthesize item = item_;
@synthesize label = label_;
@synthesize backgroundImageView = backgroundImageView_;
@synthesize rightAccessoryView = rightAccessoryView_;
@synthesize tapRecognizer = tapRecognizer_;

- (void)setup
{
	[super setup];
	
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
	self.backgroundImageView.alpha = 1.0;
	[self addSubview:self.backgroundImageView];
	
	self.label = [[UILabel alloc] initWithFrame:self.bounds];
	self.label.userInteractionEnabled = NO;
	self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.label.opaque = NO;
	self.label.backgroundColor = [UIColor clearColor];
//	self.label.backgroundColor = [[UIColor greenColor] colorWithAlpha:0.5];
	self.label.font = [UIFont boldSystemFontOfSize:14.0];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.adjustsFontSizeToFitWidth = YES;
    self.label.minimumScaleFactor = 0.5;
	self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:self.label];
	
	[self addObserver:self forKeyPath:@"item" options:0 context:NULL];
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"item"];
}

- (UIView*)rightAccessoryView
{
	return rightAccessoryView_;
}

- (void)setRightAccessoryView:(UIView *)rightAccessoryView
{
	if(rightAccessoryView_ != rightAccessoryView) {
		[rightAccessoryView_ removeFromSuperview];
		rightAccessoryView_ = rightAccessoryView;
		if(rightAccessoryView_ != nil) {
			[rightAccessoryView_ sizeToFit];
			rightAccessoryView_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
			[self addSubview:rightAccessoryView_];
		}

		[self setNeedsLayout];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CFrame* labelFrame = self.label.cframe;
	labelFrame.frame = self.bounds;
	labelFrame.flexibleLeft = self.boundsLeft + 10;
	labelFrame.flexibleRight = self.boundsRight - 10;
	labelFrame.top -= 1;

	if(self.rightAccessoryView != nil) {
		CFrame* rightAccessoryViewFrame = self.rightAccessoryView.cframe;
		rightAccessoryViewFrame.top = self.boundsTop;
		rightAccessoryViewFrame.flexibleBottom = self.boundsBottom;
		rightAccessoryViewFrame.width = 30;
		rightAccessoryViewFrame.right = self.boundsRight;
		labelFrame.flexibleRight = rightAccessoryViewFrame.left;
	} else {
		labelFrame.flexibleRight = self.boundsRight - 10;
	}
}

- (UIImage*)newImageForBackground
{
	CGRect imageBounds = {0, 0, 10, self.height};
	
	CGRect topEdge, middle, bottomEdge;
	CGRectDivide(imageBounds, &topEdge, &middle, 1.0, CGRectMinYEdge);
	CGRectDivide(middle, &bottomEdge, &middle, 1.0, CGRectMaxYEdge);
	
	UIColor* tintColor = [self.item.tintColor colorWithAlphaComponent:1.0];
	UIColor* topColor = [tintColor colorByLighteningFraction:0.3];
	UIColor* bottomColor = [tintColor colorByDarkeningFraction:0.4];
	
	UIColor* color1 = [tintColor colorByLighteningFraction:0.2];
	UIColor* color2 = [tintColor colorByDarkeningFraction:0.3];

	UIGraphicsBeginImageContextWithOptions(imageBounds.size, YES, 0.0);
	
	[topColor set];
	UIRectFill(topEdge);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGGradientRef gradient = GradientCreateWith2Colors(color1.CGColor, color2.CGColor, SharedColorSpaceDeviceRGB());
	ContextFillRectGradientVertical(context, middle, gradient);
	CGGradientRelease(gradient);

	[bottomColor set];
	UIRectFill(bottomEdge);

	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (void)syncToItem
{
	self.label.text = self.item.message;
	self.label.font = self.item.font;

	[self.backgroundImageView setImage:[self newImageForBackground]];

	if(self.item.whiteText) {
		self.label.textColor = [UIColor whiteColor];
		self.label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		self.label.shadowOffset = CGSizeMake(0, -1);
	} else {
		self.label.textColor = [UIColor blackColor];
		self.label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		self.label.shadowOffset = CGSizeMake(0, 1);
	}

	UIImageView* rightAccessoryView = nil;
	if(self.item.tapHandler != NULL) {
		UIImage* rightAccessoryImage = [UIImage imageNamed:@"DisclosureIndicator"];
		if(rightAccessoryImage != nil) {
			rightAccessoryImage = [UIImage imageWithShapeImage:rightAccessoryImage tintColor:self.label.textColor shadowColor:self.label.shadowColor shadowOffset:self.label.shadowOffset shadowBlur:0.0];
			rightAccessoryView = [[UIImageView alloc] initWithImage:rightAccessoryImage];
			rightAccessoryView.contentMode = UIViewContentModeCenter;
		}
	}
	self.rightAccessoryView = rightAccessoryView;

	if(self.item.tapHandler != NULL) {
		self.userInteractionEnabled = YES;
		if(self.tapRecognizer == nil) {
			self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTap:)];
		}
		[self addGestureRecognizer:self.tapRecognizer];
	} else {
		self.userInteractionEnabled = NO;
		if(self.tapRecognizer != nil) {
			[self removeGestureRecognizer:self.tapRecognizer];
		}
	}
	
//	CLogDebug(nil, @"syncToItem:%@ userInteractionEnabled:%d gestureRecognizers:%@", self.item, self.userInteractionEnabled, self.gestureRecognizers);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

	if(object == self) {
		if([keyPath isEqualToString:@"item"]) {
			[self syncToItem];
		}
	}
}

- (void)didRecognizeTap:(UITapGestureRecognizer*)sender
{
	if(sender.state == UIGestureRecognizerStateEnded) {
		if(self.item.tapHandler != NULL) {
			self.item.tapHandler();
		}
	}
}

@end
