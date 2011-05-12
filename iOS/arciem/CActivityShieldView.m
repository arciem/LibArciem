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

#import "CActivityShieldView.h"
#import "CGUtils.h"
#import "Geom.h"

@implementation CActivityShieldView

- (void)setup
{
	[super setup];
	
	self.contentMode = UIViewContentModeRedraw;
	self.userInteractionEnabled = NO;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	UIActivityIndicatorView* activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	activityIndicatorView.center = self.center;
	activityIndicatorView.frame = CGRectIntegral(activityIndicatorView.frame);
	[self addSubview:activityIndicatorView];
	[activityIndicatorView startAnimating];
	
//	self.debugColor = [UIColor whiteColor];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];

	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
		ContextFillShieldGradient(context, self.bounds);
		
		CGRect boxFrame = CGRectMake(0, 0, 100, 100);
		boxFrame = [Geom alignRectMid:boxFrame toRectMid:self.bounds];
		CGPathRef boxPath = CreateRoundedRectPath(boxFrame, 10, NO);
		CGContextAddPath(context, boxPath);
//		CGColorRef color = [UIColor colorWithRed:0.0 green:0.0 blue:0.4 alpha:0.5].CGColor;
		CGColorRef color = [UIColor colorWithHue:(214.0 / 360.0) saturation:1.0 brightness:0.3 alpha:0.6].CGColor;
		CGContextSetFillColorWithColor(context, color);
		CGContextFillPath(context);
		CGPathRelease(boxPath);
	CGContextRestoreGState(context);
}

- (void)dealloc {
    [super dealloc];
}


@end
