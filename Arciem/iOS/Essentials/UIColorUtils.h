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

+ (UIColor*)newColorWithDenormalizedHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor*)newColorWithRGBValue:(NSUInteger)rgbValue;     // rrggbb eg. 0x3c001b
+ (UIColor*)newColorWithRGBAValue:(NSUInteger)rgbaValue;   // rrggbbaa eg. 0x3c001bff
+ (UIColor*)newColorWithString:(NSString*)str; // @"0.5 0.7 0.3 1.0" or @"0.5 0.7 0.3"

+ (UIColor*)newRandomColor;

+ (UIColor*)systemNavigationBlue;
+ (UIColor*)systemHighlightBlue;
+ (UIColor*)systemDoneButtonBlue;

+ (UIColor*)systemNavigationGray;
+ (UIColor*)systemHighlightGray;

+ (UIImage*)newDiagonalRight:(BOOL)right patternImageWithColor1:(UIColor*)color1 color2:(UIColor*)color2 size:(CGSize)size scale:(CGFloat)scale;
+ (UIColor*)newDiagonalRight:(BOOL)right patternColorWithColor1:(UIColor*)color1 color2:(UIColor*)color2 size:(CGSize)size scale:(CGFloat)scale;

- (UIColor*)newColorByInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)newColorByCircularInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)newColorByCircularInterpolatingToHue:(UIColor*)color fraction:(CGFloat)fraction;
- (UIColor*)newColorByOffsettingHue:(CGFloat)offset;
- (UIColor*)newColorByDarkeningFraction:(CGFloat)fraction;
- (UIColor*)newColorByLighteningFraction:(CGFloat)fraction;
- (UIColor*)newColorByColorBurnFraction:(CGFloat)fraction;
- (UIColor*)newColorByColorDodgeFraction:(CGFloat)fraction;
- (UIColor*)newColorByDeepeningFraction:(CGFloat)fraction;
- (UIColor*)newColorBySaturatingFraction:(CGFloat)fraction;
- (UIColor*)newColorByDesaturatingFraction:(CGFloat)fraction;

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;
- (CGFloat)hue;
- (CGFloat)saturation;
- (CGFloat)brightness;
- (CGFloat)luminance;

- (UIColor*)newColorWithRed:(CGFloat)red;
- (UIColor*)newColorWithGreen:(CGFloat)green;
- (UIColor*)newColorWithBlue:(CGFloat)blue;
- (UIColor*)newColorWithAlpha:(CGFloat)alpha;
- (UIColor*)newColorWithHue:(CGFloat)hue;
- (UIColor*)newColorWithSaturation:(CGFloat)saturation;
- (UIColor*)newColorWithBrightness:(CGFloat)brightness;

- (UIColor*)newTintColorVariantForButtonHighlighted:(BOOL)highlighted;

@end
