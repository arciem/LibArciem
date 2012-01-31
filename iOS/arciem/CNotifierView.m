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

#import "CNotifierView.h"
#import "UIViewUtils.h"
#import "UIColorUtils.h"
#import "CGUtils.h"
#import "UIImageUtils.h"

@interface CNotifierView ()

@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UIImageView* backgroundImageView;
@property (strong, nonatomic) UIView* rightAccessoryView;

@end

@implementation CNotifierView

@synthesize item = item_;
@synthesize label = label_;
@synthesize backgroundImageView = backgroundImageView_;
@synthesize rightAccessoryView = rightAccessoryView_;

- (void)setup
{
	[super setup];
	
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
	self.backgroundImageView.alpha = 0.8;
	[self addSubview:self.backgroundImageView];
	
	self.label = [[UILabel alloc] initWithFrame:self.bounds];
	self.label.flexibleLeft = self.boundsLeft + 20;
	self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.label.opaque = NO;
	self.label.backgroundColor = [UIColor clearColor];
	self.label.font = [UIFont boldSystemFontOfSize:14.0];
	self.label.textAlignment = UITextAlignmentCenter;
	self.label.adjustsFontSizeToFitWidth = YES;
	self.label.minimumFontSize = 10.0;
	self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:self.label];
	
	[self addObserver:self forKeyPath:@"item" options:0 context:NULL];

	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTap:)];
	[self addGestureRecognizer:tapRecognizer];
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
			rightAccessoryView_.top = self.boundsTop;
			rightAccessoryView_.flexibleBottom = self.boundsBottom;
			rightAccessoryView_.width = 30;
			rightAccessoryView_.right = self.boundsRight;
			[self addSubview:rightAccessoryView_];
			
			self.label.flexibleRight = rightAccessoryView_.left;
		} else {
			self.label.flexibleRight = self.boundsRight;
		}
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
		self.label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
		self.label.shadowOffset = CGSizeMake(0, -1);
	} else {
		self.label.textColor = [UIColor blackColor];
		self.label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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
