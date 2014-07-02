//
//  CColorHSB.h
//  Arciem
//
//  Created by Robert McNally on 7/1/14.
//  Copyright (c) 2014 Arciem LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CColorHSB : NSObject

@property (readonly, nonatomic) CGFloat hue;
@property (readonly, nonatomic) CGFloat saturation;
@property (readonly, nonatomic) CGFloat brightness;
@property (readonly, nonatomic) CGFloat alpha;

- (instancetype)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (instancetype)newColorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

- (UIColor *)newUIColor;

@end
