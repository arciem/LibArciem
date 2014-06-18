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

+ (CGContextRef)beginImageContextWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale flipped:(BOOL)flipped;
+ (UIImage *)endImageContext NS_RETURNS_RETAINED;

+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor;
//+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor text:(NSString*)text;
+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor *)innerShadowColor;
+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor *)innerShadowColor shadowVerticalMultiplier:(NSInteger)shadowVerticalMultiplier;
+ (UIImage *)newEmbossedImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor;
+ (UIImage *)newEmbossedImageWithShapeImage:(UIImage *)shapeImage backgroundImage:(UIImage *)backgroundImage;
+ (UIImage *)newEtchedImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor glossAlpha:(CGFloat)glossAlpha;
+ (UIImage *)newEtchedImageWithShapeImage:(UIImage *)shapeImage backgroundImage:(UIImage *)backgroundImage glossAlpha:(CGFloat)glossAlpha;
+ (UIImage *)newEtchedButtonImageWithSize:(CGSize)size scale:(CGFloat)scale tintColor:(UIColor *)tintColor cornerRadius:(CGFloat)cornerRadius glossAlpha:(CGFloat)glossAlpha;
+ (UIImage *)newEtchedButtonWithBackgroundImage:(UIImage *)backgroundImage cornerRadius:(CGFloat)cornerRadius glossAlpha:(CGFloat)glossAlpha;
+ (UIImage *)newImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur;
+ (UIImage *)newImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor;
+ (UIImage *)newNavigationBarImageWithBackgroundPatternImage:(UIImage *)patternImage glossAlpha:(CGFloat)glossAlpha;
+ (UIImage *)newNavigationBarImageWithBackgroundPatternImage:(UIImage *)patternImage;
+ (UIImage *)newToolbarImageWithBackgroundPatternImage:(UIImage *)patternImage toolbarPosition:(UIToolbarPosition)position glossAlpha:(CGFloat)glossAlpha;
+ (UIImage *)newToolbarImageWithBackgroundPatternImage:(UIImage *)patternImage toolbarPosition:(UIToolbarPosition)position;

- (UIImage *)newReflectedImageWithHeight:(NSUInteger)height;
- (UIImage *)newImageByColorizing:(UIColor *)theColor;
- (UIImage *)newImageByDesaturating:(CGFloat)desaturation;
- (UIImage *)newImageByMaskingWithImage:(UIImage *)shapeImage;
- (UIImage *)newImageByScalingToSize:(CGSize)size;
- (UIImage *)newImageByScalingToSize:(CGSize)inSize centeredWithinImageOfSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor;
- (UIImage *)newImageByAspectFitToSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor;
- (UIImage *)newImageByAspectFitToSize:(CGSize)imageSize;
- (UIImage *)newImageByAspectFillToSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor;
- (UIImage *)newImageWithRoundedCornerRadius:(CGFloat)radius;
- (UIImage *)newImageAtScreenScale;
- (UIImage *)newImageForDarkBar:(BOOL)darkBar;

@end
