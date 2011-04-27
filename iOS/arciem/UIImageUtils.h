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


@interface UIImage (UIImageUtils)

+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor text:(NSString*)text;
+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius;
+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor*)innerShadowColor;
+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor*)innerShadowColor shadowVerticalMultiplier:(NSInteger)shadowVerticalMultiplier;

- (UIImage*)reflectedImageWithHeight:(NSUInteger)height;

- (UIImage *)imageByColorizing:(UIColor *)theColor;

- (UIImage*)imageByScalingToSize:(CGSize)size;

- (UIImage*)imageByScalingToSize:(CGSize)inSize centeredWithinImageOfSize:(CGSize)imageSize backgroundColor:(UIColor*)backgroundColor;
- (UIImage*)imageByAspectFitToSize:(CGSize)imageSize backgroundColor:(UIColor*)backgroundColor;
- (UIImage*)imageByAspectFitToSize:(CGSize)imageSize;
- (UIImage*)imageByAspectFillToSize:(CGSize)imageSize backgroundColor:(UIColor*)backgroundColor;

- (UIImage*)imageWithRoundedCornerRadius:(CGFloat)radius;

- (UIImage*)imageAtScreenScale;

@end
