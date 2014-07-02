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
#import "DeviceUtils.h"
#import "UIImageUtils.h"

@interface CNotifierItemView ()

@property (nonatomic) UILabel* label;
@property (nonatomic) UIImageView* backgroundImageView;
@property (nonatomic) UIView* rightAccessoryView;
@property (nonatomic) UITapGestureRecognizer* tapRecognizer;

@end

@implementation CNotifierItemView

@synthesize rightAccessoryView = _rightAccessoryView;
@synthesize contentOffsetTop = _contentOffsetTop;

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
	self.label.font = [UIFont boldSystemFontOfSize:14.0];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.adjustsFontSizeToFitWidth = YES;
    self.label.minimumScaleFactor = 0.5;
	self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:self.label];
	
	[self addObserver:self forKeyPath:@"item" options:(NSKeyValueObservingOptions)0 context:NULL];
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"item"];
}

- (CGFloat)contentOffsetTop {
    return _contentOffsetTop;
}

- (void)setContentOffsetTop:(CGFloat)contentOffsetTop {
    _contentOffsetTop = contentOffsetTop;
    [self setNeedsLayout];
}

- (UIView*)rightAccessoryView
{
	return _rightAccessoryView;
}

- (void)setRightAccessoryView:(UIView *)rightAccessoryView
{
	if(_rightAccessoryView != rightAccessoryView) {
		[_rightAccessoryView removeFromSuperview];
		_rightAccessoryView = rightAccessoryView;
		if(_rightAccessoryView != nil) {
			[_rightAccessoryView sizeToFit];
			_rightAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
			[self addSubview:_rightAccessoryView];
		}

		[self setNeedsLayout];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CFrame* labelFrame = self.label.cframe;
	labelFrame.frame = self.bounds;
    labelFrame.flexibleTop += self.contentOffsetTop;
	labelFrame.flexibleLeft = self.boundsLeft + 10;
	labelFrame.flexibleRight = self.boundsRight - 10;
	labelFrame.top -= 1;

	if(self.rightAccessoryView != nil) {
		CFrame* rightAccessoryViewFrame = self.rightAccessoryView.cframe;
		rightAccessoryViewFrame.top = self.boundsTop + self.contentOffsetTop;
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
	
    CGFloat topEdgeWidth = 0.5;
    CGFloat bottomEdgeWidth = 0.5;
    
    topEdgeWidth = 0.0;
    
	CGRect topEdge, middle, bottomEdge;
	CGRectDivide(imageBounds, &topEdge, &middle, topEdgeWidth, CGRectMinYEdge);
	CGRectDivide(middle, &bottomEdge, &middle, bottomEdgeWidth, CGRectMaxYEdge);
	
	UIColor* tintColor = [self.item.tintColor colorWithAlphaComponent:1.0];
	UIColor* topColor = [tintColor newColorByLighteningFraction:0.3];
	UIColor* bottomColor = [[tintColor newColorByDarkeningFraction:0.3] newColorByColorBurnFraction:0.1];
	
    UIColor *color1, *color2;
    color1 = [tintColor newColorByLighteningFraction:0.1];
    color2 = [tintColor newColorByDarkeningFraction:0.1];

    CGContextRef context = [UIImage beginImageContextWithSize:imageBounds.size opaque:YES scale:0.0 flipped:NO];
    
	CGGradientRef gradient = GradientCreateWith2Colors(color1.CGColor, color2.CGColor, SharedColorSpaceDeviceRGB());
	ContextFillRectGradientVertical(context, imageBounds, gradient, NO);
	CGGradientRelease(gradient);
	
	[topColor set];
	UIRectFill(topEdge);

	[bottomColor set];
	UIRectFill(bottomEdge);

    UIImage *image = [UIImage endImageContext];
	return image;
}

- (void)syncToItem
{
	self.label.text = self.item.message;
	self.label.font = self.item.font;

	[self.backgroundImageView setImage:[self newImageForBackground]];

	if(self.item.whiteText) {
		self.label.textColor = [UIColor whiteColor];
	} else {
		self.label.textColor = [UIColor blackColor];
	}

	UIImageView* rightAccessoryView = nil;
	if(self.item.tapHandler != NULL) {
		UIImage* rightAccessoryImage = [UIImage imageNamed:@"DisclosureIndicator"];
		if(rightAccessoryImage != nil) {
			rightAccessoryImage = [UIImage newImageWithShapeImage:rightAccessoryImage tintColor:self.label.textColor shadowColor:self.label.shadowColor shadowOffset:self.label.shadowOffset shadowBlur:0.0];
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
