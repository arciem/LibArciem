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

#import "CDisclosureIndicator.h"

@interface CDisclosureIndicator ()

@end

@implementation CDisclosureIndicator

+ (CDisclosureIndicator *)disclosureIndicatorWithColor:(UIColor*)color highlightColor:(UIColor*)highlightColor {
    CDisclosureIndicator* indicator = [[CDisclosureIndicator alloc] initWithFrame:CGRectZero];
    indicator.color = color;
    indicator.highlightColor = highlightColor;
    return indicator;
}

- (id)initWithFrame:(CGRect)frame
{
    CGRect f = frame;
    f.size.width = 11;
    f.size.height = 15;
    if(self = [super initWithFrame:f]) {
        self.color = [UIColor blackColor];
        self.highlightColor = [UIColor whiteColor];
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	// (x,y) is the tip of the chevron
	CGFloat x = CGRectGetMaxX(self.bounds)-3.0;
	CGFloat y = CGRectGetMidY(self.bounds);
	const CGFloat R = 4.5;
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctxt, self.bounds);
	CGContextMoveToPoint(ctxt, x-R, y-R);
	CGContextAddLineToPoint(ctxt, x, y);
	CGContextAddLineToPoint(ctxt, x-R, y+R);
	CGContextSetLineCap(ctxt, kCGLineCapSquare);
	CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
	CGContextSetLineWidth(ctxt, 3);
    
	if (self.highlighted) {
        CGContextSetStrokeColorWithColor(ctxt, self.highlightColor.CGColor);
	} else {
        CGContextSetStrokeColorWithColor(ctxt, self.color.CGColor);
	}
    
	CGContextStrokePath(ctxt);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
