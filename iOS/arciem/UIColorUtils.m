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

#import "UIColorUtils.h"
#import "math_utils.hpp"
#import <QuartzCore/QuartzCore.h>
#import "Geom.h"

@implementation UIColor(UIColorUtils)

+ (UIColor*)colorWithDenormalizedHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
	return [UIColor colorWithHue:hue / 360.0 saturation:saturation / 100.0 brightness:brightness / 100.0 alpha:alpha];
}

+ (UIColor*)systemNavigationBlue
{
	return [self colorWithRGBValue:0x436a9b];
}

+ (UIColor*)systemHighlightBlue
{
	return [self colorWithRGBValue:0x0081ee];
}

+ (UIColor*)systemNavigationGray
{
	return [self colorWithRGBValue:0x666666];
}

+ (UIColor*)systemHighlightGray
{
	return [self colorWithRGBValue:0x000000];
}

- (UIColor*)colorByInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction
{
	CGColorRef color1 = CreateColorByConvertingToRGB(self.CGColor);
	CGColorRef color2 = CreateColorByConvertingToRGB(color.CGColor);
	CGColorRef icolor = CreateColorByInterpolatingColors(color1, color2, fraction);
	
	UIColor* result = [UIColor colorWithCGColor:icolor];
	
	CGColorRelease(color1);
	CGColorRelease(color2);
	CGColorRelease(icolor);
	
	return result;
}

- (UIColor*)colorByCircularInterpolatingToColor:(UIColor*)color fraction:(CGFloat)fraction
{
	UIColor* result = self;
	
	CGFloat h1, s1, b1, a1;
	CGFloat h2, s2, b2, a2;
	CGFloat h, s, b, a;
	if([self getHue:&h1 saturation:&s1 brightness:&b1 alpha:&a1]) {
		if([self getHue:&h2 saturation:&s2 brightness:&b2 alpha:&a2]) {
			h = arciem::circular_interpolate(fraction, h1, h2);
			s = arciem::denormalize(fraction, s1, s2);
			b = arciem::denormalize(fraction, b1, b2);
			a = arciem::denormalize(fraction, a1, a2);
			result = [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
		}
	}
	
	return result;
}

- (UIColor*)colorByCircularInterpolatingToHue:(UIColor*)color fraction:(CGFloat)fraction
{
	UIColor* result = self;
	
	CGFloat h1, s1, b1, a1;
	CGFloat h2, s2, b2, a2;
	CGFloat h;
	if([self getHue:&h1 saturation:&s1 brightness:&b1 alpha:&a1]) {
		if([color getHue:&h2 saturation:&s2 brightness:&b2 alpha:&a2]) {
			h = arciem::circular_interpolate(fraction, h1, h2);
			result = [UIColor colorWithHue:h saturation:s1 brightness:b1 alpha:a1];
		}
	}
	
	return result;
}

- (UIColor*)colorByDarkeningFraction:(CGFloat)fraction
{
	CGColorRef color = CreateColorByDarkening(self.CGColor, fraction);
	UIColor* result = [UIColor colorWithCGColor:color];
	CGColorRelease(color);
	
	return result;
}

- (UIColor*)colorByLighteningFraction:(CGFloat)fraction
{
	CGColorRef color = CreateColorByLightening(self.CGColor, fraction);
	UIColor* result = [UIColor colorWithCGColor:color];
	CGColorRelease(color);
	
	return result;
}

- (UIColor*)colorByColorBurnFraction:(CGFloat)fraction
{
	CGColorRef color = CreateColorByColorBurn(self.CGColor, fraction);
	UIColor* result = [UIColor colorWithCGColor:color];
	CGColorRelease(color);

	return result;
}

- (UIColor*)colorByDeepeningFraction:(CGFloat)fraction
{
	UIColor* color = self;
	
	CGFloat h, s, b, a;
	if([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		b = arciem::denormalize(fraction, b, 0.0f);
		color = [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
	}
	
	return color;
}

- (UIColor*)colorBySaturatingFraction:(CGFloat)fraction
{
	UIColor* color = self;
	
	CGFloat h, s, b, a;
	if([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		s = arciem::denormalize(fraction, s, 1.0f);
		color = [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
	}
	
	return color;
}

- (UIColor*)colorByDesaturatingFraction:(CGFloat)fraction
{
	UIColor* color = self;
	
	CGFloat h, s, b, a;
	if([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		s = arciem::denormalize(fraction, s, 0.0f);
		color = [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
	}
	
	return color;
}

- (CGFloat)distanceToColor:(UIColor*)color
{
	CGFloat r1, g1, b1, a1;
	CGFloat r2, g2, b2, a2;
	[self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
	[color getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	CGFloat rd = r2 - r1;
	CGFloat gd = g2 - g1;
	CGFloat bd = b2 - b1;
	CGFloat distance = sqrtf(rd*rd + gd*gd + bd*bd);
	return distance;
}

- (UIColor*)closestColorInColors:(NSArray*)colors
{
	UIColor* closestColor = nil;
	CGFloat closestDistance = INFINITY;
	for(UIColor* color in colors) {
		CGFloat distance = [self distanceToColor:color];
		if(distance < closestDistance) {
			closestColor = color;
			closestDistance = distance;
		}
	}
	
	return closestColor;
}

+ (UIColor*)colorWithRGBValue:(NSUInteger)rgbValue
{
	return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
						   green:((float)((rgbValue & 0xFF00) >> 8))/255.0
							blue:((float)(rgbValue & 0xFF))/255.0
						   alpha:1.0
			];
}

- (CGFloat)red
{
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	[self getRed:&r green:&g blue:&b alpha:&a];
	return r;
}

- (CGFloat)green
{
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	[self getRed:&r green:&g blue:&b alpha:&a];
	return g;
}

- (CGFloat)blue
{
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	[self getRed:&r green:&g blue:&b alpha:&a];
	return b;
}

- (CGFloat)alpha
{
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	[self getRed:&r green:&g blue:&b alpha:&a];
	return a;
}

- (CGFloat)hue
{
	CGFloat h = 0.0, s = 0.0, b = 0.0, a = 0.0;
	[self getHue:&h saturation:&s brightness:&b alpha:&a];
	return h;
}

- (CGFloat)saturation
{
	CGFloat h = 0.0, s = 0.0, b = 0.0, a = 0.0;
	[self getHue:&h saturation:&s brightness:&b alpha:&a];
	return s;
}

- (CGFloat)brightness
{
	CGFloat h = 0.0, s = 0.0, b = 0.0, a = 0.0;
	[self getHue:&h saturation:&s brightness:&b alpha:&a];
	return b;
}

- (CGFloat)luminance
{
	CGFloat luminance = 0.0;
	
	CGColorRef cgColor = self.CGColor;
	CGColorSpaceRef colorSpace = CGColorGetColorSpace(cgColor);
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
	const CGFloat* components = CGColorGetComponents(cgColor);
	
	if(colorSpaceModel == kCGColorSpaceModelMonochrome) {
		luminance = components[0];
	} else if(colorSpaceModel == kCGColorSpaceModelRGB) {
		luminance = 0.3 * components[0] + 0.59 * components[1] + 0.11 * components[2];
	}
	
	return luminance;
}

- (UIColor*)colorWithRed:(CGFloat)red
{
	UIColor* color = self;
	
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	if([self getRed:&r green:&g blue:&b alpha:&a]) {
		color = [UIColor colorWithRed:red green:g blue:b alpha:a];
	}
	
	return color;
}

- (UIColor*)colorWithGreen:(CGFloat)green
{
	UIColor* color = self;
	
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	if([self getRed:&r green:&g blue:&b alpha:&a]) {
		color = [UIColor colorWithRed:r green:green blue:b alpha:a];
	}
	
	return color;
}

- (UIColor*)colorWithBlue:(CGFloat)blue
{
	UIColor* color = self;
	
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	if([self getRed:&r green:&g blue:&b alpha:&a]) {
		color = [UIColor colorWithRed:r green:g blue:blue alpha:a];
	}
	
	return color;
}

- (UIColor*)colorWithAlpha:(CGFloat)alpha
{
	UIColor* color = self;
	
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
	if([self getRed:&r green:&g blue:&b alpha:&a]) {
		color = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
	}
	
	return color;
}

- (UIColor*)colorWithHue:(CGFloat)hue
{
	UIColor* color = self;
	CGFloat h = 0.0, s = 0.0, b = 0.0, a = 0.0;
	if([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		color = [UIColor colorWithHue:hue saturation:s brightness:b alpha:a];
	}

	return color;
}

- (UIColor*)colorWithSaturation:(CGFloat)saturation
{
	UIColor* color = self;
	CGFloat h = 0.0, s = 0.0, b = 0.0, a = 0.0;
	if([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		color = [UIColor colorWithHue:h saturation:saturation brightness:b alpha:a];
	}
	
	return color;
}

- (UIColor*)colorWithBrightness:(CGFloat)brightness
{
	UIColor* color = self;
	CGFloat h = 0.0, s = 0.0, b = 0.0, a = 0.0;
	if([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		color = [UIColor colorWithHue:h saturation:s brightness:brightness alpha:a];
	}
	
	return color;
}

- (UIColor*)tintColorVariantForButtonHighlighted:(BOOL)highlighted
{
	UIColor* result = nil;
	if(highlighted) {
		result = [[self colorByColorBurnFraction:0.35] colorByDarkeningFraction:0.2];
	} else {
		result = [self colorByColorBurnFraction:0.25];
	}
	return result;
}

+ (UIColor*)diagonalPatternColorWithColor1:(UIColor*)color1 color2:(UIColor*)color2 size:(CGSize)size scale:(CGFloat)scale
{
	CGRect imageBounds = CGRectZero;
	imageBounds.size = size;

	UIGraphicsBeginImageContextWithOptions(size, YES, scale);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[color1 set];
	CGContextFillRect(context, imageBounds);
	
	UIBezierPath* path = [[UIBezierPath alloc] init];
	[path moveToPoint:[Geom rectMinXMinY:imageBounds]];
	[path addLineToPoint:[Geom rectMidXMinY:imageBounds]];
	[path addLineToPoint:[Geom rectMinXMidY:imageBounds]];
	[path closePath];
	[path moveToPoint:[Geom rectMaxXMinY:imageBounds]];
	[path addLineToPoint:[Geom rectMaxXMidY:imageBounds]];
	[path addLineToPoint:[Geom rectMidXMaxY:imageBounds]];
	[path addLineToPoint:[Geom rectMinXMaxY:imageBounds]];
	[path closePath];
	[color2 set];
	[path fill];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIColor* color = [[UIColor alloc] initWithPatternImage:image];
	return color;
}

@end
