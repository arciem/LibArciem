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

@implementation UIImage (UIImageUtils)

+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor text:(NSString*)text
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
			CGSize stringSize = [text sizeWithFont:font minFontSize:[UIFont smallSystemFontSize] actualFontSize:&actualFontSize forWidth:size.width lineBreakMode:UILineBreakModeTailTruncation];
			CGPoint p = CGPointMake((size.width - stringSize.width) / 2, (size.height - stringSize.height) / 2);
			[text drawAtPoint:p forWidth:size.width withFont:font minFontSize:[UIFont smallSystemFontSize] actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentNone];
		
		UIGraphicsPopContext();
		
		CGImageRef image = CGBitmapContextCreateImage(context);

		BitmapContextFreeData(context);
		CGContextRelease(context);

		uiImage = [[[UIImage alloc] initWithCGImage:image] autorelease];
		
		CGImageRelease(image);
	}
	
	return uiImage;
}

+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor*)innerShadowColor shadowVerticalMultiplier:(NSInteger)shadowVerticalMultiplier
{
	UIImage* uiImage = nil;
	
	CGFloat scale = ScreenScale();
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
			uiImage = [[[UIImage alloc] initWithCGImage:image scale:scale orientation:UIImageOrientationUp] autorelease];
		} else {
			uiImage = [[[UIImage alloc] initWithCGImage:image] autorelease];
		}

		CGImageRelease(image);
	}

	return uiImage;
}

+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius innerShadowColor:(UIColor*)innerShadowColor
{
	return [self imageWithSize:size backgroundColor:backgroundColor cornerRadius:cornerRadius innerShadowColor:innerShadowColor shadowVerticalMultiplier:1];
}

+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius
{
	UIColor* innerShadowColor = [[UIColor blackColor] colorWithAlphaComponent:1.0 / 3.0];
	return [self imageWithSize:size backgroundColor:backgroundColor cornerRadius:cornerRadius innerShadowColor:innerShadowColor];
}

- (UIImage*)reflectedImageWithHeight:(NSUInteger)height
{
	CGImageRef reflectionImage = ReflectedImageCreate(self.CGImage, height);
	UIImage *image = [UIImage imageWithCGImage:reflectionImage];
	CGImageRelease(reflectionImage);
	
	return image;
}

- (UIImage *)imageByColorizing:(UIColor *)theColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
 
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, self.CGImage);
 
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)imageByScalingToSize:(CGSize)size
{
	UIImage* result = nil;
	
	UIGraphicsBeginImageContext( size );
		[self drawInRect:CGRectMake( 0, 0, size.width, size.height )];
		result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

- (UIImage*)imageByScalingToSize:(CGSize)inSize centeredWithinImageOfSize:(CGSize)imageSize backgroundColor:(UIColor*)backgroundColor
{
	UIImage* result = nil;
	
	UIGraphicsBeginImageContext( imageSize );

		CGContextRef context = UIGraphicsGetCurrentContext();
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
		result = UIGraphicsGetImageFromCurrentImageContext();
		
	UIGraphicsEndImageContext();
	
	return result;
}

- (UIImage*)imageByAspectFitToSize:(CGSize)imageSize backgroundColor:(UIColor*)backgroundColor
{
	CGSize inSize = [Geom aspectFitSize:self.size withinSize:imageSize];
	return [self imageByScalingToSize:inSize centeredWithinImageOfSize:imageSize backgroundColor:backgroundColor];
}

- (UIImage*)imageByAspectFitToSize:(CGSize)imageSize
{
	CGSize inSize = [Geom aspectFitSize:self.size withinSize:imageSize];
	return [self imageByScalingToSize:inSize];
}

- (UIImage*)imageByAspectFillToSize:(CGSize)imageSize backgroundColor:(UIColor*)backgroundColor
{
	CGSize inSize = [Geom aspectFillSize:self.size withinSize:imageSize];
	return [self imageByScalingToSize:inSize centeredWithinImageOfSize:imageSize backgroundColor:backgroundColor];
}

- (UIImage*)imageWithRoundedCornerRadius:(CGFloat)radius
{
	UIImage* result = nil;

	CGRect r;
	r.origin = CGPointZero;
	r.size = self.size;
	CGPathRef path = CreateRoundedRectPath(r, radius, NO);

	UIGraphicsBeginImageContext( self.size );

		CGContextRef context = UIGraphicsGetCurrentContext();

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

- (UIImage*)imageAtScreenScale
{
	UIImage* image = self;
	CGFloat scale = ScreenScale();
	if(scale > 1.0) {
		image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
	}
	return image;
}

+ (UIImage*)etchedImageWithShape:(UIImage*)shapeImage tintColor:(UIColor*)tintColor glossAlpha:(CGFloat)glossAlpha
{
	UIImage* resultImage = nil;
	CGContextRef context = nil;
	CGRect bounds = {CGPointZero, shapeImage.size};

	// Make a stencil that contains the shape we've been passed, drawn as a black silhouette on a white background
	CGImageRef shapeStencil = CGImageMaskCreate(CGImageGetWidth(shapeImage.CGImage), CGImageGetHeight(shapeImage.CGImage), CGImageGetBitsPerComponent(shapeImage.CGImage), CGImageGetBitsPerPixel(shapeImage.CGImage), CGImageGetBytesPerRow(shapeImage.CGImage), CGImageGetDataProvider(shapeImage.CGImage), NULL, false);

	// Also make an inverted stencil
	CGFloat invertDecodeArray[] = {1.0, 0.0,  1.0, 0.0,  1.0, 0.0};
	CGImageRef invertedShapeStencil = CGImageMaskCreate(CGImageGetWidth(shapeImage.CGImage), CGImageGetHeight(shapeImage.CGImage), CGImageGetBitsPerComponent(shapeImage.CGImage), CGImageGetBitsPerPixel(shapeImage.CGImage), CGImageGetBytesPerRow(shapeImage.CGImage), CGImageGetDataProvider(shapeImage.CGImage), invertDecodeArray, false);

	// To create an inner shadow, first paint a black rectangle through the inverted stencil, to create a frisket
	UIImage* innerShadowFrisketImage = nil;
	UIGraphicsBeginImageContextWithOptions(shapeImage.size, NO, shapeImage.scale);
	context = UIGraphicsGetCurrentContext();
	CGContextClipToMask(context, bounds, invertedShapeStencil);
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, bounds);
	innerShadowFrisketImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// Now draw the frisket with shadow into a new transparent image, resulting in an inner shadow
	UIImage* innerShadowImage = nil;
	UIGraphicsBeginImageContextWithOptions(shapeImage.size, NO, shapeImage.scale);
	context = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(context, CGSizeZero, 1.0, [UIColor blackColor].CGColor);
	[innerShadowFrisketImage drawAtPoint:CGPointZero];
	innerShadowImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// Create a border image by repeatedly striking the inner shadow image with the darken blend mode
	UIImage* borderImage = nil;
	UIGraphicsBeginImageContextWithOptions(shapeImage.size, NO, shapeImage.scale);
	context = UIGraphicsGetCurrentContext();
	CGContextSetBlendMode(context, kCGBlendModeDarken);
	for(int i = 0; i < 10; i++) {
		[innerShadowImage drawAtPoint:CGPointZero];
	}
	borderImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Create the main context we'll be painting into
	UIGraphicsBeginImageContextWithOptions(shapeImage.size, NO, shapeImage.scale);
	context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Paint the light, lower etching
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, -0.75);
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.25].CGColor);
	CGContextFillRect(context, bounds);
	CGContextRestoreGState(context);
	
	// Paint the tint colored shape
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextSetFillColorWithColor(context, tintColor.CGColor);
	CGContextFillRect(context, bounds);
	
	// Paint the gloss gradient
	CGContextSaveGState(context);
	UIColor* glossColor1 = [UIColor colorWithWhite:0.6 alpha:1];
	UIColor* glossColor2 = [UIColor colorWithWhite:0.1 alpha:1];
	UIColor* glossColor3 = [UIColor colorWithWhite:0.0 alpha:1];
	UIColor* glossColor4 = [UIColor colorWithWhite:0.05 alpha:1];
	CGGradientRef gradient = GradientCreateGloss(glossColor4.CGColor, glossColor3.CGColor, glossColor2.CGColor, glossColor1.CGColor, SharedColorSpaceDeviceRGB());
	CGContextSetBlendMode(context, kCGBlendModeScreen);
	CGContextSetAlpha(context, glossAlpha);
	ContextFillRectGradientVertical(context, bounds, gradient);
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);

	// Paint the inner shadow on top of the shape
	CGContextSaveGState(context);
	CGContextClipToMask(context, bounds, shapeStencil);
	CGContextTranslateCTM(context, 0.0, -0.5);
	[borderImage drawInRect:bounds blendMode:kCGBlendModeDarken alpha:0.5];
	CGContextRestoreGState(context);
	
	// Paint the border
	[borderImage drawInRect:bounds blendMode:kCGBlendModeDarken alpha:0.2];
	
	// Retrieve the finished image
	resultImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// Clean up
	CGImageRelease(shapeStencil);
	CGImageRelease(invertedShapeStencil);
	
	return resultImage;
}

+ (UIImage*)etchedButtonImageWithSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius tintColor:(UIColor*)tintColor glossAlpha:(CGFloat)glossAlpha
{
	UIImage* resultImage = nil;

	CGRect outerBounds = {CGPointZero, size};
	CGRect innerBounds = CGRectInset(outerBounds, 1, 1);

	UIImage* shapeImage = nil;
	UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, outerBounds);
	UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:innerBounds cornerRadius:cornerRadius];
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextAddPath(context, path.CGPath);
	CGContextFillPath(context);
	shapeImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	UIImage* etchedImage = [self etchedImageWithShape:shapeImage tintColor:tintColor glossAlpha:glossAlpha];

	UIEdgeInsets insets = UIEdgeInsetsMake(size.height / 2, size.width / 2 - 1.0, size.height/2, size.width / 2);
	resultImage = [etchedImage resizableImageWithCapInsets:insets];

	return resultImage;
}

@end
