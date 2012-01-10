//
//  CNotifierView.m
//  QP2
//
//  Created by Robert McNally on 1/9/12.
//  Copyright (c) 2012 QP Corp. All rights reserved.
//

#import "CNotifierView.h"
#import "UIViewUtils.h"
#import "UIColorUtils.h"
#import "CGUtils.h"

@interface CNotifierView ()

@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UIImageView* backgroundImageView;

@end

@implementation CNotifierView

@synthesize item = item_;
@synthesize label = label_;
@synthesize backgroundImageView = backgroundImageView_;

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
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"item"];
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self) {
		if([keyPath isEqualToString:@"item"]) {
			[self syncToItem];
		}
	}
}



@end
