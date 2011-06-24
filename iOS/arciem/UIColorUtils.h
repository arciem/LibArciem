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

#import <UIKit/UIKit.h>
#import "CGUtils.h"

@interface UIColor(UIColorUtils)

+ (UIColor*)colorWithDenormalizedHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor*)colorWithRGBValue:(NSUInteger)rgbValue; //rrggbb eg. 0x3c001b

- (UIColor*)colorByInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)colorByCircularInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)colorByCircularInterpolatingToHue:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)colorByDarkeningFraction:(CGFloat)fraction;
- (UIColor*)colorByLighteningFraction:(CGFloat)fraction;

- (UIColor*)colorByHueSnappingFraction:(CGFloat)fraction;
- (UIColor*)colorByDeepeningFraction:(CGFloat)fraction;
- (UIColor*)colorBySaturatingFraction:(CGFloat)fraction;
- (UIColor*)closestCardinalColor;

//- (UIColor*)colorByHueSnapping:(CGFloat)snapFraction darkening:(CGFloat)darkFraction saturating:(CGFloat)satFraction;

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;
- (CGFloat)hue;
- (CGFloat)saturation;
- (CGFloat)brightness;

- (UIColor*)colorWithRed:(CGFloat)red;
- (UIColor*)colorWithGreen:(CGFloat)green;
- (UIColor*)colorWithBlue:(CGFloat)blue;
- (UIColor*)colorWithAlpha:(CGFloat)alpha;
- (UIColor*)colorWithHue:(CGFloat)hue;
- (UIColor*)colorWithSaturation:(CGFloat)saturation;
- (UIColor*)colorWithBrightness:(CGFloat)brightness;

- (void)tintColorVariant1:(UIColor**)outColor1 variant2:(UIColor**)outColor2;

@end
