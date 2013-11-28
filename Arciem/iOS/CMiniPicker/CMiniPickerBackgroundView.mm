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

#import "CMiniPickerBackgroundView.h"
#import "CGUtils.h"
#import "UIColorUtils.h"
#import "DeviceUtils.h"

@interface CMiniPickerBackgroundView ()

@end

@implementation CMiniPickerBackgroundView

@synthesize underlayRect = _underlayRect;

- (void)setup
{
    [super setup];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentMode = UIViewContentModeRedraw;
    if(IsOSVersionAtLeast7()) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    }
}

- (CGRect)underlayRect
{
    return _underlayRect;
}

- (void)setUnderlayRect:(CGRect)underlayRect
{
    _underlayRect = underlayRect;
    [self setNeedsDisplay];
}

- (void)context:(CGContextRef)context drawSlotAtX:(CGFloat)x leftSide:(BOOL)leftSide
{
    CGRect whiteRect, blackRect, grayRect;
    grayRect.size.width = 5.0;
    CGRect bounds = self.bounds;
    grayRect.size.height = bounds.size.height;
    grayRect.origin.y = bounds.origin.y;
    if(leftSide) {
        grayRect.origin.x = x;
        CGRectDivide(grayRect, &blackRect, &grayRect, 1.0, CGRectMinXEdge);
        CGRectDivide(grayRect, &whiteRect, &grayRect, 1.0, CGRectMaxXEdge);
    } else {
        grayRect.origin.x = x - grayRect.size.width;
        CGRectDivide(grayRect, &blackRect, &grayRect, 1.0, CGRectMaxXEdge);
        CGRectDivide(grayRect, &whiteRect, &grayRect, 1.0, CGRectMinXEdge);
    }
    ContextFillRectColor(context, blackRect, [UIColor blackColor].CGColor);
    ContextFillRectColor(context, grayRect, [UIColor colorWithRGBValue:0xcbccdd].CGColor);
    ContextFillRectColor(context, whiteRect, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if(!IsOSVersionAtLeast7()) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //    ContextFillRectColor(context, self.bounds, SharedBlackColor());
        ContextFillRectColor(context, self.bounds, self.backgroundColor.CGColor);
        
        CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.margins);
        [self context:context drawSlotAtX:CGRectGetMinX(bounds) leftSide:YES];
        [self context:context drawSlotAtX:CGRectGetMaxX(bounds) leftSide:NO];
        
        CGContextSetBlendMode(context, kCGBlendModeMultiply);
        ContextFillRectColor(context, self.underlayRect, [UIColor colorWithRGBValue:0xa0aac5].CGColor);
    }
}

@end
