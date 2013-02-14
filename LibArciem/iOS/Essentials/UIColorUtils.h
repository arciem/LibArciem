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
+ (UIColor*)colorWithString:(NSString*)str; // @"0.5 0.7 0.3 1.0" or @"0.5 0.7 0.3"

+ (UIColor*)systemNavigationBlue;
+ (UIColor*)systemHighlightBlue;
+ (UIColor*)systemDoneButtonBlue;

+ (UIColor*)systemNavigationGray;
+ (UIColor*)systemHighlightGray;

+ (UIImage*)diagonalRight:(BOOL)right patternImageWithColor1:(UIColor*)color1 color2:(UIColor*)color2 size:(CGSize)size scale:(CGFloat)scale;
+ (UIColor*)diagonalRight:(BOOL)right patternColorWithColor1:(UIColor*)color1 color2:(UIColor*)color2 size:(CGSize)size scale:(CGFloat)scale;

- (UIColor*)colorByInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)colorByCircularInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)colorByCircularInterpolatingToHue:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)colorByOffsettingHue:(CGFloat)offset;
- (UIColor*)colorByDarkeningFraction:(CGFloat)fraction;
- (UIColor*)colorByLighteningFraction:(CGFloat)fraction;
- (UIColor*)colorByColorBurnFraction:(CGFloat)fraction;
- (UIColor*)colorByColorDodgeFraction:(CGFloat)fraction;
- (UIColor*)colorByDeepeningFraction:(CGFloat)fraction;
- (UIColor*)colorBySaturatingFraction:(CGFloat)fraction;
- (UIColor*)colorByDesaturatingFraction:(CGFloat)fraction;

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;
- (CGFloat)hue;
- (CGFloat)saturation;
- (CGFloat)brightness;
- (CGFloat)luminance;

- (UIColor*)colorWithRed:(CGFloat)red;
- (UIColor*)colorWithGreen:(CGFloat)green;
- (UIColor*)colorWithBlue:(CGFloat)blue;
- (UIColor*)colorWithAlpha:(CGFloat)alpha;
- (UIColor*)colorWithHue:(CGFloat)hue;
- (UIColor*)colorWithSaturation:(CGFloat)saturation;
- (UIColor*)colorWithBrightness:(CGFloat)brightness;

- (UIColor*)tintColorVariantForButtonHighlighted:(BOOL)highlighted;

@end
