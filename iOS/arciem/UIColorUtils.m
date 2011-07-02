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

@implementation UIColor(UIColorUtils)

+ (UIColor*)colorWithDenormalizedHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
	return [UIColor colorWithHue:hue / 360.0 saturation:saturation / 100.0 brightness:brightness / 100.0 alpha:alpha];
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

- (void)tintColorVariant1:(UIColor**)outColor1 variant2:(UIColor**)outColor2
{
	NSArray* items = [NSArray arrayWithObjects:@"Hello", @"World", nil];
	UISegmentedControl* ctrl = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
	ctrl.tintColor = self;
	CGSize size = ctrl.bounds.size;

	CGContextRef context = BitmapContextCreate(size, NO);
	CGContextClearRect(context, ctrl.bounds);
	CALayer* layer = ctrl.layer;
	layer.shouldRasterize = YES;
	[layer renderInContext:context];
	UInt8* data = (UInt8*)CGBitmapContextGetData(context);
	
//	NSUInteger x1 = 6;
//	NSUInteger y1 = size.height - 6;
//	NSUInteger x2 = size.width - 6;
//	NSUInteger y2 = size.height - 6;

	NSUInteger x1 = 8;
	NSUInteger y1 = 8;
	NSUInteger x2 = size.width - 8;
	NSUInteger y2 = 8;
	
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = size.width * bytesPerPixel;
	UInt8* data1 = data + bytesPerRow * y1 + bytesPerPixel * x1;
	UInt8* data2 = data + bytesPerRow * y2 + bytesPerPixel * x2;
	CGFloat comp1[4] = {data1[0]/255.0, data1[1]/255.0, data1[2]/255.0, data1[3]/255.0};
	CGFloat comp2[4] = {data2[0]/255.0, data2[1]/255.0, data2[2]/255.0, data2[3]/255.0};
	CGColorRef color1 = CGColorCreate(SharedColorSpaceDeviceRGB(), comp1);
	CGColorRef color2 = CGColorCreate(SharedColorSpaceDeviceRGB(), comp2);
	BitmapContextFreeData(context);
	CGContextRelease(context);
	*outColor1 = [UIColor colorWithCGColor:color1];
	*outColor2 = [UIColor colorWithCGColor:color2];
	CGColorRelease(color1);
	CGColorRelease(color2);
}

@end
