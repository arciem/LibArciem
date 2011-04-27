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
    UIGraphicsBeginImageContext(self.size);
    
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

@end
