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

+ (UIColor*)colorWithRGBValue:(NSUInteger)rgbValue
{
	return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
						   green:((float)((rgbValue & 0xFF00) >> 8))/255.0
							blue:((float)(rgbValue & 0xFF))/255.0
						   alpha:1.0
			];
}

@end
