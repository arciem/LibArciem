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
#import "DeviceUtils.h"
#import "CColorHSB.h"

@interface CMiniPickerOverlayView ()

@property (readonly, nonatomic) CGGradientRef glossGradient;
@property (readonly, nonatomic) CGColorRef bevelColor1;
@property (readonly, nonatomic) CGColorRef bevelColor2;
@property (readonly, nonatomic) CGGradientRef shadowGradient;
@property (readonly, nonatomic) CGGradientRef shadeGradientRef;

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
    CColorHSB *baseColorHSB = [CColorHSB newColorWithHue:240.0/360 saturation:0.1 brightness:0.1 alpha:1.0];
    CGColorRef *colorValues = malloc(sizeof(CGColorRef) * steps);
    for(NSUInteger step = 0; step < steps; step++) {
        CGFloat alpha = alphas[step];
        CColorHSB *colorHSB = [CColorHSB newColorWithHue:baseColorHSB.hue saturation:baseColorHSB.saturation brightness:baseColorHSB.brightness alpha:alpha];
        UIColor *colorRGB = [colorHSB newUIColor];
        CGFloat components[4];
        [colorRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
        colorValues[step] = CGColorCreate(SharedColorSpaceDeviceRGB(), components);
    }
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)colorValues, steps, NULL);
    CGGradientRef gradient = CGGradientCreateWithColors(SharedColorSpaceDeviceRGB(), colors, NULL);
    CFRelease(colors);
    
    for(NSUInteger step = 0; step < steps; step++) {
        CGColorRelease(colorValues[step]);
    }
    free(colorValues);
    
    return gradient;
}

- (void)setup
{
    [super setup];
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentMode = UIViewContentModeRedraw;
    
    _glossGradient = GradientCreateGloss([UIColor colorWithWhite:1.0 alpha:0.8].CGColor,
                                         [UIColor colorWithWhite:1.0 alpha:0.2].CGColor,
                                         [UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                         [UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                         SharedColorSpaceDeviceGray());
    
    _shadowGradient = GradientCreateEaseOut([UIColor colorWithWhite:0.0 alpha:0.6].CGColor,
                                            [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                            SharedColorSpaceDeviceGray(), 20);
    
    _shadeGradientRef = GradientCreateSine(
                                           [UIColor colorWithWhite:1.0 alpha:0.9].CGColor,
                                           [UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                           SharedColorSpaceDeviceGray(),
                                           30, 2);
    
    _bevelColor1 = CGColorRetain([UIColor colorWithWhite:0.0 alpha:0.07].CGColor);
    _bevelColor2 = CGColorRetain([UIColor colorWithWhite:0.0 alpha:0.07].CGColor);
}

- (void)dealloc
{
    CGColorRelease(_bevelColor1);
    CGColorRelease(_bevelColor2);
    CGGradientRelease(_glossGradient);
    CGGradientRelease(_shadowGradient);
    CGGradientRelease(_shadeGradientRef);
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
    
    CGContextRef context = UIGraphicsGetCurrentContextChecked();
    
    CGRect glossRect = self.overlayRect;
    CGRect bevelRectTop1, bevelRectTop2, bevelRectBottom;
    CGRectDivide(glossRect, &bevelRectTop1, &glossRect, 1.0, CGRectMinYEdge);
    CGRectDivide(glossRect, &bevelRectTop2, &glossRect, 1.0, CGRectMinYEdge);
    CGRectDivide(glossRect, &bevelRectBottom, &glossRect, 1.0, CGRectMaxYEdge);

    CGRect shadeBounds = UIEdgeInsetsInsetRect(self.bounds, self.margins);

    CGRect upperRect = shadeBounds;
    upperRect.size.height = CGRectGetMinY(bevelRectTop1) - CGRectGetMinY(shadeBounds);
    CGRect lowerRect = shadeBounds;
    lowerRect.size.height = CGRectGetMaxY(shadeBounds) - CGRectGetMaxY(bevelRectBottom);
    lowerRect.origin.y = CGRectGetMaxY(bevelRectBottom);
    ContextFillRectColor(context, upperRect, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
    ContextFillRectColor(context, lowerRect, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
    
    ContextFillRectGradientVertical(context, shadeBounds, self.shadeGradientRef, NO);

    CGContextSetStrokeColorWithColor(context, self.bevelColor1);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, shadeBounds);

    ContextFillRectColor(context, bevelRectTop1, self.bevelColor1);
    ContextFillRectColor(context, bevelRectBottom, self.bevelColor2);
}

@end