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
static const NSTimeInterval kAnimationDuration = 0.4;

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
	CLogPrint(@"%@%@%3d %@", prefix, indent, level, view);
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

- (void)resignAnyFirstResponder
{
	[[self findFirstResponder] resignFirstResponder];
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

- (CGPoint)boundsOrigin
{
	return self.bounds.origin;
}

- (CGSize)boundsSize
{
	return self.bounds.size;
}

- (CGFloat)boundsWidth
{
	return self.bounds.size.width;
}

- (CGFloat)boundsHeight
{
	return self.bounds.size.height;
}

- (CGFloat)boundsTop
{
	return self.bounds.origin.y;
}

- (CGFloat)boundsBottom
{
	return CGRectGetMaxY(self.bounds);
}

- (CGFloat)boundsLeft
{
	return self.bounds.origin.x;
}

- (CGFloat)boundsRight
{
	return CGRectGetMaxX(self.bounds);
}

- (CGFloat)boundsCenterX
{
	return CGRectGetMidX(self.bounds);
}

- (CGFloat)boundsCenterY
{
	return CGRectGetMidY(self.bounds);
}

- (CGPoint)boundsCenter
{
	return [Geom rectMid:self.bounds];
}

- (void)addSubview:(UIView *)view animated:(BOOL)animated
{
	if(view.superview == nil) {
		NSTimeInterval duration = animated ? kAnimationDuration : 0.0;
		view.alpha = 0.0;
		[self addSubview:view];
		[UIView animateWithDuration:duration animations:^{
			view.alpha = 1.0;
		}];
	}
}

- (void)removeFromSuperviewAnimated:(BOOL)animated
{
	if(self.superview != nil) {
		NSTimeInterval duration = animated ? kAnimationDuration : 0.0;
		[UIView animateWithDuration:duration animations:^{
			self.alpha = 0.0;
		} completion:^(BOOL finished) {
			[self removeFromSuperview];
		}];
	}
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
			UIView* view = views[i];
			UIView* nextView = views[i + 1];
			nextView.top = roundf(view.bottom + spacePerGap);
		}
	}
}

+ (UIEdgeInsets)edgeInsetsNegate:(UIEdgeInsets)insets
{
	return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

- (NSUInteger)indexInSubviews
{
	return [self.superview.subviews indexOfObject:self];
}

- (void)bringToFront
{
	[self.superview bringSubviewToFront:self];
}

- (void)sentToBack
{
	[self.superview sendSubviewToBack:self];
}

- (void)bringOneLevelUp
{
	NSUInteger currentIndex = self.indexInSubviews;
	[self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex+1];
}

- (void)sendOneLevelDown
{
	NSUInteger currentIndex = self.indexInSubviews;
	[self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex-1];
}

- (BOOL)isInFront
{
	return ([self.superview.subviews lastObject] == self);
}

- (BOOL)isAtBack
{
	return ((self.superview.subviews)[0] == self);
}

- (void)swapDepthsWithView:(UIView*)swapView
{
	[self.superview exchangeSubviewAtIndex:self.indexInSubviews withSubviewAtIndex:swapView.indexInSubviews];
}

- (UIView*)addBevelViewAtY:(CGFloat)y top:(BOOL)top
{
	NSString* imageName = top ? @"BevelTop" : @"BevelBottom";
	UIImage* bevelImage = [UIImage imageNamed:imageName];
	UIImageView* bevelView = [[UIImageView alloc] initWithImage:bevelImage];
	bevelView.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
	UIViewAutoresizing autoresizing = UIViewAutoresizingFlexibleWidth;
	if(top) {
		autoresizing |= UIViewAutoresizingFlexibleBottomMargin;
	} else {
		autoresizing |= UIViewAutoresizingFlexibleTopMargin;
	}
	bevelView.autoresizingMask = autoresizing;
	bevelView.contentMode = UIViewContentModeScaleToFill;
	CGRect bevelFrame = CGRectMake(self.boundsLeft, y, self.boundsWidth, bevelImage.size.height);
	if(!top) {
		bevelFrame.origin.y -= bevelImage.size.height;
	}
	bevelView.frame = bevelFrame;
	[self addSubview:bevelView];
	return bevelView;
}

- (UIView*)addTopBevelView
{
	return [self addBevelViewAtY:self.boundsTop top:YES];
}

- (UIView*)addBottomBevelView
{
	return [self addBevelViewAtY:self.boundsBottom top:NO];
}

- (CFrame*)cframe NS_RETURNS_RETAINED
{
	return [CFrame frameWithView:self];
}

@end

@interface CFrame ()

@property (weak, readwrite, nonatomic) UIView* view;

@end

@implementation CFrame

@synthesize view = view_;
@synthesize frame = frame_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_FRAME", YES);
}

- (id)initWithView:(UIView*)view
{
	if(self = [super init]) {
		view_ = view;
		frame_ = view_.frame;
		CLogTrace(@"C_FRAME", @"%@ initWithView:%@", self, view_);
	}
	
	
	return self;
}

- (id)initWithRect:(CGRect)rect
{
	if(self = [super init]) {
		frame_ = rect;
		CLogTrace(@"C_FRAME", @"%@ initWithRect:%@", self, NSStringFromCGRect(rect));
	}
	
	
	return self;
}

+ (CFrame*)frameWithView:(UIView*)view NS_RETURNS_RETAINED
{
	return [[self alloc] initWithView:view];
}

+ (CFrame*)frameWithRect:(CGRect)rect NS_RETURNS_RETAINED
{
    return [[self alloc] initWithRect:rect];
}


- (void)dealloc
{
	if(!CGRectEqualToRect(frame_, view_.frame)) {
		view_.frame = CGRectIntegral(frame_);
	}
	CLogTrace(@"C_FRAME", @"%@ dealloc:%@", self, view_);
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: %p %@>", [self class], self, NSStringFromCGRect(frame_)];
}

- (CGPoint)origin
{
	return frame_.origin;
}

- (CGSize)size
{
	return frame_.size;
}

- (CGFloat)width
{
	return frame_.size.width;
}

- (CGFloat)height
{
	return frame_.size.height;
}

- (CGPoint)center
{
	return CGPointMake(self.centerX, self.centerY);
}

- (CGFloat)top
{
	return frame_.origin.y;
}

- (CGFloat)bottom
{
	return CGRectGetMaxY(frame_);
}

- (CGFloat)left
{
	return frame_.origin.x;
}

- (CGFloat)right
{
	return CGRectGetMaxX(frame_);
}

- (CGFloat)centerX
{
	return self.left + self.width / 2;
}

- (CGFloat)centerY
{
	return self.top + self.height / 2;
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
	frame_.origin = origin;
}

- (void)setSize:(CGSize)size
{
	frame_.size = size;
}

- (void)setWidth:(CGFloat)width
{
	frame_.size.width = width;
}

- (void)setHeight:(CGFloat)height
{
	frame_.size.height = height;
}

- (void)setTop:(CGFloat)top
{
	frame_.origin.y = top;
}

- (void)setBottom:(CGFloat)bottom
{
	frame_.origin.y = bottom - frame_.size.height;
}

- (void)setLeft:(CGFloat)left
{
	frame_.origin.x = left;
}

- (void)setRight:(CGFloat)right
{
	frame_.origin.x = right - frame_.size.width;
}

- (void)setCenterX:(CGFloat)x
{
	frame_.origin.x = x - frame_.size.width / 2;
}

- (void)setCenterY:(CGFloat)y
{
	frame_.origin.y = y - frame_.size.height / 2;
}

- (void)setCenter:(CGPoint)center
{
	frame_.origin.x = center.x - frame_.size.width / 2;
	frame_.origin.y = center.y - frame_.size.height / 2;
}

- (void)setFlexibleTop:(CGFloat)top
{
	CGFloat delta = top - self.top;
	frame_.origin.y = top;
	frame_.size.height -= delta;
}

- (void)setFlexibleBottom:(CGFloat)bottom
{
	CGFloat delta = self.bottom - bottom;
	frame_.size.height -= delta;
}

- (void)setFlexibleLeft:(CGFloat)left
{
	CGFloat delta = left - self.left;
	frame_.origin.x = left;
	frame_.size.width -= delta;
}

- (void)setFlexibleRight:(CGFloat)right
{
	CGFloat delta = self.right - right;
	frame_.size.width -= delta;
}

- (void)sizeToFit
{
	frame_.size = [view_ sizeThatFits:frame_.size];
}

@end