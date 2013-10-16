/*******************************************************************************
 
 Copyright 2013 Arciem LLC
 
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

#import "CBadgeView.h"
#import "ObjectUtils.h"
#import "StringUtils.h"
#import "DeviceUtils.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static const CGFloat kBadgeSize = 20.0;
static const CGFloat kFontSize = 14.0;

@interface CBadgeView ()

@property (readonly, nonatomic) CGFloat unscaledFontSize;
@property (readonly, nonatomic) UIFont* unscaledFont;
@property (readonly, nonatomic) CGSize unscaledTextSize;
@property (readonly, nonatomic) CGSize unscaledImageSize;

@property (readonly, nonatomic) CGSize scaledImageSize;
@property (readonly, nonatomic) CGRect scaledImageBounds;
@property (readonly, nonatomic) UIFont* scaledFont;
@property (readonly, nonatomic) CGSize scaledViewSize;

@property (readonly, nonatomic) CGRect shadowBounds;
@property (readonly, nonatomic) CGSize imageOffset;

@end

@implementation CBadgeView

@synthesize text = _text;
@synthesize scaleFactor = _scaleFactor;
@synthesize shadowOffset = _shadowOffset;
@synthesize shadowRadius = _shadowRadius;

- (void)setup {
    [super setup];

//    self.debugColor = [UIColor yellowColor];

    self.userInteractionEnabled = NO;

    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor whiteColor];
    self.fillColor = [UIColor redColor];
    self.cornerRoundness = 0.5;
    self.scaleFactor = 1.0;

//    if(!IsOSVersionAtLeast7()) {
//        self.strokeColor = [UIColor whiteColor];
//        self.hasGloss = YES;
//        _shadowRadius = 3.0;
//        _shadowOffset = CGSizeMake(0.0, 1.0);
//    }
}

+ (CBadgeView*)badgeViewWithText:(NSString *)text {
    CBadgeView* view = [CBadgeView new];
    view.text = text;
    return view;
}

+ (CBadgeView*)badgeViewWithText:(NSString *)text textColor:(UIColor*)textColor fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor scaleFactor:(CGFloat)scaleFactor gloss:(BOOL)hasGloss {
    
    CBadgeView* view = [CBadgeView new];
    view.textColor = textColor;
    view.fillColor = fillColor;
    view.strokeColor = strokeColor;
    view.scaleFactor = scaleFactor;
    view.hasGloss = hasGloss;
    view.text = text;
    return view;
}

- (void)syncToSize {
    [self sizeToFit];
    [self setNeedsDisplay];
}

- (NSString*)text {
    return _text;
}

- (void)setText:(NSString *)text {
    if(!Same(_text, text)) {
        _text = text;
        [self syncToSize];
    }
}

- (CGFloat)scaleFactor {
    return _scaleFactor;
}

- (void)setScaleFactor:(CGFloat)scaleFactor {
    if(fabs(_scaleFactor - scaleFactor) > 0.001) {
        _scaleFactor = scaleFactor;
        [self syncToSize];
    }
}

- (CGFloat)shadowRadius {
    return _shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    if(fabs(_shadowRadius - shadowRadius) > 0.001) {
        _shadowRadius = shadowRadius;
        [self syncToSize];
    }
}

- (CGSize)shadowOffset {
    return _shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    if(!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        [self syncToSize];
    }
}

- (CGFloat)unscaledFontSize {
    CGFloat fontSize = kFontSize;
//    if(self.text.length < 2) {
//        fontSize += fontSize * 0.20;
//    }
    return fontSize;
}

- (UIFont*)unscaledFont {
    return [UIFont boldSystemFontOfSize:self.unscaledFontSize];
}

- (CGSize)unscaledTextSize {
    return [self.text sizeWithFont:self.unscaledFont];
}

- (CGSize)unscaledImageSize {
    CGSize imageSize = CGSizeMake(kBadgeSize, kBadgeSize);
    
    if(self.text.length > 1) {
        CGSize textSize = self.unscaledTextSize;
        imageSize.width += textSize.width;
        imageSize.width -= kBadgeSize / 3;
    }
    
    return imageSize;
}

- (CGSize)scaledImageSize {
    CGSize size = self.unscaledImageSize;
    return CGSizeMake(size.width * self.scaleFactor, size.height * self.scaleFactor);
}

- (CGRect)scaledImageBounds {
    CGRect imageBounds = CGRectZero;
    imageBounds.size = self.scaledImageSize;
    return imageBounds;
}

- (CGRect)shadowBounds {
    CGRect shadowBounds = self.scaledImageBounds;
    
    CGFloat shadowInset = -self.shadowRadius;
    shadowBounds = CGRectInset(shadowBounds, shadowInset, shadowInset);
    shadowBounds = CGRectOffset(shadowBounds, self.shadowOffset.width, self.shadowOffset.height);
    
    return shadowBounds;
}

- (CGSize)scaledViewSize {
    CGRect imageBounds = self.scaledImageBounds;
    CGRect shadowBounds = self.shadowBounds;
    CGRect r = CGRectUnion(imageBounds, shadowBounds);
    return r.size;
}

- (CGSize)imageOffset {
    CGRect imageBounds = self.scaledImageBounds;

    CGRect shadowBounds = imageBounds;
    CGFloat shadowInset = -self.shadowRadius;
    shadowBounds = CGRectInset(shadowBounds, shadowInset, shadowInset);
    shadowBounds = CGRectOffset(shadowBounds, self.shadowOffset.width, self.shadowOffset.height);

    CGFloat ox = std::max(0.0f, imageBounds.origin.x - shadowBounds.origin.x);
    CGFloat oy = std::max(0.0f, imageBounds.origin.y - shadowBounds.origin.y);
    CGSize offset = CGSizeMake(ox, oy);
    return offset;
    //    CGRect shadowBounds = self.shadowBounds;
//    return CGSizeMake(shadowBounds.origin.x, shadowBounds.origin.y);
//    CGFloat ox = std::max(0.0f, -self.shadowOffset.width);
//    CGFloat oy = std::max(0.0f, -self.shadowOffset.height);
//    ox += self.shadowRadius;
//    oy += self.shadowRadius;
//    return CGSizeMake(ox, oy);
}

- (UIFont*)scaledFont {
    return [UIFont boldSystemFontOfSize:self.unscaledFontSize * self.scaleFactor];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return self.scaledViewSize;
}

- (void)drawFillWithContext:(CGContextRef)context rect:(CGRect)rect {
	CGContextSaveGState(context);
	
	CGFloat r = CGRectGetHeight(rect) * self.cornerRoundness;
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
    
    CGContextBeginPath(context);
	CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
	CGContextAddArc(context, maxX - r, minY + r, r, M_PI + (M_PI / 2),  0,                  0);
	CGContextAddArc(context, maxX - r, maxY - r, r, 0,                  M_PI / 2,           0);
	CGContextAddArc(context, minX + r, maxY - r, r, M_PI / 2,           M_PI,               0);
	CGContextAddArc(context, minX + r, minY + r, r, M_PI,               M_PI + M_PI / 2,    0);
	CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowRadius, [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    
	CGContextRestoreGState(context);
}

- (void)drawGlossWithContext:(CGContextRef)context rect:(CGRect)rect {
	CGContextSaveGState(context);
    
	CGFloat r = CGRectGetHeight(rect) * self.cornerRoundness;

	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
    
	CGContextBeginPath(context);
	CGContextAddArc(context, maxX - r, minY + r, r, M_PI + (M_PI / 2),    0,                  0);
	CGContextAddArc(context, maxX - r, maxY - r, r, 0,                    M_PI/2,             0);
	CGContextAddArc(context, minX + r, maxY - r, r, M_PI / 2,             M_PI,               0);
	CGContextAddArc(context, minX + r, minY + r, r, M_PI,                 M_PI + M_PI / 2,    0);
	CGContextClip(context);
	
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 0.4 };
	CGFloat components[8] = {  0.92, 0.92, 0.92, 1.0, 0.82, 0.82, 0.82, 0.4 };
    
	CGColorSpaceRef cspace;
	CGGradientRef gradient;
	cspace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents (cspace, components, locations, num_locations);
	
	CGPoint sPoint, ePoint;
	sPoint.x = 0;
	sPoint.y = 0;
	ePoint.x = 0;
	ePoint.y = maxY;
	CGContextDrawLinearGradient (context, gradient, sPoint, ePoint, 0);
	
	CGColorSpaceRelease(cspace);
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);
}

- (void)drawStrokeWithContext:(CGContextRef)context rect:(CGRect)rect {
	CGFloat r = CGRectGetHeight(rect) * self.cornerRoundness;

    CGFloat lineWidth = std::max(1.0f, 2.0f * self.scaleFactor);
    rect = CGRectInset(rect, lineWidth / 2 - 0.5, lineWidth / 2 - 0.5);

	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	
    CGContextBeginPath(context);
	CGContextSetLineWidth(context, lineWidth);
	CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
	CGContextAddArc(context, maxX - r, minY + r, r, M_PI+(M_PI/2),  0,              0);
	CGContextAddArc(context, maxX - r, maxY - r, r, 0,              M_PI/2,         0);
	CGContextAddArc(context, minX + r, maxY - r, r, M_PI/2,         M_PI,           0);
	CGContextAddArc(context, minX + r, minY + r, r, M_PI,           M_PI+M_PI/2,    0);
	CGContextClosePath(context);
	CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

	CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGSize offset = self.imageOffset;
    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, offset.width, offset.height);
    CGContextConcatCTM(context, transform);
    
    CGRect bounds = CGRectZero;
    bounds.size = self.scaledImageSize;

	[self drawFillWithContext:context rect:bounds];
	
	if(self.hasGloss) {
		[self drawGlossWithContext:context rect:bounds];
	}
	
	if(self.strokeColor != nil)  {
		[self drawStrokeWithContext:context rect:bounds];
	}
	
	if(!IsEmptyString(self.text)) {
		[self.textColor set];
		UIFont *textFont = self.scaledFont;
		CGSize textSize = [self.text sizeWithFont:textFont];
        CGPoint p = CGPointMake((bounds.size.width / 2 - textSize.width / 2), (bounds.size.height / 2 - textSize.height / 2));
        p.x += 0.25;
		[self.text drawAtPoint:p withFont:textFont];
	}

	CGContextRestoreGState(context);
}

@end
