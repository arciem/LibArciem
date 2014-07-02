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

#import <CoreGraphics/CoreGraphics.h>

CGContextRef UIGraphicsGetCurrentContextChecked();

CGColorSpaceRef SharedColorSpaceDeviceRGB();
CGColorSpaceRef SharedColorSpaceDeviceGray();

CGColorRef SharedWhiteColor();
CGColorRef SharedBlackColor();
CGColorRef SharedClearColor();

void ContextFillRectColor(CGContextRef context, CGRect rect, CGColorRef color);
void ContextFillRectGray(CGContextRef context, CGRect rect, CGFloat gray, CGFloat alpha);
void ContextDrawCrossedBox(CGContextRef context, CGRect rect, CGColorRef color, float lineWidth, bool originIndicators);
CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat radius, BOOL reverse);
CGPathRef CreateTopRoundedRectPath(CGRect rect, CGFloat radius);
CGPathRef CreateBottomRoundedRectPath(CGRect rect, CGFloat radius);
CGPathRef CreateRoundedShadowPath(CGRect rect, CGFloat radius, BOOL upper, CGFloat thickness);

//CGContextRef BitmapContextCreate(CGSize size, bool flipped);
//CGContextRef BitmapContextCreateGray(CGSize size, bool flipped);
//void BitmapContextFreeData(CGContextRef context);
void BitmapContextScroll(CGContextRef context, CGPoint offset);
CGSize BitmapContextSize(CGContextRef context);

CGGradientRef GradientCreateWith2Colors(CGColorRef color1, CGColorRef color2, CGColorSpaceRef colorSpace);
CGGradientRef GradientCreateWith3Colors(CGColorRef color1, CGColorRef color2, CGColorRef color3, CGColorSpaceRef colorSpace);
CGGradientRef GradientCreateWith4Colors(CGColorRef color1, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGColorSpaceRef colorSpace);
CGGradientRef GradientCreateGloss(CGColorRef color1, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGColorSpaceRef colorSpace);
CGGradientRef GradientCreateShield();
CGGradientRef GradientCreateSine(CGColorRef color1, CGColorRef color2, CGColorSpaceRef colorSpace, NSUInteger steps, CGFloat exponent /* = 0.5*/);
CGGradientRef GradientCreateRainbow(CGFloat hueOffset, CGFloat saturation, CGFloat value, CGFloat alpha);
CGGradientRef GradientCreateEaseOut(CGColorRef color1, CGColorRef color2, CGColorSpaceRef colorSpace, NSUInteger steps);

void ContextFillShieldGradient(CGContextRef context, CGRect rect);
void ContextFillRectGradient(CGContextRef context, CGRect rect, CGGradientRef gradient, CGPoint point1, CGPoint point2);
void ContextFillRectGradientVertical(CGContextRef context, CGRect rect, CGGradientRef gradient, BOOL reverse);
void ContextFillRectGradientHorizontal(CGContextRef context, CGRect rect, CGGradientRef gradient, BOOL reverse);

void ContextFillRectColor(CGContextRef context, CGRect rect, CGColorRef color);
void ContextFillPathColor(CGContextRef context, CGPathRef path, CGColorRef color);
void ContextFillPathGradient(CGContextRef context, CGPathRef path, CGGradientRef gradient, CGPoint point1, CGPoint point2);
void ContextFillPathGradientVertical(CGContextRef context, CGPathRef path, CGGradientRef gradient, BOOL reverse);
void ContextFillPathGradientHorizontal(CGContextRef context, CGPathRef path, CGGradientRef gradient, BOOL reverse);

CGImageRef CreateImageWithMaskAndColor(CGImageRef mask, CGColorRef color);

CGColorRef CreateRandomColor();
CGColorRef CreateColorWithRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a);
CGColorRef CreateColorWithGray(CGFloat gray, CGFloat alpha);
CGColorRef CreateColorByConvertingToRGB(CGColorRef color);
CGColorRef CreateColorByDarkening(CGColorRef color, CGFloat fractionDarker);
CGColorRef CreateColorByLightening(CGColorRef color, CGFloat fractionLighter);
CGColorRef CreateColorByColorBurn(CGColorRef color, CGFloat fractionDarker);
CGColorRef CreateColorByColorDodge(CGColorRef color, CGFloat fractionLighter);
CGColorRef CreateColorByInterpolatingColors(CGColorRef color1, CGColorRef color2, CGFloat fraction);

//CGImageRef ReflectedImageCreate(CGImageRef fromImage, NSUInteger height);
//CGImageRef CreateImageFromPDF(CFURLRef url, NSUInteger pageNumber, CGRect contentRect, CGSize imageSize);

#if 0
class CGContextSaveGStateS
{
private:
	CGContextRef _context;

public:
	CGContextSaveGStateS(CGContextRef context) : _context(context) { CGContextSaveGState(_context); }
	~CGContextSaveGStateS() { CGContextRestoreGState(_context); }
};
#endif

void ContextDrawSavingState(CGContextRef context, void (^drawing)(void));

CGFloat RoundUpToEvenValue(CGFloat v);
CGPathRef CreatePathReversed(CGPathRef path);
