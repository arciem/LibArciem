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

#import "CBeveledBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@interface CBeveledBackgroundView ()

@property(nonatomic) CALayer* topEdgeLayer;
@property(nonatomic) CAGradientLayer* gradientLayer;
@property(nonatomic) CALayer* bottomEdgeLayer;

@end

@implementation CBeveledBackgroundView

@synthesize topEdgeLayer;
@synthesize gradientLayer;
@synthesize bottomEdgeLayer;

- (void)setup
{
	[super setup];

	self.opaque = YES;
	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.topEdgeLayer = [CALayer layer];
	[self.layer addSublayer:self.topEdgeLayer];
	
	self.gradientLayer = [CAGradientLayer layer];
	[self.layer addSublayer:self.gradientLayer];
	
	self.bottomEdgeLayer = [CALayer layer];
	[self.layer addSublayer:self.bottomEdgeLayer];
}

- (void)dealloc
{
	self.topEdgeLayer = nil;
	self.gradientLayer = nil;
	self.bottomEdgeLayer = nil;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect gradientFrame = self.bounds;
	CGRect topEdgeFrame;
	CGRect bottomEdgeFrame;
	CGRectDivide(gradientFrame, &topEdgeFrame, &gradientFrame, 1.0, CGRectMinYEdge);
	CGRectDivide(gradientFrame, &bottomEdgeFrame, &gradientFrame, 1.0, CGRectMaxYEdge);
	
	self.topEdgeLayer.frame = topEdgeFrame;
	self.topEdgeLayer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0].CGColor;
	
	
	self.gradientLayer.frame = gradientFrame;
	self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0.9 alpha:1.0].CGColor,
								 (__bridge id)[UIColor colorWithWhite:0.8 alpha:1.0].CGColor];
	
	
	self.bottomEdgeLayer.frame = bottomEdgeFrame;
	self.bottomEdgeLayer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
}

@end
