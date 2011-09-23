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

#import "UIViewUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "CGUtils.h"
#import "UIColorUtils.h"
#import "DeviceUtils.h"
#import "Geom.h"

NSString* const sTapInBackgroundNotification = @"TapInBackground";

@implementation UIView (UIViewUitls)

- (void)fillRect:(CGRect)rect color:(UIColor*)color
{
	ContextFillRectColor(UIGraphicsGetCurrentContext(), rect, color.CGColor);
}

- (void)drawCrossedBox:(CGRect)rect color:(UIColor*)color lineWidth:(float)lineWidth originIndicators:(BOOL)originIndicators
{
	ContextDrawCrossedBox(UIGraphicsGetCurrentContext(), rect, color.CGColor, lineWidth, originIndicators);
}

- (void)drawCrossedBox:(CGRect)rect color:(UIColor*)color lineWidth:(float)lineWidth
{
	ContextDrawCrossedBox(UIGraphicsGetCurrentContext(), rect, color.CGColor, lineWidth, NO);
}

- (void)sendTapInBackgroundNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:sTapInBackgroundNotification object:self];
}

- (UIImage*)capture
{
    CGRect r = [self bounds];
    
	CGFloat screenScale = ScreenScale();
    UIGraphicsBeginImageContextWithOptions(r.size, NO, screenScale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(ctx, r);
    
	[self.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
 
    return newImage;
}

- (void)bringSubview:(UIView*)view aboveSubview:(UIView*)siblingSubview
{
	if(view.superview == self) {
		[view removeFromSuperview];
		[self insertSubview:view aboveSubview:siblingSubview];
	}
}

- (void)sendSubview:(UIView*)view belowSubview:(UIView*)siblingSubview
{
	if(view.superview == self) {
		[view removeFromSuperview];
		[self insertSubview:view belowSubview:siblingSubview];
	}
}

- (void)printViewHierarchy:(UIView*)view indent:(NSString*)indent level:(int)level
{
	NSString* prefix = @"   ";
	if([view isKindOfClass:[UIScrollView class]]) {
		prefix = @"***";
	}
	NSLog(@"%@%@%3d %@", prefix, indent, level, view);
	indent = [indent stringByAppendingString:@"  |"];
	for(UIView* subview in view.subviews) {
		[self printViewHierarchy:subview indent:indent level:level+1];
	}
}

- (void)printViewHierarchy
{
	[self printViewHierarchy:self indent:@"" level:0];
}

- (void)printResponderChain
{
	UIResponder* r = self;
	do {
		r = r.nextResponder;
		CLogInfo(nil, @"%@", r);
	} while(r != nil);
}

- (UIResponder*)findNextResponderRespondingToSelector:(SEL)selector
{
	UIResponder* r = self;
	do {
		r = r.nextResponder;
		CLogInfo(nil, @"%@", r);
		if([r respondsToSelector:selector]) {
			break;
		}
	} while(r != nil);
	
	return r;
}

- (UIResponder*)findFirstResponder
{
	if(self.isFirstResponder) return self;
	for(UIView* subview in self.subviews) {
		UIResponder* firstResponder = [subview findFirstResponder];
		if(firstResponder != nil) {
			return firstResponder;
		}
	}
	return nil;
}

// Disabled because compiler complains of possible leak in performSelector due to unknown selector
#if 0
- (void)viewHierarchyPerformSelector:(SEL)selector withObject:(id)object
{
	if([self respondsToSelector:selector]) {
		[self performSelector:selector withObject:object];
	}

	for(UIView* subview in self.subviews) {
		[subview viewHierarchyPerformSelector:selector withObject:object];
	}
}
#endif

- (void)sizeToFitSubviews
{
	CGRect r = [self subviewFramesUnion];
	CGRect frame = self.frame;
	frame.size = r.size;
	self.frame = frame;
}

- (void)removeAllSubviews
{
	NSArray* subviews = [NSArray arrayWithArray:self.subviews];
	for(UIView* subview in subviews) {
		[subview removeFromSuperview];
	}
}

- (CGRect)subviewFramesUnion
{
//	GOLog(@"begin subviewFramesUnion");
	CGRect r = CGRectZero;
	for (UIView* subview in self.subviews) {
//		GOLog(@"%@", subview);
		if(CGRectIsEmpty(r)) {
			r = subview.frame;
		} else {
			r = CGRectUnion(r, subview.frame);
		}
	}
//	GOLog(@"end subviewFramesUnion");
	return r;
}

- (CGPoint)origin
{
	return self.frame.origin;
}

- (CGSize)size
{
	return self.frame.size;
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (CGFloat)height
{
	return self.frame.size.height;
}

- (CGFloat)top
{
	return self.frame.origin.y;
}

- (CGFloat)bottom
{
	return CGRectGetMaxY(self.frame);
}

- (CGFloat)left
{
	return self.frame.origin.x;
}

- (CGFloat)right
{
	return CGRectGetMaxX(self.frame);
}

- (CGFloat)centerX
{
	return self.center.x;
}

- (CGFloat)centerY
{
	return self.center.y;
}

- (CGFloat)flexibleTop
{
	return self.top;
}

- (CGFloat)flexibleBottom
{
	return self.bottom;
}

- (CGFloat)flexibleLeft
{
	return self.left;
}

- (CGFloat)flexibleRight
{
	return self.right;
}

- (void)setOrigin:(CGPoint)origin
{
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}

- (void)setSize:(CGSize)size
{
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}

- (void)setWidth:(CGFloat)width
{
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (void)setTop:(CGFloat)top
{
	CGRect frame = self.frame;
	frame.origin.y = top;
	self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom
{
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}

- (void)setLeft:(CGFloat)left
{
	CGRect frame = self.frame;
	frame.origin.x = left;
	self.frame = frame;
}

- (void)setRight:(CGFloat)right
{
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

- (void)setCenterX:(CGFloat)x
{
	CGRect frame = self.frame;
	frame = [Geom alignRectMidX:frame toX:x];
	self.frame = CGRectIntegral(frame);
}

- (void)setCenterY:(CGFloat)y
{
	CGRect frame = self.frame;
	frame = [Geom alignRectMidY:frame toY:y];
	self.frame = CGRectIntegral(frame);
}

- (void)setFlexibleTop:(CGFloat)top
{
	CGFloat delta = top - self.top;
	CGRect frame = self.frame;
	frame.origin.y = top;
	frame.size.height -= delta;
	self.frame = frame;
}

- (void)setFlexibleBottom:(CGFloat)bottom
{
	CGFloat delta = self.bottom - bottom;
	CGRect frame = self.frame;
	frame.size.height -= delta;
	self.frame = frame;
}

- (void)setFlexibleLeft:(CGFloat)left
{
	CGFloat delta = left - self.left;
	CGRect frame = self.frame;
	frame.origin.x = left;
	frame.size.width -= delta;
	self.frame = frame;
}

- (void)setFlexibleRight:(CGFloat)right
{
	CGFloat delta = self.right - right;
	CGRect frame = self.frame;
	frame.size.width -= delta;
	self.frame = frame;
}

- (void)addSubview:(UIView *)view animated:(BOOL)animated
{
	if(view.superview == nil) {
		if(animated) {
			view.alpha = 0.0;
			[self addSubview:view];
			[UIView beginAnimations:@"viewAppearance" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(appearanceAnimationDidStop:finished:context:)];
			view.alpha = 1.0;
//			[self retain];	// balanced in appearanceAnimationDidStop
			[UIView commitAnimations];
		} else {
			[self addSubview:view];
			view.alpha = 1.0;
		}
	}
}

- (void)appearanceAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
//	[self release];
}

- (void)removeFromSuperviewAnimated:(BOOL)animated
{
	if(self.superview != nil) {
		if(animated) {
			[UIView beginAnimations:@"viewDisappearance" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(disappearanceAnimationDidStop:finished:context:)];
			self.alpha = 0.0;
//			[self.superview retain]; // balanced in disappearanceAnimationDidStop
			[UIView commitAnimations];
		} else {
			[self removeFromSuperview];
		}
	}
}

- (void)disappearanceAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
//	UIView* superview = self.superview;
	[self removeFromSuperview];
//	[superview release];
}

- (void)tableHeaderFillWithTintColor:(UIColor*)tintColor
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGColorRef tintColorRGB = CreateColorByConvertingToRGB(tintColor.CGColor);
	CGColorRef darkColor = CreateColorByDarkening(tintColorRGB, 0.1);
	CGColorRef lightColor = CreateColorByLightening(tintColorRGB, 0.1);
	CGGradientRef grad = GradientCreateWith2Colors(darkColor, lightColor, SharedColorSpaceDeviceRGB());
	
	CGRect r1 = self.bounds;
	CGRect r2;
	CGRectDivide(r1, &r1, &r2, 1.0, CGRectMinYEdge);
	CGRect r3;
	CGRectDivide(r2, &r3, &r2, 1.0, CGRectMaxYEdge);
	
	ContextFillRectColor(context, r1, lightColor);
	ContextFillRectGradientVertical(context, r2, grad);
	ContextFillRectColor(context, r3, darkColor);
	
	CGGradientRelease(grad);
	CGColorRelease(darkColor);
	CGColorRelease(lightColor);
	CGColorRelease(tintColorRGB);
}

+ (void)distributeViewsVertically:(NSArray*)views
{
	if(views.count > 2) {
		CGFloat yMin = INFINITY;
		CGFloat yMax = -INFINITY;
		CGFloat viewsHeight = 0.0;
		
		for(UIView* view in views) {
			viewsHeight += view.height;
			yMin = MIN(yMin, view.top);
			yMax = MAX(yMax, view.bottom);
		}
		
		CGFloat totalHeight = yMax - yMin;
		CGFloat space = totalHeight - viewsHeight;
		CGFloat gapCount = views.count - 1;
		CGFloat spacePerGap = space / gapCount;
		
		for(NSUInteger i = 0; i < views.count - 2; i++) {
			UIView* view = [views objectAtIndex:i];
			UIView* nextView = [views objectAtIndex:i + 1];
			nextView.top = roundf(view.bottom + spacePerGap);
		}
	}
}

+ (UIEdgeInsets)edgeInsetsNegate:(UIEdgeInsets)insets
{
	return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

+ (NSInteger)shadowVerticalMultiplier
{
    static NSInteger shadowVerticalMultiplier = 0;
    if (0 == shadowVerticalMultiplier) {
        CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        shadowVerticalMultiplier = (systemVersion < 3.2f) ? 1 : -1;
    }
	
    return shadowVerticalMultiplier;
}
@end
