//
//  CColorHSB.m
//  Arciem
//
//  Created by Robert McNally on 7/1/14.
//  Copyright (c) 2014 Arciem LLC. All rights reserved.
//

#import "CColorHSB.h"

@implementation CColorHSB

@synthesize hue = _hue;
@synthesize saturation = _saturation;
@synthesize brightness = _brightness;
@synthesize alpha = _alpha;

- (instancetype)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
    if(self = [super init]) {
        _hue = hue;
        _saturation = saturation;
        _brightness = brightness;
        _alpha = alpha;
    }
    return self;
}

+ (instancetype)newColorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
    return [[CColorHSB alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (UIColor *)newUIColor {
    CGFloat r, g, b;
    CGFloat v = self.brightness;
    if(self.saturation == 0.0) {
        r = g = b = v;
    } else {
        CGFloat h = self.hue;
        CGFloat s = self.saturation;
        if(h == 1.0) h = 0.0;
        h *= 6.0;
        int i = (int)(floor(h));
        CGFloat f = h - i;
        CGFloat p = v * (1.0 - s);
        CGFloat q = v * (1.0 - (s * f));
        CGFloat t = v * (1.0 - (s * (1.0 - f)));
        switch(i) {
            default:
            case 0: r = v; g = t; b = p; break;
            case 1: r = q; g = v; b = p; break;
            case 2: r = p; g = v; b = t; break;
            case 3: r = p; g = q; b = v; break;
            case 4: r = t; g = p; b = v; break;
            case 5: r = v; g = p; b = q; break;
        }
    }
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:self.alpha];
    return color;
}

@end
