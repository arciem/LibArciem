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

#include <algorithm>
#import "random.hpp"
#include <arciem/essentials/math_utils.hpp>
#import "CGUtils.h"
#import "Geom.h"

using namespace arciem;

static CGColorSpaceRef _sharedColorSpaceDeviceRGB = NULL;
static CGColorSpaceRef _sharedColorSpaceDeviceGray = NULL;
static CGColorRef _sharedWhiteColor = NULL;
static CGColorRef _sharedBlackColor = NULL;
static CGColorRef _sharedClearColor = NULL;

CGColorSpaceRef SharedColorSpaceDeviceRGB()
{
	if(_sharedColorSpaceDeviceRGB == NULL) {
		_sharedColorSpaceDeviceRGB = CGColorSpaceCreateDeviceRGB();
	}
	
	return _sharedColorSpaceDeviceRGB;
}

CGColorSpaceRef SharedColorSpaceDeviceGray()
{
	if(_sharedColorSpaceDeviceGray == NULL) {
		_sharedColorSpaceDeviceGray = CGColorSpaceCreateDeviceGray();
	}
	
	return _sharedColorSpaceDeviceGray;
}

CGContextRef BitmapContextCreate(CGSize size, bool flipped)
{
	CGContextRef context = NULL;

	size_t width = size.width;
	size_t height = size.height;
	size_t bytesPerRow = 4 * width;
	size_t byteCount = bytesPerRow * height;
	void* data = malloc(byteCount);
	if(data != NULL) {
		CGColorSpaceRef colorSpace = SharedColorSpaceDeviceRGB();

		context = CGBitmapContextCreate(data, 
			width, 
			height, 
			8, // bitsPerComponent
			bytesPerRow,
			colorSpace,
			kCGImageAlphaPremultipliedLast);
		
		if(context == NULL) {
			free(data);
		} else {
			if(flipped) {
				CGContextTranslateCTM(context, 0.0, size.height);
				CGContextScaleCTM(context, 1.0, -1.0);
			}
		}
	}
	
	return context;
}

CGContextRef BitmapContextCreateGray(CGSize size, bool flipped)
{
	CGContextRef context = NULL;

	size_t width = size.width;
	size_t height = size.height;
	size_t bytesPerRow = width;
	size_t byteCount = bytesPerRow * height;
	void* data = malloc(byteCount);
	if(data != NULL) {
		CGColorSpaceRef colorSpace = SharedColorSpaceDeviceGray();

		context = CGBitmapContextCreate(data, 
			width, 
			height, 
			8, // bitsPerComponent
			bytesPerRow,
			colorSpace,
			kCGImageAlphaNone);
		
		if(context == NULL) {
			free(data);
		} else {
			if(flipped) {
				CGContextTranslateCTM(context, 0.0, size.height);
				CGContextScaleCTM(context, 1.0, -1.0);
			}
		}
	}
	
	return context;
}

void BitmapContextFreeData(CGContextRef context)
{
	if(context != NULL) {
		void* data = CGBitmapContextGetData(context);
		free(data);
	}
//	CGContextRelease(context);
}

void ContextDrawCrossedBox(CGContextRef context, CGRect rect, CGColorRef color, float lineWidth, bool originIndicators)
{
	float minX = CGRectGetMinX(rect);
	float minY = CGRectGetMinY(rect);
	float maxX = CGRectGetMaxX(rect);
	float maxY = CGRectGetMaxY(rect);

	CGMutablePathRef path = CGPathCreateMutable();

	CGPathMoveToPoint(path, NULL, minX, minY);
	CGPathAddLineToPoint(path, NULL, maxX, minY);
	CGPathAddLineToPoint(path, NULL, maxX, maxY);
	CGPathAddLineToPoint(path, NULL, minX, maxY);
	CGPathCloseSubpath(path);
	
	CGPathMoveToPoint(path, NULL, minX, minY);
	CGPathAddLineToPoint(path, NULL, maxX, maxY);

	CGPathMoveToPoint(path, NULL, maxX, minY);
	CGPathAddLineToPoint(path, NULL, minX, maxY);
	
	if(originIndicators) {
		float midX = CGRectGetMidX(rect);
		float midY = CGRectGetMidY(rect);

		CGPathMoveToPoint(path, NULL, midX, minY);
		CGPathAddLineToPoint(path, NULL, midX, midY);

		CGPathMoveToPoint(path, NULL, minX, midY);
		CGPathAddLineToPoint(path, NULL, midX, midY);
	}

	CGContextSaveGState(context);
		CGContextSetStrokeColorWithColor(context, color);
		CGContextSetLineWidth(context, lineWidth);
		CGContextAddPath(context, path);
		CGContextStrokePath(context);
	CGContextRestoreGState(context);
	
	CGPathRelease(path);
}

CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat radius, BOOL reverse)
{
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	CGFloat xRadius = fmin(radius, rect.size.width / 2);
	CGFloat yRadius = fmin(radius, rect.size.height / 2);
	radius = fmin(xRadius, yRadius);
	
	CGFloat inMinX = minX + xRadius;
	CGFloat inMinY = minY + yRadius;
	CGFloat	inMaxX = maxX - xRadius;
	CGFloat inMaxY = maxY - yRadius;
	
	CGMutablePathRef mPath = CGPathCreateMutable();

	if(reverse) {
		CGPathMoveToPoint(mPath, NULL, inMinX, minY);
		CGPathAddArcToPoint(mPath, NULL, minX, minY, minX, inMinY, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, maxY, inMinX, maxY, radius);
		CGPathAddArcToPoint(mPath, NULL, maxX, maxY, maxX, inMaxY, radius);
		CGPathAddArcToPoint(mPath, NULL, maxX, minY, inMaxX, minY, radius);
	} else {
		CGPathMoveToPoint(mPath, NULL, inMaxX, minY);
		CGPathAddArcToPoint(mPath, NULL, maxX, minY, maxX, inMinY, radius);
		CGPathAddArcToPoint(mPath, NULL, maxX, maxY, inMaxX, maxY, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, maxY, minX, inMaxY, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, minY, inMinX, minY, radius);
	}

	CGPathCloseSubpath(mPath);
	
	CGPathRef path = CGPathCreateCopy(mPath);
	CFRelease(mPath);
	
	return path;
}

CGPathRef CreateTopRoundedRectPath(CGRect rect, CGFloat radius) {
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	CGFloat xRadius = fmin(radius, rect.size.width / 2);
	CGFloat yRadius = fmin(radius, rect.size.height / 2);
	radius = fmin(xRadius, yRadius);
	
	CGFloat inMinX = minX + xRadius;
	CGFloat inMinY = minY + yRadius;
	CGFloat	inMaxX = maxX - xRadius;
	
	CGMutablePathRef mPath = CGPathCreateMutable();
		CGPathMoveToPoint(mPath, NULL, inMaxX, minY);
		CGPathAddArcToPoint(mPath, NULL, maxX, minY, maxX, inMinY, radius);
		CGPathAddLineToPoint(mPath, NULL, maxX, maxY);
		CGPathAddLineToPoint(mPath, NULL, minX, maxY);
		CGPathAddArcToPoint(mPath, NULL, minX, minY, inMinX, minY, radius);
	CGPathCloseSubpath(mPath);
	
	CGPathRef path = CGPathCreateCopy(mPath);
	CFRelease(mPath);
	
	return path;
}

CGPathRef CreateBottomRoundedRectPath(CGRect rect, CGFloat radius) {
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	CGFloat xRadius = fmin(radius, rect.size.width / 2);
	CGFloat yRadius = fmin(radius, rect.size.height / 2);
	radius = fmin(xRadius, yRadius);
	
	CGFloat	inMaxX = maxX - xRadius;
	CGFloat	inMaxY = maxY - yRadius;
	
	CGMutablePathRef mPath = CGPathCreateMutable();
		CGPathMoveToPoint(mPath, NULL, maxX, minY);
		CGPathAddArcToPoint(mPath, NULL, maxX, maxY, inMaxX, maxY, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, maxY, minX, inMaxY, radius);
		CGPathAddLineToPoint(mPath, NULL, minX, minY);
		CGPathAddLineToPoint(mPath, NULL, maxX, minY);
	CGPathCloseSubpath(mPath);
	
	CGPathRef path = CGPathCreateCopy(mPath);
	CFRelease(mPath);
	
	return path;
}



CGPathRef CreateRoundedShadowPath(CGRect rect, CGFloat radius, BOOL upper, CGFloat thickness)
{
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	CGFloat xRadius = fmin(radius, rect.size.width / 2);
	CGFloat yRadius = fmin(radius, rect.size.height / 2);
	radius = fmin(xRadius, yRadius);
	
	CGFloat inMinX = minX + xRadius;
	CGFloat inMinY = minY + yRadius;
	CGFloat	inMaxX = maxX - xRadius;
	CGFloat inMaxY = maxY - yRadius;
	
	CGMutablePathRef mPath = CGPathCreateMutable();

	if(upper) {
		CGPathMoveToPoint(mPath, NULL, inMaxX, minY);
		CGPathAddArcToPoint(mPath, NULL, maxX, minY, maxX, inMinY, radius);
		CGPathAddArcToPoint(mPath, NULL, maxX, minY + thickness, inMaxX, minY + thickness, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, minY + thickness, minX, inMinY + thickness, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, minY, inMinX, minY, radius);
	} else {
		CGPathMoveToPoint(mPath, NULL, inMinX, maxY);
		CGPathAddArcToPoint(mPath, NULL, minX, maxY, minX, inMaxY, radius);
		CGPathAddArcToPoint(mPath, NULL, minX, maxY - thickness, inMinX, maxY - thickness, radius);
		CGPathAddArcToPoint(mPath, NULL, maxX, maxY - thickness, maxX, inMaxY - thickness, radius);
		CGPathAddArcToPoint(mPath, NULL, maxX, maxY, inMaxX, maxY, radius);
	}

	CGPathCloseSubpath(mPath);
	
	CGPathRef path = CGPathCreateCopy(mPath);
	CFRelease(mPath);
	
	return path;
}

CGGradientRef GradientCreateWith2Colors(CGColorRef color1, CGColorRef color2, CGColorSpaceRef colorSpace)
{
	const void* colorValues[] = { color1, color2 };
	CFArrayRef colors = CFArrayCreate(NULL, colorValues, 2, NULL);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
	CFRelease(colors);
	return gradient;
}

CGGradientRef GradientCreateWith3Colors(CGColorRef color1, CGColorRef color2, CGColorRef color3, CGColorSpaceRef colorSpace)
{
	const void* colorValues[] = { color1, color2, color3 };
	CFArrayRef colors = CFArrayCreate(NULL, colorValues, 3, NULL);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
	CFRelease(colors);
	return gradient;
}

CGGradientRef GradientCreateWith4Colors(CGColorRef color1, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGColorSpaceRef colorSpace)
{
	const void* colorValues[] = { color1, color2, color3, color4 };
	CFArrayRef colors = CFArrayCreate(NULL, colorValues, 4, NULL);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
	CFRelease(colors);
	return gradient;
}

CGGradientRef GradientCreateGloss(CGColorRef color1, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGColorSpaceRef colorSpace)
{
	const void* colorValues[] = { color1, color2, color3, color4 };
	CGFloat locations[] = { 0.0, 0.49, 0.51, 1.0 };
	CFArrayRef colors = CFArrayCreate(NULL, colorValues, 4, NULL);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
	CFRelease(colors);
	return gradient;
}

CGGradientRef GradientCreateShield()
{
	CGColorRef innerColor = CreateColorWithGray(0.0, 0.0);
	CGColorRef outerColor = CreateColorWithGray(0.0, 0.6);
	const void* colorValues[] = { innerColor, outerColor };
	CFArrayRef colors = CFArrayCreate(NULL, colorValues, 2, NULL);
	CGGradientRef gradient = CGGradientCreateWithColors(SharedColorSpaceDeviceGray(), colors, NULL);
	CFRelease(colors);
	CGColorRelease(outerColor);
	CGColorRelease(innerColor);
	return gradient;
}

void ContextFillShieldGradient(CGContextRef context, CGRect rect)
{
	CGGradientRef gradient = GradientCreateShield();
	
	CGSize size = [Geom aspectFitSize:CGSizeMake(100, 100) withinSize:rect.size];
	CGFloat radius = size.width * 0.5;
	CGFloat outerRadius = radius * 1.5;
	CGFloat innerRadius = radius * 0.2;
	CGPoint center = [Geom rectMid:rect];
	CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
	CGContextDrawRadialGradient(context, gradient, center, innerRadius, center, outerRadius, options);
	
	CGGradientRelease(gradient);
}

void ContextFillRectGradient(CGContextRef context, CGRect rect, CGGradientRef gradient, CGPoint point1, CGPoint point2)
{
	CGContextSaveGState(context);
		CGContextClipToRect(context, rect);
		CGContextDrawLinearGradient(context, gradient, point1, point2, 0);
	CGContextRestoreGState(context);
}

void ContextFillRectGradientVertical(CGContextRef context, CGRect rect, CGGradientRef gradient)
{
	CGPoint point1 = CGPointMake(0, CGRectGetMinY(rect));
	CGPoint point2 = CGPointMake(0, CGRectGetMaxY(rect));
	ContextFillRectGradient(context, rect, gradient, point1, point2);
}

void ContextFillRectGradientHorizontal(CGContextRef context, CGRect rect, CGGradientRef gradient)
{
	CGPoint point1 = CGPointMake(CGRectGetMinX(rect), 0);
	CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), 0);
	ContextFillRectGradient(context, rect, gradient, point1, point2);
}

CGColorRef CreateRandomColor()
{
	CGFloat components[4];
	for(int i = 0; i < 3; ++i) {
		components[i] = random_flat();
	}
	components[3] = 1.0;
	CGColorRef color = CGColorCreate(SharedColorSpaceDeviceRGB(), components);
	return color;
}

CGColorRef SharedWhiteColor()
{
	if(_sharedWhiteColor == NULL) {
		static CGFloat components[] = {1.0, 1.0};
		_sharedWhiteColor = CGColorCreate(SharedColorSpaceDeviceGray(), components);
	}

	return _sharedWhiteColor;
}

CGColorRef SharedBlackColor()
{
	if(_sharedBlackColor == NULL) {
		static CGFloat components[] = {0.0, 1.0};
		_sharedBlackColor = CGColorCreate(SharedColorSpaceDeviceGray(), components);
	}

	return _sharedBlackColor;
}

CGColorRef SharedClearColor()
{
	if(_sharedClearColor == NULL) {
		static CGFloat components[] = {0.0, 0.0};
		_sharedClearColor = CGColorCreate(SharedColorSpaceDeviceGray(), components);
	}

	return _sharedClearColor;
}

void BitmapContextScroll(CGContextRef context, CGPoint offset)
{
	CGRect r;
	r.origin = offset;
	r.size.width = CGBitmapContextGetWidth(context);
	r.size.height = CGBitmapContextGetHeight(context);

	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextDrawImage(context, r, image);
	CGImageRelease(image);
}

CGSize BitmapContextSize(CGContextRef context)
{
	return CGSizeMake(CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context));
}

CGImageRef ReflectedImageCreate(CGImageRef fromImage, NSUInteger height)
{
	// Create a flipped context for the reflection of the given height
	CGRect fromImageRect = CGRectMake(0, 0, CGImageGetWidth(fromImage), CGImageGetHeight(fromImage));
	CGRect reflectionRect = CGRectMake(0, 0, CGImageGetWidth(fromImage), height);
	CGContextRef reflectionContext = BitmapContextCreate(reflectionRect.size, YES);
	
	// Draw the original image into the flipped context
	CGContextDrawImage(reflectionContext, fromImageRect, fromImage);
	
	// Create an image from the flipped context and release the context
	CGImageRef mainViewImage = CGBitmapContextCreateImage(reflectionContext);
	CGContextRelease(reflectionContext);

	// Create a 1-pixel wide context for the gradient mask, it will be automatically stretched by CGImageCreateWithMask
	CGRect gradientRect = CGRectMake(0, 0, 1, height);
	CGContextRef gradientBitmapContext = BitmapContextCreateGray(gradientRect.size, NO);

	// Draw the gradient mask
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    CGColorSpaceRef colorSpace = SharedColorSpaceDeviceGray();
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	ContextFillRectGradientVertical(gradientBitmapContext, gradientRect, grayScaleGradient);
	CGGradientRelease(grayScaleGradient);
	
	// convert the gradient context into an image and release the context
	CGImageRef gradientMaskImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGImageRef reflectionImage = CGImageCreateWithMask(mainViewImage, gradientMaskImage);
	CGImageRelease(mainViewImage);
	CGImageRelease(gradientMaskImage);
	
	return reflectionImage;
}

#if 0
CGImageRef CreateImageWithMaskAndColor(CGImageRef mask, CGColorRef color)
{
	CGRect r;
	r.origin = CGPointZero;
	r.size = CGSizeMake(CGImageGetWidth(mask), CGImageGetHeight(mask));
	CGContextRef colorContext = BitmapContextCreate(r.size, NO);
	ContextFillRectColor(colorContext, r, color);
	return NULL;
}
#endif

CGImageRef CreateImageFromPDF(CFURLRef url, NSUInteger pageNumber, CGRect contentRect, CGSize imageSize)
{
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL(url);
	CGPDFPageRef page = CGPDFDocumentGetPage(doc, pageNumber);

	CGRect mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	if(CGRectEqualToRect(contentRect, CGRectZero)) {
		contentRect = mediaBox;
	}

	CGSize scale = CGSizeMake(imageSize.width / contentRect.size.width, imageSize.height / contentRect.size.height);
	
	CGContextRef context = BitmapContextCreate(imageSize, NO);
	CGContextClearRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));

	CGContextScaleCTM(context, scale.width, scale.height);
//	CGContextScaleCTM(context, 1, -1);
//	CGContextTranslateCTM(context, 0, -mediaBox.size.height);
	CGContextTranslateCTM(context, -CGRectGetMinX(contentRect), CGRectGetMinY(contentRect));
	CGContextDrawPDFPage(context, page);
	
	CGImageRef image = CGBitmapContextCreateImage(context);

	BitmapContextFreeData(context);
	CGContextRelease(context);
	CGPDFDocumentRelease(doc);
	
	return image;
}

void ContextFillRectColor(CGContextRef context, CGRect rect, CGColorRef color)
{
	CGContextSaveGState(context);
		CGContextSetFillColorWithColor(context, color);
		CGContextFillRect(context, rect);
	CGContextRestoreGState(context);
}

void ContextFillRectGray(CGContextRef context, CGRect rect, CGFloat gray, CGFloat alpha)
{
	CGColorRef c = CreateColorWithGray(gray, alpha);
	ContextFillRectColor(context, rect, c);
	CGColorRelease(c);
}

void ContextFillPathColor(CGContextRef context, CGPathRef path, CGColorRef color)
{
	CGContextSaveGState(context);
		CGContextAddPath(context, path);
		CGContextClip(context);
		ContextFillRectColor(context, CGPathGetBoundingBox(path), color);
	CGContextRestoreGState(context);
}

void ContextFillPathGradient(CGContextRef context, CGPathRef path, CGGradientRef gradient, CGPoint point1, CGPoint point2)
{
	CGContextSaveGState(context);
		CGContextAddPath(context, path);
		CGContextClip(context);
		ContextFillRectGradient(context, CGPathGetBoundingBox(path), gradient, point1, point2);
	CGContextRestoreGState(context);
}

void ContextFillPathGradientVertical(CGContextRef context, CGPathRef path, CGGradientRef gradient)
{
	CGRect rect = CGPathGetBoundingBox(path);
	CGPoint point1 = CGPointMake(0, CGRectGetMinY(rect));
	CGPoint point2 = CGPointMake(0, CGRectGetMaxY(rect));
	ContextFillPathGradient(context, path, gradient, point1, point2);
}

void ContextFillPathGradientHorizontal(CGContextRef context, CGPathRef path, CGGradientRef gradient)
{
	CGRect rect = CGPathGetBoundingBox(path);
	CGPoint point1 = CGPointMake(CGRectGetMinX(rect), 0);
	CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), 0);
	ContextFillPathGradient(context, path, gradient, point1, point2);
}

CGColorRef CreateColorWithRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	CGFloat c[4];
	c[0] = r;
	c[1] = g;
	c[2] = b;
	c[3] = a;
	return CGColorCreate(SharedColorSpaceDeviceRGB(), c);
}

CGColorRef CreateColorWithGray(CGFloat gray, CGFloat alpha)
{
	CGFloat c[2];
	c[0] = gray;
	c[1] = alpha;
	return CGColorCreate(SharedColorSpaceDeviceGray(), c);
}

CGColorRef CreateColorByConvertingToRGB(CGColorRef color)
{
	const CGFloat* oldc = CGColorGetComponents(color);
	CGFloat newc[4];

	size_t numberOfComponents = CGColorGetNumberOfComponents(color);
	switch(numberOfComponents) {
	case 2:
		newc[0] = oldc[0];
		newc[1] = oldc[0];
		newc[2] = oldc[0];
		newc[3] = oldc[1];
		break;
	case 4:
		newc[0] = oldc[0];
		newc[1] = oldc[1];
		newc[2] = oldc[2];
		newc[3] = oldc[3];
		break;
	}

	return CGColorCreate(SharedColorSpaceDeviceRGB(), newc);
}

CGColorRef CreateColorByDarkening(CGColorRef color, CGFloat fractionDarker)
{
	const CGFloat* oldc = CGColorGetComponents(color);
	CGFloat newc[4];

	size_t numberOfComponents = CGColorGetNumberOfComponents(color);
	switch(numberOfComponents) {
	case 2:
		newc[0] = arciem::denormalize(fractionDarker, oldc[0], 0.0f);
		newc[1] = newc[0];
		newc[2] = newc[0];
		newc[3] = oldc[1];
		break;
	case 4:
		newc[0] = arciem::denormalize(fractionDarker, oldc[0], 0.0f);
		newc[1] = arciem::denormalize(fractionDarker, oldc[1], 0.0f);
		newc[2] = arciem::denormalize(fractionDarker, oldc[2], 0.0f);
		newc[3] = oldc[3];
		break;
	}

	return CGColorCreate(SharedColorSpaceDeviceRGB(), newc);
}

CGColorRef CreateColorByLightening(CGColorRef color, CGFloat fractionLighter)
{
	const CGFloat* oldc = CGColorGetComponents(color);
	CGFloat newc[4];

	size_t numberOfComponents = CGColorGetNumberOfComponents(color);
	switch(numberOfComponents) {
	case 2:
		newc[0] = arciem::denormalize(fractionLighter, oldc[0], 1.0f);
		newc[1] = newc[0];
		newc[2] = newc[0];
		newc[3] = oldc[1];
		break;
	case 4:
		newc[0] = arciem::denormalize(fractionLighter, oldc[0], 1.0f);
		newc[1] = arciem::denormalize(fractionLighter, oldc[1], 1.0f);
		newc[2] = arciem::denormalize(fractionLighter, oldc[2], 1.0f);
		newc[3] = oldc[3];
		break;
	}

	return CGColorCreate(SharedColorSpaceDeviceRGB(), newc);
}

CGColorRef CreateColorByColorDodge(CGColorRef color, CGFloat fractionLighter)
{
	const CGFloat* oldc = CGColorGetComponents(color);
	CGFloat newc[4];
	
	size_t numberOfComponents = CGColorGetNumberOfComponents(color);
	switch(numberOfComponents) {
		case 2:
			newc[0] = arciem::denormalize(fractionLighter, oldc[0], 1.0f);
			newc[1] = newc[0];
			newc[2] = newc[0];
			newc[3] = oldc[1];
			break;
		case 4:
			CGFloat invertedFraction = 1.0 - fractionLighter;
			newc[0] = fminf(oldc[0] / invertedFraction, 1.0);
			newc[1] = fminf(oldc[1] / invertedFraction, 1.0);
			newc[2] = fminf(oldc[2] / invertedFraction, 1.0);
			newc[3] = oldc[3];
			break;
	}
	
	return CGColorCreate(SharedColorSpaceDeviceRGB(), newc);
}

CGColorRef CreateColorByColorBurn(CGColorRef color, CGFloat fractionDarker)
{
	const CGFloat* oldc = CGColorGetComponents(color);
	CGFloat newc[4];
	
	size_t numberOfComponents = CGColorGetNumberOfComponents(color);
	switch(numberOfComponents) {
		case 2:
			newc[0] = arciem::denormalize(fractionDarker, oldc[0], 0.0f);
			newc[1] = newc[0];
			newc[2] = newc[0];
			newc[3] = oldc[1];
			break;
		case 4:
			CGFloat invertedFraction = 1.0 - fractionDarker;
			newc[0] = 1.0 - fminf((1.0 - oldc[0]) / invertedFraction, 1.0);
			newc[1] = 1.0 - fminf((1.0 - oldc[1]) / invertedFraction, 1.0);
			newc[2] = 1.0 - fminf((1.0 - oldc[2]) / invertedFraction, 1.0);
			newc[3] = oldc[3];
			break;
	}
	
	return CGColorCreate(SharedColorSpaceDeviceRGB(), newc);
}

CGColorRef CreateColorByInterpolatingColors(CGColorRef color1, CGColorRef color2, CGFloat fraction)
{
	CGColorRef newColor = NULL;
	
	if(CGColorGetNumberOfComponents(color1) == 4 && CGColorGetNumberOfComponents(color2) == 4) {
		const CGFloat* c1 = CGColorGetComponents(color1);
		const CGFloat* c2 = CGColorGetComponents(color2);
		
		CGFloat newc[4];
		newc[0] = arciem::denormalize(fraction, c1[0], c2[0]);
		newc[1] = arciem::denormalize(fraction, c1[1], c2[1]);
		newc[2] = arciem::denormalize(fraction, c1[2], c2[2]);
		newc[3] = c1[3];

		newColor = CGColorCreate(SharedColorSpaceDeviceRGB(), newc);
	}
	
	return newColor;
}

void ContextDrawSavingState(CGContextRef context, void (^drawing)(void))
{
	CGContextSaveGState(context);
	drawing();
	CGContextRestoreGState(context);
}