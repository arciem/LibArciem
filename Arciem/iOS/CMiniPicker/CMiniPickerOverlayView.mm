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

#import "CMiniPickerOverlayView.h"
#import "CGUtils.h"
#import "UIColorUtils.h"
#import "UIViewUtils.h"
#include "gl_utils.hpp"

@interface CMiniPickerOverlayView ()

@property (nonatomic) CGGradientRef glossGradient;
@property (nonatomic) CGColorRef bevelColor1;
@property (nonatomic) CGColorRef bevelColor2;
@property (nonatomic) CGGradientRef shadowGradient;
@property (nonatomic) CGGradientRef shadeGradientRef;

@end

@implementation CMiniPickerOverlayView

@synthesize overlayRect = _overlayRect;

- (CGGradientRef)createShadeGradient
{
    static CGFloat alphas[] = {0.780392, 0.673776, 0.551896, 0.437394, 0.339969, 0.268047, \
        0.203282, 0.151201, 0.117359, 0.0829804, 0.0562824, 0.036549, \
        0.027451, 0.0232782, 0.0223257, 0.0196078, 0.0156863, 0.0156863, \
        0.0117647, 0.0124446, 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., \
        0., 0., 0., 0.0416, 0.0614902, 0.084549, 0.107646, 0.132109, \
        0.157898, 0.180694, 0.207454, 0.244345, 0.293932, 0.347169, 0.401001, \
        0.485942, 0.576857, 0.670063, 0.764706};
    static NSUInteger steps = sizeof(alphas)/sizeof(CGFloat);
    arciem::color_hsb baseColorHSB(240.0/360, 0.1, 0.1, 1.0);
    CGColorRef *colorValues = new CGColorRef[steps];
    for(NSUInteger step = 0; step < steps; step++) {
        CGFloat alpha = alphas[step];
        arciem::color_hsb colorHSB(baseColorHSB);
        colorHSB.a = alpha;
        arciem::color colorRGB(colorHSB);
        CGFloat components[4];
        components[0] = colorRGB.r;
        components[1] = colorRGB.g;
        components[2] = colorRGB.b;
        components[3] = colorRGB.a;
        colorValues[step] = CGColorCreate(SharedColorSpaceDeviceRGB(), components);
    }
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)colorValues, steps, NULL);
    CGGradientRef gradient = CGGradientCreateWithColors(SharedColorSpaceDeviceRGB(), colors, NULL);
    CFRelease(colors);
    
    for(NSUInteger step = 0; step < steps; step++) {
        CGColorRelease(colorValues[step]);
    }
    delete[] colorValues;
    
    return gradient;
}

- (void)setup
{
    [super setup];
    self.userInteractionEnabled = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentMode = UIViewContentModeRedraw;
    
    self.glossGradient = GradientCreateGloss([UIColor colorWithWhite:1.0 alpha:0.8].CGColor,
                                             [UIColor colorWithWhite:1.0 alpha:0.2].CGColor,
                                             [UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                             [UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                             SharedColorSpaceDeviceGray());
    
    self.shadowGradient = GradientCreateEaseOut([UIColor colorWithWhite:0.0 alpha:0.6].CGColor,
                                                    [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                                    SharedColorSpaceDeviceGray(), 20);

    self.shadeGradientRef = [self createShadeGradient];
//    self.shadeGradientRef = GradientCreateSine(
//                                               [UIColor colorWithWhite:0.0 alpha:0.9].CGColor,
//                                               [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
//                                               SharedColorSpaceDeviceGray(),
//                                               30, 0.5);
    
    self.bevelColor1 = CGColorRetain([UIColor colorWithRGBValue:0x7a8696].CGColor);
    self.bevelColor2 = CGColorRetain([UIColor colorWithRGBValue:0xecedf2].CGColor);
}

- (void)dealloc
{
    CGColorRelease(self.bevelColor1);
    CGColorRelease(self.bevelColor2);
    CGGradientRelease(self.glossGradient);
    CGGradientRelease(self.shadowGradient);
    CGGradientRelease(self.shadeGradientRef);
}

- (CGRect)overlayRect
{
    return _overlayRect;
}

- (void)setOverlayRect:(CGRect)overlayRect
{
    _overlayRect = overlayRect;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect shadeBounds = UIEdgeInsetsInsetRect(self.bounds, self.margins);
    ContextFillRectGradientVertical(context, shadeBounds, self.shadeGradientRef);

    CGRect glossRect = self.overlayRect;
    CGRect bevelRectTop1, bevelRectTop2, bevelRectBottom;
    CGRectDivide(glossRect, &bevelRectTop1, &glossRect, 1.0, CGRectMinYEdge);
    CGRectDivide(glossRect, &bevelRectTop2, &glossRect, 1.0, CGRectMinYEdge);
    CGRectDivide(glossRect, &bevelRectBottom, &glossRect, 1.0, CGRectMaxYEdge);
    ContextFillRectColor(context, bevelRectTop1, self.bevelColor1);
    ContextFillRectColor(context, bevelRectTop2, self.bevelColor2);
    ContextFillRectGradientVertical(context, glossRect, self.glossGradient);
    ContextFillRectColor(context, bevelRectBottom, self.bevelColor1);

    CFrame* shadowFrame = [CFrame new];
    shadowFrame.frame = self.overlayRect;
    shadowFrame.top = shadowFrame.bottom;
    shadowFrame.height = 20.0;
    ContextFillRectGradientVertical(context, shadowFrame.frame, self.shadowGradient);
}

@end
