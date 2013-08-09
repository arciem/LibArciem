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

#import "CMiniPickerFrameView.h"
#import "UIColorUtils.h"
#import "UIViewUtils.h"

static const CGFloat kTopBevelHeight = 2.0;
static const CGFloat kFrameWidth = 8.0;

@interface CMiniPickerFrameView ()

@property (readwrite, nonatomic) UIEdgeInsets margins;
@property (readonly, nonatomic) CGGradientRef bevelGradientRef;
@property (readonly, nonatomic) CGGradientRef frameGradientRef;

@end

@implementation CMiniPickerFrameView

- (void)setup
{
    [super setup];
    self.userInteractionEnabled = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentMode = UIViewContentModeRedraw;
//    self.debugColor = [UIColor blueColor];
    self.margins = UIEdgeInsetsMake(kTopBevelHeight + kFrameWidth, kFrameWidth, kFrameWidth, kFrameWidth);
    
    _bevelGradientRef = GradientCreateWith2Colors(
                                                      [UIColor colorWithRGBValue:0x313944].CGColor,
                                                      [UIColor colorWithRGBValue:0xd7d7da].CGColor, SharedColorSpaceDeviceRGB());

    _frameGradientRef = GradientCreateGloss(
                                                [UIColor colorWithRGBValue:0xa2a3aa].CGColor,
                                                [UIColor colorWithRGBValue:0x484a55].CGColor,
                                                [UIColor colorWithRGBValue:0x3a3c4f].CGColor,
                                                [UIColor colorWithRGBValue:0x3a3d52].CGColor,
                                                SharedColorSpaceDeviceRGB());
}

- (void)dealloc
{
    CGGradientRelease(_frameGradientRef);
    CGGradientRelease(_bevelGradientRef);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGRect boundsRect = self.bounds;
    
    CGRect bevelRect;
    CGRectDivide(boundsRect, &bevelRect, &boundsRect, kTopBevelHeight, CGRectMinYEdge);
    ContextFillRectGradientVertical(context, bevelRect, self.bevelGradientRef);
    UIBezierPath* boundsPath = [UIBezierPath bezierPathWithRect:boundsRect];
    CGRect innerRect1 = UIEdgeInsetsInsetRect(self.bounds, self.margins);
    UIBezierPath* innerBoundsPath1 = [UIBezierPath bezierPathWithRoundedRect:innerRect1 cornerRadius:4.0];
    CGRect innerRect2 = CGRectInset(innerRect1, -1, -1);
    UIBezierPath* innerBoundsPath2 = [UIBezierPath bezierPathWithRoundedRect:innerRect2 cornerRadius:5.0];
    
    UIBezierPath* maskPath;
    
    maskPath = [UIBezierPath bezierPath];
    [maskPath appendPath:boundsPath];
    [maskPath appendPath:[innerBoundsPath2 pathByReversingPath]];
    ContextFillPathGradientVertical(context, maskPath.CGPath, self.frameGradientRef);
    
    maskPath = [UIBezierPath bezierPath];
    [maskPath appendPath:innerBoundsPath2];
    [maskPath appendPath:[innerBoundsPath1 pathByReversingPath]];
    ContextFillPathGradientVertical(context, maskPath.CGPath, self.frameGradientRef, YES);
    
    UIGraphicsPopContext();
}

@end
