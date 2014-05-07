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

#import "UIImageUtils.h"
#import "CGUtils.h"
#import "Geom.h"
#import "DeviceUtils.h"
#import "UIColorUtils.h"
#include "math_utils.hpp"

@implementation UIImage (UIImageUtils)

+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor
{
	UIImage* resultImage = nil;
	
    CGContextRef context = [UIImage beginImageContextWithSize:size opaque:NO scale:scale flipped:NO];
    
	CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
	CGRect bounds = {CGPointZero, size};
	CGContextFillRect(context, bounds);
	
    resultImage = [UIImage endImageContext];
	
	return resultImage;
}

+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor text:(NSString*)text
{
	UIImage* uiImage = nil;
	
	CGContextRef context = BitmapContextCreate(size, YES);
	if(context != NULL) {
		UIGraphicsPushContext(context);
			CGRect rect = CGRectMake(0, 0, size.width, size.height);

			[backgroundColor set];
			//CGContextSetFillColorWithColor(context, backgroundColor);
			CGContextFillRect(context, rect);
			//DrawCrossedBox(context, rect, [[UIColor redColor] cgColor], 1.0, true);
	
			UIFont* font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
			[textColor set];
			CGFloat actualFontSize;
			CGSize stringSize = [text sizeWithFont:font minFontSize:[UIFont smallSystemFontSize] actualFontSize:&actualFontSize forWidth:size.width lineBreakMode:NSLineBreakByTruncatingTail];
			CGPoint p = CGPointMake((size.width - stringSize.width) / 2, (size.height - stringSize.height) / 2);
			[text drawAtPoint:p forWidth:size.width withFont:font minFontSize:[UIFont smallSystemFontSize] actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentNone];
		
		UIGraphicsPopContext();
		
		CGImageRef image = CGBitmapContextCreateImage(context);

		BitmapContextFreeData(context);
		CGContextRelease(context);

		uiImage = [[UIImage alloc] initWithCGImage:image];
		
		CGImageRelease(image);
	}
	
	return uiImage;
}

+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor *)innerShadowColor shadowVerticalMultiplier:(NSInteger)shadowVerticalMultiplier
{
	UIImage* uiImage = nil;
	
	CGRect bounds = CGRectMake(0, 0, size.width * scale, size.height * scale);
	CGContextRef context = BitmapContextCreate(bounds.size, NO);
	if(context != NULL) {
		UIGraphicsPushContext(context);
			CGContextClearRect(context, bounds);
			CGFloat scaledCornerRadius = scale * cornerRadius;
			CGPathRef path = CreateRoundedRectPath(bounds, scaledCornerRadius, NO);
			[backgroundColor set];
			CGContextAddPath(context, path);
			CGContextClip(context);
			CGContextFillRect(context, bounds);

			if(innerShadowColor != nil) {
				// draw outline
				CGContextSetStrokeColorWithColor(context, innerShadowColor.CGColor);
				CGContextSetLineWidth(context, 0.25 * scale);
				CGContextAddPath(context, path);
				CGContextStrokePath(context);

				// draw inner shadow
				CGRect r1 = CGRectInset(bounds, -20 * scale, -20 * scale);
//				CLogDebug(nil, @"r1:%@", NSStringFromCGRect(r1));
				CGMutablePathRef path1 = CGPathCreateMutable();
				CGPathAddRect(path1, nil, r1);
				CGPathRef path2 = CreateRoundedRectPath(CGRectInset(bounds, -0.5 * scale, -0.5 * scale), scaledCornerRadius, NO);
				CGMutablePathRef path3 = CGPathCreateMutable();
				CGPathAddPath(path3, nil, path1);
				CGPathAddPath(path3, nil, path2);
				[[UIColor blackColor] set];
				CGSize offset = CGSizeMake(0, 2 * scale * shadowVerticalMultiplier);
				CGFloat blur = 2 * scale;
				CGContextSetShadowWithColor(context, offset, blur, innerShadowColor.CGColor);
				CGContextAddPath(context, path3);
				CGContextEOFillPath(context);

				CGPathRelease(path1);
				CGPathRelease(path2);
				CGPathRelease(path3);
			}
			
			CGPathRelease(path);

		UIGraphicsPopContext();

		CGImageRef image = CGBitmapContextCreateImage(context);

		BitmapContextFreeData(context);
		CGContextRelease(context);

		if(scale > 1.0) {
			uiImage = [[UIImage alloc] initWithCGImage:image scale:scale orientation:UIImageOrientationUp];
		} else {
			uiImage = [[UIImage alloc] initWithCGImage:image];
		}

		CGImageRelease(image);
	}

	return uiImage;
}

+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor *)innerShadowColor
{
	return [self newImageWithSize:size scale:scale backgroundColor:backgroundColor cornerRadius:cornerRadius innerShadowColor:innerShadowColor shadowVerticalMultiplier:1];
}

+ (UIImage *)newImageWithSize:(CGSize)size scale:(CGFloat)scale backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius
{
	UIColor* innerShadowColor = [[UIColor blackColor] colorWithAlphaComponent:1.0 / 3.0];
	return [self newImageWithSize:size scale:scale backgroundColor:backgroundColor cornerRadius:cornerRadius innerShadowColor:innerShadowColor];
}

- (UIImage *)newReflectedImageWithHeight:(NSUInteger)height
{
	CGImageRef reflectionImage = ReflectedImageCreate(self.CGImage, height);
	UIImage *image = [UIImage imageWithCGImage:reflectionImage];
	CGImageRelease(reflectionImage);
	
	return image;
}

- (UIImage *)newImageByMaskingWithImage:(UIImage *)shapeImage
{
    UIImage* image = nil;
    
    CGRect bounds = CGRectZero;
    bounds.size = shapeImage.size;

    UIImage* flatShapeImage = [shapeImage flattenShapeImage];

	CGImageRef shapeStencil = CGImageMaskCreate(CGImageGetWidth(flatShapeImage.CGImage), CGImageGetHeight(flatShapeImage.CGImage), CGImageGetBitsPerComponent(flatShapeImage.CGImage), CGImageGetBitsPerPixel(flatShapeImage.CGImage), CGImageGetBytesPerRow(flatShapeImage.CGImage), CGImageGetDataProvider(flatShapeImage.CGImage), NULL, false);

    CGContextRef context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:YES];
    CGContextClipToMask(context, bounds, shapeStencil);
    CGContextDrawImage(context, bounds, self.CGImage);
    CGImageRelease(shapeStencil);
	image = [UIImage endImageContext];

    return image;
}

- (UIImage *)newImageByColorizing:(UIColor *)theColor
{
    CGContextRef ctx = [UIImage beginImageContextWithSize:self.size opaque:NO scale:self.scale flipped:YES];

    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
 
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, self.CGImage);
 
    UIImage *newImage = [UIImage endImageContext];
    return newImage;
}

- (UIImage *)newImageByDesaturating:(CGFloat)desaturation
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciimage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:ciimage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:desaturation] forKey:@"inputSaturation"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    UIImage* image = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return image;
}

- (UIImage *)newImageByScalingToSize:(CGSize)size
{
	UIImage* result = nil;
	
	UIGraphicsBeginImageContextWithOptions( size, NO, self.scale );
		[self drawInRect:CGRectMake( 0, 0, size.width, size.height )];
		result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

- (UIImage *)newImageByScalingToSize:(CGSize)inSize centeredWithinImageOfSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor
{
	UIImage* result = nil;
	
    CGContextRef context = [UIImage beginImageContextWithSize:imageSize opaque:NO scale:self.scale flipped:NO];
    
    CGRect bounds;
    bounds.origin = CGPointZero;
    bounds.size = imageSize;
    
    if(backgroundColor != nil) {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, bounds);
    }
    
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = inSize;
    frame = [Geom alignRectMid:frame toRectMid:bounds];

    [self drawInRect:frame];
    
    result = [UIImage endImageContext];
	
	return result;
}

- (UIImage *)newImageByAspectFitToSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor
{
	CGSize inSize = [Geom aspectFitSize:self.size withinSize:imageSize];
	return [self newImageByScalingToSize:inSize centeredWithinImageOfSize:imageSize backgroundColor:backgroundColor];
}

- (UIImage *)newImageByAspectFitToSize:(CGSize)imageSize
{
	CGSize inSize = [Geom aspectFitSize:self.size withinSize:imageSize];
	return [self newImageByScalingToSize:inSize];
}

- (UIImage *)newImageByAspectFillToSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor
{
	CGSize inSize = [Geom aspectFillSize:self.size withinSize:imageSize];
	return [self newImageByScalingToSize:inSize centeredWithinImageOfSize:imageSize backgroundColor:backgroundColor];
}

- (UIImage *)newImageWithRoundedCornerRadius:(CGFloat)radius
{
	UIImage* result = nil;

	CGRect r;
	r.origin = CGPointZero;
	r.size = self.size;
	CGPathRef path = CreateRoundedRectPath(r, radius, NO);

	UIGraphicsBeginImageContext( self.size );

		CGContextRef context = UIGraphicsGetCurrentContextChecked();

		CGContextSaveGState(context);

			CGContextAddPath(context, path);
			CGContextClip(context);
			[self drawInRect:CGRectMake( 0, 0, self.size.width, self.size.height )];

		CGContextRestoreGState(context);

		result = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();
	
	CGPathRelease(path);

	return result;
}

- (UIImage *)newImageAtScreenScale
{
	UIImage* image = self;
	CGFloat scale = ScreenScale();
	if(scale > 1.0) {
		image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
	}
	return image;
}

- (UIImage *)flattenShapeImage
{
	// Draw the shape image on a white background to get rid of any alpha channel
	UIImage* flatShapeImage = nil;
	CGRect bounds = {CGPointZero, self.size};

    CGContextRef context = [UIImage beginImageContextWithSize:self.size opaque:NO scale:self.scale flipped:NO];
    
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, bounds);
	[self drawAtPoint:CGPointZero];
	
    flatShapeImage = [UIImage endImageContext];
	
	return flatShapeImage;
}

+ (UIImage *)newImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor
{
	return [self newImageWithShapeImage:shapeImage tintColor:tintColor shadowColor:nil shadowOffset:CGSizeMake(0, 0) shadowBlur:0];
}

+ (UIImage *)newImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur
{
	UIImage* resultImage = nil;
	CGContextRef context = nil;
	CGRect bounds = {CGPointZero, shapeImage.size};
	
	UIImage* backgroundImage = [self newImageWithSize:shapeImage.size scale:shapeImage.scale backgroundColor:tintColor];
	
	// Draw the shape image on a white background to get rid of any alpha channel
	UIImage* flatShapeImage = [shapeImage flattenShapeImage];
	
	// Make a stencil that contains the shape we've been passed, drawn as a black silhouette on a white background
	CGImageRef shapeStencil = CGImageMaskCreate(CGImageGetWidth(flatShapeImage.CGImage), CGImageGetHeight(flatShapeImage.CGImage), CGImageGetBitsPerComponent(flatShapeImage.CGImage), CGImageGetBitsPerPixel(flatShapeImage.CGImage), CGImageGetBytesPerRow(flatShapeImage.CGImage), CGImageGetDataProvider(flatShapeImage.CGImage), NULL, false);
	
	// Create the context we'll be painting into for the tinted image
    context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:YES];
    
	// Paint the tinted shape
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextDrawImage(context, bounds, backgroundImage.CGImage);
	
	// Retrieve the tinted image
    UIImage *tintedImage = [UIImage endImageContext];

	if(shadowColor == nil) {
		resultImage = tintedImage;
	} else {
		// Create the main context we'll be painting into
        context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:YES];

		// Paint the tinted shape with a shadow
		CGContextSetShadowWithColor(context, shadowOffset, shadowBlur, shadowColor.CGColor);
		CGContextDrawImage(context, bounds, tintedImage.CGImage);

		// Retrieve the shadowed, tinted image
        resultImage = [UIImage endImageContext];
	}

	// Clean up
	CGImageRelease(shapeStencil);
	
	return resultImage;
}

+ (UIImage *)newEmbossedImageWithShapeImage:(UIImage *)shapeImage backgroundImage:(UIImage *)backgroundImage
{
	UIImage* resultImage = nil;
    
	CGContextRef context = nil;
    
    CGRect bounds = CGRectMake(0, 0, shapeImage.size.width, shapeImage.size.height);
    
	// Draw the shape image on a white background to get rid of any alpha channel
	UIImage* flatShapeImage = [shapeImage flattenShapeImage];
    
	// Make a stencil that contains the shape we've been passed, drawn as a black silhouette on a white background
	CGImageRef shapeStencil = CGImageMaskCreate(CGImageGetWidth(flatShapeImage.CGImage), CGImageGetHeight(flatShapeImage.CGImage), CGImageGetBitsPerComponent(flatShapeImage.CGImage), CGImageGetBitsPerPixel(flatShapeImage.CGImage), CGImageGetBytesPerRow(flatShapeImage.CGImage), CGImageGetDataProvider(flatShapeImage.CGImage), NULL, false);
	
	// Also make an inverted stencil
	CGFloat invertDecodeArray[] = {1.0, 0.0,  1.0, 0.0,  1.0, 0.0};
	CGImageRef invertedShapeStencil = CGImageMaskCreate(CGImageGetWidth(flatShapeImage.CGImage), CGImageGetHeight(flatShapeImage.CGImage), CGImageGetBitsPerComponent(flatShapeImage.CGImage), CGImageGetBitsPerPixel(flatShapeImage.CGImage), CGImageGetBytesPerRow(flatShapeImage.CGImage), CGImageGetDataProvider(flatShapeImage.CGImage), invertDecodeArray, false);
    
	// Create the main context we'll be painting into
    context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:YES];
    
    // Constraint all drawing to the basic shape
    CGContextClipToMask(context, bounds, shapeStencil);
    
	// Paint the tint colored shape
    CGRect backgroundDestRect = CGRectZero;
    backgroundDestRect.size = [Geom aspectFillSize:backgroundImage.size withinSize:shapeImage.size];
    backgroundDestRect = [Geom alignRectMid:backgroundDestRect toRectMid:bounds];
    CGContextDrawImage(context, backgroundDestRect, backgroundImage.CGImage);
    
	// Paint the dark, lower etching
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, 1.0);
	CGContextClipToMask(context, bounds, invertedShapeStencil);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.7].CGColor);
    CGContextFillRect(context, bounds);
	CGContextRestoreGState(context);
	
	// Paint the light, upper etching
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, -1.0);
	CGContextClipToMask(context, bounds, invertedShapeStencil);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.9].CGColor);
    CGContextFillRect(context, bounds);
	CGContextRestoreGState(context);
    
	// Retrieve the finished image
    resultImage = [UIImage endImageContext];
	
	// Clean up
	CGImageRelease(shapeStencil);
	CGImageRelease(invertedShapeStencil);
    
	return resultImage;
}

+ (UIImage *)newEmbossedImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor
{
    CGRect bounds = CGRectMake(0, 0, 10, 10);
    CGContextRef context = [UIImage beginImageContextWithSize:bounds.size opaque:YES scale:1 flipped:YES];

	// Paint the tint colored shape
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextFillRect(context, bounds);
    
	// Retrieve the finished image
    UIImage* backgroundImage = [UIImage endImageContext];
    
	return [self newEmbossedImageWithShapeImage:shapeImage backgroundImage:backgroundImage];
}

+ (UIImage *)newEtchedImageWithShapeImage:(UIImage *)shapeImage backgroundImage:(UIImage *)backgroundImage glossAlpha:(CGFloat)glossAlpha
{
	UIImage* resultImage = nil;
	CGContextRef context = nil;
	CGRect bounds = {CGPointZero, shapeImage.size};
	
	// Draw the shape image on a white background to get rid of any alpha channel
	UIImage* flatShapeImage = [shapeImage flattenShapeImage];
	
	// Make a stencil that contains the shape we've been passed, drawn as a black silhouette on a white background
	CGImageRef shapeStencil = CGImageMaskCreate(CGImageGetWidth(flatShapeImage.CGImage), CGImageGetHeight(flatShapeImage.CGImage), CGImageGetBitsPerComponent(flatShapeImage.CGImage), CGImageGetBitsPerPixel(flatShapeImage.CGImage), CGImageGetBytesPerRow(flatShapeImage.CGImage), CGImageGetDataProvider(flatShapeImage.CGImage), NULL, false);
	
	// Also make an inverted stencil
	CGFloat invertDecodeArray[] = {1.0, 0.0,  1.0, 0.0,  1.0, 0.0};
	CGImageRef invertedShapeStencil = CGImageMaskCreate(CGImageGetWidth(flatShapeImage.CGImage), CGImageGetHeight(flatShapeImage.CGImage), CGImageGetBitsPerComponent(flatShapeImage.CGImage), CGImageGetBitsPerPixel(flatShapeImage.CGImage), CGImageGetBytesPerRow(flatShapeImage.CGImage), CGImageGetDataProvider(flatShapeImage.CGImage), invertDecodeArray, false);
	
	// To create an inner shadow, first paint a black rectangle through the inverted stencil, to create a frisket
	UIImage* innerShadowFrisketImage = nil;
    context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:NO];
	CGContextClipToMask(context, bounds, invertedShapeStencil);
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, bounds);
    innerShadowFrisketImage = [UIImage endImageContext];
	
	// Now draw the frisket with shadow into a new transparent image, resulting in an inner shadow
	UIImage* innerShadowImage = nil;
    context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:NO];
	CGContextSetShadowWithColor(context, CGSizeZero, 1.0, [UIColor blackColor].CGColor);
	[innerShadowFrisketImage drawAtPoint:CGPointZero];
    innerShadowImage = [UIImage endImageContext];
	
	// Create a border image by repeatedly striking the inner shadow image with the darken blend mode
	UIImage* borderImage = nil;
    context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:NO];
	CGContextSetBlendMode(context, kCGBlendModeDarken);
	for(int i = 0; i < 10; i++) {
		[innerShadowImage drawAtPoint:CGPointZero];
	}
    borderImage = [UIImage endImageContext];
	
	// Create the main context we'll be painting into
    context = [UIImage beginImageContextWithSize:shapeImage.size opaque:NO scale:shapeImage.scale flipped:YES];
	
	// Paint the light, lower etching
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, -0.75);
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.25].CGColor);
	CGContextFillRect(context, bounds);
	CGContextRestoreGState(context);
	
	// Paint the tint colored shape
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextDrawImage(context, bounds, backgroundImage.CGImage);
	
	// Paint the gloss gradient
	if(glossAlpha > 0.0) {
		CGContextSaveGState(context);
		UIColor* glossColor1 = [UIColor colorWithWhite:0.6 alpha:1];
		UIColor* glossColor2 = [UIColor colorWithWhite:0.1 alpha:1];
		UIColor* glossColor3 = [UIColor colorWithWhite:0.0 alpha:1];
		UIColor* glossColor4 = [UIColor colorWithWhite:0.05 alpha:1];
		CGGradientRef gradient = GradientCreateGloss(glossColor4.CGColor, glossColor3.CGColor, glossColor2.CGColor, glossColor1.CGColor, SharedColorSpaceDeviceGray());
		CGContextSetBlendMode(context, kCGBlendModeScreen);
		CGContextSetAlpha(context, glossAlpha);
		ContextFillRectGradientVertical(context, bounds, gradient);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}

	// Paint the inner shadow on top of the shape
	CGContextSaveGState(context);
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextTranslateCTM(context, 0.0, -0.5);
	[borderImage drawInRect:bounds blendMode:kCGBlendModeDarken alpha:0.5];
	CGContextRestoreGState(context);

	// Paint the border
	[borderImage drawInRect:bounds blendMode:kCGBlendModeDarken alpha:0.2];
	
	// Retrieve the finished image
    resultImage = [UIImage endImageContext];
	
	// Clean up
	CGImageRelease(shapeStencil);
	CGImageRelease(invertedShapeStencil);
	
	return resultImage;
}

+ (UIImage *)newEtchedImageWithShapeImage:(UIImage *)shapeImage tintColor:(UIColor *)tintColor glossAlpha:(CGFloat)glossAlpha
{
	UIImage* resultImage = nil;
	
	UIImage* backgroundImage = [self newImageWithSize:shapeImage.size scale:shapeImage.scale backgroundColor:tintColor];
	resultImage = [self newEtchedImageWithShapeImage:shapeImage backgroundImage:backgroundImage glossAlpha:glossAlpha];

	return resultImage;
}

// CLogDebug(nil, @"image:%@ scale:%f image2:%@ scale:%f", NSStringFromCGSize(image.size), image.scale, NSStringFromCGSize(image2.size), image2.scale);

+ (UIImage *)newEtchedButtonWithBackgroundImage:(UIImage *)backgroundImage cornerRadius:(CGFloat)cornerRadius glossAlpha:(CGFloat)glossAlpha
{
	UIImage* resultImage = nil;
	
	CGSize size = backgroundImage.size;
	CGRect outerBounds = {CGPointZero, size};
	CGRect innerBounds = CGRectInset(outerBounds, 1, 1);
	
	UIImage* shapeImage = nil;
    CGContextRef context = [UIImage beginImageContextWithSize:size opaque:YES scale:backgroundImage.scale flipped:NO];
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, outerBounds);
	UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:innerBounds cornerRadius:cornerRadius];
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextAddPath(context, path.CGPath);
	CGContextFillPath(context);
    shapeImage = [UIImage endImageContext];
	
	UIImage* etchedImage = [self newEtchedImageWithShapeImage:shapeImage backgroundImage:backgroundImage glossAlpha:glossAlpha];
	
	if([etchedImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
		// iOS 5 and later only
		UIEdgeInsets insets = UIEdgeInsetsMake(size.height / 2, size.width / 2 - 1.0, size.height/2, size.width / 2);
		resultImage = [etchedImage resizableImageWithCapInsets:insets];
	} else {
		NSInteger leftCapWidth = ((NSInteger)size.width / 2.0) - 1;
		NSInteger topCapHeight = ((NSInteger)size.height / 2.0) - 1;
		resultImage = [etchedImage stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
	}
	
	return resultImage;
}

+ (UIImage *)newEtchedButtonImageWithSize:(CGSize)size scale:(CGFloat)scale tintColor:(UIColor *)tintColor cornerRadius:(CGFloat)cornerRadius glossAlpha:(CGFloat)glossAlpha
{
	UIImage* resultImage = nil;

	UIImage* backgroundImage = [self newImageWithSize:size scale:scale backgroundColor:tintColor];
	resultImage = [self newEtchedButtonWithBackgroundImage:backgroundImage cornerRadius:cornerRadius glossAlpha:glossAlpha];

	return resultImage;
}

- (UIImage *)newImageForDarkBar:(BOOL)darkBar
{
	UIImage* resultImage;

	UIColor *tintColor;
	UIColor* shadowColor;
	CGSize shadowOffset;
    
    // Make room for the shadow
    CGSize size = CGSizeMake(self.size.width + 2, self.size.height + 2);
    UIImage *image = [self newImageByScalingToSize:self.size centeredWithinImageOfSize:size backgroundColor:[UIColor clearColor]];

	if(darkBar) {
		tintColor = [UIColor whiteColor];
		shadowOffset = CGSizeMake(0, -1);
		shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

		resultImage = [UIImage newImageWithShapeImage:image tintColor:tintColor shadowColor:shadowColor shadowOffset:shadowOffset shadowBlur:0.0];
	} else {
		tintColor = [UIColor colorWithHue:0.600 saturation:0.173 brightness:0.423 alpha:1.000];
		shadowOffset = CGSizeMake(0, 1);
		shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
		
		resultImage = [UIImage newImageWithShapeImage:image tintColor:tintColor shadowColor:shadowColor shadowOffset:shadowOffset shadowBlur:0.0];
	}
	
	return resultImage;
}

+ (UIImage *)barImageWithBackgroundPatternImage:(UIImage *)patternImage glossAlpha:(CGFloat)glossAlpha edgeTreatments:(void (^)(CGContextRef,CGRect))block
{
	UIImage* image = nil;
	
	CGRect bounds = {{0, 0}, {320, 44}};
    CGContextRef context = [UIImage beginImageContextWithSize:bounds.size opaque:YES scale:0.0 flipped:NO];
	
	ContextDrawSavingState(context, ^{
		CGFloat screenScale = ScreenScale();
		CGFloat patternScale = patternImage.scale;
		CGFloat scale = screenScale / patternScale ;
		CGContextScaleCTM(context, scale, scale);
		[patternImage drawAsPatternInRect:bounds];
	});

	if(glossAlpha > 0.0) {
		CGColorRef glossColor1 = CreateColorWithGray(1.0, glossAlpha);
		CGColorRef glossColor2 = CreateColorWithGray(1.0, glossAlpha * 0.25);
		CGColorRef glossColor3 = CreateColorWithGray(1.0, 0.0);
		CGColorRef glossColor4 = CreateColorWithGray(1.0, 0.0);
		
		CGGradientRef glossGradient = GradientCreateGloss(glossColor1, glossColor2, glossColor3, glossColor4, SharedColorSpaceDeviceGray());
		
		ContextFillRectGradientVertical(context, bounds, glossGradient);
		
		CGColorRelease(glossColor1);
		CGColorRelease(glossColor2);
		CGColorRelease(glossColor3);
		CGColorRelease(glossColor4);
		
		CGGradientRelease(glossGradient);
	}
	
	if(block != NULL) {
		block(context, bounds);
	}
	
    image = [UIImage endImageContext];
	return image;
}

+ (UIImage *)newNavigationBarImageWithBackgroundPatternImage:(UIImage *)patternImage glossAlpha:(CGFloat)glossAlpha
{
	UIImage* result = [self barImageWithBackgroundPatternImage:patternImage glossAlpha:glossAlpha edgeTreatments:^(CGContextRef context, CGRect bounds) {
		
		CGRect r = bounds;
		CGRect t;
		
		if(IsHiDPI()) {
			CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 1.0, 0.30);
			CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 1.0, 0.20);
			CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 1.0, 0.06);

			CGRectDivide(r, &t, &r, 0.5, CGRectMaxYEdge); ContextFillRectGray(context, t, 0.0, 1.0 - 0.38);
			CGRectDivide(r, &t, &r, 0.5, CGRectMaxYEdge); ContextFillRectGray(context, t, 0.0, 1.0 - 0.53);
			CGRectDivide(r, &t, &r, 0.5, CGRectMaxYEdge); ContextFillRectGray(context, t, 0.0, 1.0 - 0.84);
		} else {
			CGRectDivide(r, &t, &r, 1.0, CGRectMinYEdge); ContextFillRectGray(context, t, 1.0, 0.25);

			CGRectDivide(r, &t, &r, 1.0, CGRectMaxYEdge); ContextFillRectGray(context, t, 0.0, 1.0 - 0.38);
		}
	}];
	
	return result;
}

+ (UIImage *)newNavigationBarImageWithBackgroundPatternImage:(UIImage *)patternImage
{
	return [self newNavigationBarImageWithBackgroundPatternImage:patternImage glossAlpha:0.4];
}

+ (UIImage *)newToolbarImageWithBackgroundPatternImage:(UIImage *)patternImage toolbarPosition:(UIToolbarPosition)position glossAlpha:(CGFloat)glossAlpha
{
	UIImage* result = [self barImageWithBackgroundPatternImage:patternImage glossAlpha:glossAlpha edgeTreatments:^(CGContextRef context, CGRect bounds) {
		CGRect r = bounds;
		CGRect t;
		
		if(position == UIToolbarPositionBottom) {
			if(IsHiDPI()) {
				CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 0.0, 0.63);
				CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 0.1, 0.49);
				CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 0.4, 0.34);
				CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 0.6, 0.20);
				CGRectDivide(r, &t, &r, 0.5, CGRectMinYEdge); ContextFillRectGray(context, t, 0.8, 0.05);
			} else {
				CGRectDivide(r, &t, &r, 1.0, CGRectMinYEdge); ContextFillRectGray(context, t, 0.0, 0.7);
				CGRectDivide(r, &t, &r, 1.0, CGRectMinYEdge); ContextFillRectGray(context, t, 1.0, 0.6);
			}
		} else {
			// TODO
		}
	}];
	
	return result;
}

+ (UIImage *)newToolbarImageWithBackgroundPatternImage:(UIImage *)patternImage toolbarPosition:(UIToolbarPosition)position
{
	return [self newToolbarImageWithBackgroundPatternImage:patternImage toolbarPosition:position glossAlpha:0.4];
}

+ (CGContextRef)beginImageContextWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale flipped:(BOOL)flipped
{
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContextChecked();
    if(flipped) {
        CGContextTranslateCTM(context, 0.0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    return context;
}

+ (UIImage *)endImageContext NS_RETURNS_RETAINED
{
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
