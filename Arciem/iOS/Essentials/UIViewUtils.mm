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
#import "StringUtils.h"
#import "ObjectUtils.h"
#import "CView.h"
#import "ThreadUtils.h"
#import "UIImageUtils.h"

NSString* const sTapInBackgroundNotification = @"TapInBackground";
static const NSTimeInterval kAnimationDuration = 0.4;

@implementation UIView (UIViewUitls)

- (void)fillRect:(CGRect)rect color:(UIColor*)color
{
	ContextFillRectColor(UIGraphicsGetCurrentContextChecked(), rect, color.CGColor);
}

- (void)drawCrossedBox:(CGRect)rect color:(UIColor*)color lineWidth:(float)lineWidth originIndicators:(BOOL)originIndicators
{
	ContextDrawCrossedBox(UIGraphicsGetCurrentContextChecked(), rect, color.CGColor, lineWidth, originIndicators);
}

- (void)drawCrossedBox:(CGRect)rect color:(UIColor*)color lineWidth:(float)lineWidth
{
	ContextDrawCrossedBox(UIGraphicsGetCurrentContextChecked(), rect, color.CGColor, lineWidth, NO);
}

- (void)sendTapInBackgroundNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:sTapInBackgroundNotification object:self];
}

- (UIImage*)capture
{
    UIImage *image = nil;
    
    CGRect r = [self bounds];

    CGContextRef ctx = [UIImage beginImageContextWithSize:r.size opaque:NO scale:0.0 flipped:NO];

//    if(IsOSVersionAtLeast7()) {
//        [self drawViewHierarchyInRect:r afterScreenUpdates:NO];
//    } else {
        [[UIColor clearColor] set];
        CGContextFillRect(ctx, r);
        [self.layer renderInContext:ctx];
//    }

    image = [UIImage endImageContext];
    return image;
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

- (void)exerciseAmbiguityInViewHierarchy:(UIView *)view {
    if(view.hasAmbiguousLayout) {
        [view exerciseAmbiguityInLayout];
    }
	for(UIView* subview in view.subviews) {
		[self exerciseAmbiguityInViewHierarchy:subview];
	}
}

- (void)exerciseAmbiguityInViewHierarchy {
    [self exerciseAmbiguityInViewHierarchy:self];
}

- (void)animateAmbiguityInViewHierarchy {
    BSELF;
    [NSThread performBlockOnMainThread:^(BOOL *stop) {
        [UIView animateWithDuration:0.2 animations:^{
            if(bself == nil) {
                *stop = YES;
//                CLogDebug(nil, @"STOPPED");
            } else {
//                CLogDebug(nil, @"RUNNING");
                [bself exerciseAmbiguityInViewHierarchy];
            }
        }];
    } repeatInterval:1.0];
}

- (void)walkViewHierarchyWithLevel:(NSUInteger)level block:(void (^)(UIView *view, NSUInteger level, NSUInteger idx, BOOL *stop))block {
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        block(view, level, idx, stop);
        if(!(*stop)) {
            [view walkViewHierarchyWithLevel:(level + 1) block:block];
        }
    }];
}

- (void)walkViewHierarchyWithBlock:(void (^)(UIView *view, NSUInteger level, NSUInteger idx, BOOL *stop))block {
    [self walkViewHierarchyWithLevel:0 block:block];
}

- (void)printViewHierarchy:(UIView*)view indent:(NSString*)indent level:(NSUInteger)level
{
#ifdef DEBUG
    NSString *scrollViewPrefix = @"⬜️";
    if([view isKindOfClass:[UIScrollView class]]) {
        scrollViewPrefix = @"🔃";
        UIScrollView *scrollView = (UIScrollView *)view;
        if(scrollView.scrollsToTop) {
            scrollViewPrefix = @"🔝";
        }
    }
    NSString *translatesPrefix = view.translatesAutoresizingMaskIntoConstraints ? @"⬜️" : @"✅";
    NSString *ambiguousPrefix = view.hasAmbiguousLayout ? @"❓" : @"⬜️";

    NSMutableArray *auxInfoStrings = [NSMutableArray new];

    [auxInfoStrings addObject:[NSString stringWithFormat:@"opaque:%@", StringFromBool(view.opaque)]];

    [auxInfoStrings addObject:[NSString stringWithFormat:@"backgroundColor:%@", view.backgroundColor]];
    
    if([view isKindOfClass:[UILabel class]]) {
        [auxInfoStrings addObject:[NSString stringWithFormat:@"textColor:%@", ((UILabel *)view).textColor]];
    }
    
    if(IsOSVersionAtLeast7()) {
        [auxInfoStrings addObject:[NSString stringWithFormat:@"tintColor:%@", view.tintColor]];
    }

    [auxInfoStrings addObject:[NSString stringWithFormat:@"alpha:%f", view.alpha]];

    NSString *debugName = view.debugName;
    NSString *debugNameString = IsEmptyString(debugName) ? @"" : [NSString stringWithFormat:@"%@: ", debugName];
    NSString *auxInfoString = StringByJoiningNonemptyStringsWithString(auxInfoStrings, @" ");
    NSString *prefix = [NSString stringWithFormat:@"%@ %@ %@", scrollViewPrefix, translatesPrefix, ambiguousPrefix];
	CLogPrint(@"%@%@%3d %@%@ %@", prefix, indent, level, debugNameString, view, auxInfoString);
    
	indent = [indent stringByAppendingString:@"  │"];
	for(UIView* subview in view.subviews) {
		[self printViewHierarchy:subview indent:indent level:level+1];
	}
#endif
}

- (void)printViewHierarchy {
	[self printViewHierarchy:self indent:@"" level:0];
}

- (void)printConstraintsHierarchy:(UIView*)view indent:(NSString*)indent level:(int)level
{
#ifdef DEBUG
    NSString *translatesPrefix = view.translatesAutoresizingMaskIntoConstraints ? @"⬜️" : @"✅";
    NSString *ambiguousPrefix = view.hasAmbiguousLayout ? @"❓" : @"⬜️";
    NSString* prefix = [NSString stringWithFormat:@"%@ %@ ", translatesPrefix, ambiguousPrefix];
    NSString *debugName = view.debugName;
    NSString *debugNameString = IsEmptyString(debugName) ? @"" : [NSString stringWithFormat:@"%@: ", debugName];
    NSString *viewString = [NSString stringWithFormat:@"%@<%p>", NSStringFromClass([view class]), view];
    NSString *frameString = [NSString stringWithFormat:@"(%g %g; %g %g)", view.left, view.top, view.width, view.height];
	CLogPrint(@"%@⬜️ %@%3d %@%@ %@", prefix, indent, level, debugNameString, viewString, frameString);
    for(NSLayoutConstraint *constraint in view.constraints) {
        NSString *layoutGroupName = constraint.layoutGroupName;
        NSString *layoutGroupNameString = IsEmptyString(layoutGroupName) ? @"" : [NSString stringWithFormat:@"%@: ", layoutGroupName];
        CLogPrint(@"⬜️ ⬜️ 🔵 %@  │    %@%@", indent, layoutGroupNameString, constraint);
    }
	indent = [indent stringByAppendingString:@"  │"];
	for(UIView* subview in view.subviews) {
		[self printConstraintsHierarchy:subview indent:indent level:level+1];
	}
#endif
}

- (void)printConstraintsHierarchy {
    [self printConstraintsHierarchy:self indent:@"" level:0];
}

- (void)printResponderChain {
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
	CGContextRef context = UIGraphicsGetCurrentContextChecked();

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

- (CFrame*)cframe NS_RETURNS_RETAINED
{
	return [CFrame frameWithView:self];
}

- (BOOL)tapResignsFirstResponder {
    return [[self associatedObjectForKey:@"tapResignsFirstResponder"] boolValue];
}

- (void)setTapResignsFirstResponder:(BOOL)tapResignsFirstResponder {
    id obj = nil;
    if(tapResignsFirstResponder) {
        obj = [NSNumber numberWithBool:YES];
    }
    [self setAssociatedObject:obj forKey:@"tapResignsFirstResponder"];
}

- (NSLayoutConstraint *)constrainLeadingEqualToLeadingOfItem:(id)item {
    return [self constrainLeadingEqualToLeadingOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainTrailingEqualToTrailingOfItem:(id)item {
    return [self constrainTrailingEqualToTrailingOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainLeadingEqualToTrailingOfItem:(id)item {
    return [self constrainLeadingEqualToTrailingOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainTopEqualToTopOfItem:(id)item {
    return [self constrainTopEqualToTopOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainBottomEqualToBottomOfItem:(id)item {
    return [self constrainBottomEqualToBottomOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainTopEqualToBottomOfItem:(id)item {
    return [self constrainTopEqualToBottomOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainCenterXEqualToCenterXOfItem:(id)item {
    return [self constrainCenterXEqualToCenterXOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainCenterYEqualToCenterYOfItem:(id)item {
    return [self constrainCenterYEqualToCenterYOfItem:item offset:0.0];
}

- (NSArray *)constrainCenterEqualToCenterOfItem:(id)item {
    return [self constrainCenterEqualToCenterOfItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainHeightEqualToItem:(id)item {
    return [self constrainHeightEqualToItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainWidthEqualToItem:(id)item {
    return [self constrainWidthEqualToItem:item offset:0.0];
}

- (NSLayoutConstraint *)constrainWidthEqualTo:(CGFloat)width {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
}

- (NSLayoutConstraint *)constrainHeightEqualTo:(CGFloat)height {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
}

- (NSLayoutConstraint *)constrainWidthEqualToItem:(id)item multiplier:(CGFloat)multiplier offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeWidth multiplier:multiplier constant:constant];
}

- (NSLayoutConstraint *)constrainHeightEqualToItem:(id)item multiplier:(CGFloat)multiplier offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeHeight multiplier:multiplier constant:constant];
}

- (NSArray *)constrainSizeEqualTo:(CGSize)size {
    return @[
             [self constrainWidthEqualTo:size.width],
             [self constrainHeightEqualTo:size.height]
             ];
}



- (NSLayoutConstraint *)constrainLeadingEqualToLeadingOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeLeading multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainTrailingEqualToTrailingOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainLeadingGreaterThanOrEqualToLeadingOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:item attribute:NSLayoutAttributeLeading multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainTrailingLessThanOrEqualToTrailingOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:item attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainLeadingEqualToTrailingOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainTopEqualToTopOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeTop multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainBottomEqualToBottomOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeBottom multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainTopEqualToBottomOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeBottom multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainCenterXEqualToCenterXOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainCenterYEqualToCenterYOfItem:(id)item offset:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:constant];
}

- (NSLayoutConstraint *)constrainHeightEqualToItem:(id)item offset:(CGFloat)constant {
    return [self constrainHeightEqualToItem:item multiplier:1.0 offset:constant];
}

- (NSLayoutConstraint *)constrainWidthEqualToItem:(id)item offset:(CGFloat)constant {
    return [self constrainWidthEqualToItem:item multiplier:1.0 offset:constant];
}


- (NSArray *)constrainCenterEqualToCenterOfItem:(id)item offset:(CGFloat)constant {
    return @[
             [self constrainCenterXEqualToCenterXOfItem:item],
             [self constrainCenterYEqualToCenterYOfItem:item]
             ];
}

- (NSArray *)constrainSizeToSizeOfItem:(id)item {
    return @[
             [self constrainWidthEqualToItem:item],
             [self constrainHeightEqualToItem:item]
             ];
}

- (NSArray *)constrainFrameToFrameOfItem:(id)item {
    NSArray *a1 = [self constrainCenterEqualToCenterOfItem:item];
    NSArray *a2 = [self constrainSizeToSizeOfItem:item];
    NSArray *a = [a1 arrayByAddingObjectsFromArray:a2];
    return a;
}

- (NSArray *)constrainLeadingAndTrailingSpacingEqual {
    CView *spacer1 = [CView new];
    spacer1.translatesAutoresizingMaskIntoConstraints = NO;
    spacer1.debugName = @"spacer1";
    spacer1.layoutView = YES;
    [self.superview insertSubview:spacer1 belowSubview:self];
    CView *spacer2 = [CView new];
    spacer2.translatesAutoresizingMaskIntoConstraints = NO;
    spacer2.debugName = @"spacer2";
    spacer2.layoutView = YES;
    [self.superview insertSubview:spacer2 aboveSubview:self];

    NSDictionary *views = @{@"self": self, @"spacer1": spacer1, @"spacer2": spacer2};

    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[spacer1][self][spacer2(==spacer1)]|" options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[self]-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:spacer1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:spacer2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[spacer1(==self)]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[spacer2(==self)]" options:0 metrics:nil views:views]];

    [self.superview addConstraints:constraints];
    
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    return constraints;
}

- (void)collectKeyViewsIntoArray:(NSMutableArray *)keyViews {
    for(UIView *subview in self.subviews) {
        if([subview conformsToProtocol:@protocol(UITextInputTraits)]) {
            if([subview canBecomeFirstResponder]) {
                if(!subview.hidden) {
                    [keyViews addObject:subview];
                }
            }
        } else {
            [subview collectKeyViewsIntoArray:keyViews];
        }
    }
}

- (NSArray *)collectKeyViews {
    NSMutableArray *keyViews = [NSMutableArray new];
    [self collectKeyViewsIntoArray:keyViews];
    return [keyViews copy];
}

- (NSArray *)subviewsSortedByReadingOrder:(NSArray *)subviews {
    return [subviews sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(UIView *subview1, UIView *subview2) {
        CGRect rect1 = [self convertRect:subview1.frame fromView:subview1.superview];
        CGRect rect2 = [self convertRect:subview2.frame fromView:subview2.superview];
        
        NSComparisonResult result = NSOrderedSame;
        
        if(rect1.origin.y > rect2.origin.y) {
            result = NSOrderedDescending;
        } else if(rect1.origin.y < rect2.origin.y) {
            result = NSOrderedAscending;
        } else {
            if(rect1.origin.x > rect2.origin.x) {
                result = NSOrderedDescending;
            } else if(rect1.origin.x < rect2.origin.x) {
                result = NSOrderedAscending;
            }
        }
        
        return result;
    }];
}

- (void)visitAllDescendentViewsWithBlock:(view_block_t)block {
    block(self);
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview visitAllDescendentViewsWithBlock:block];
    }];
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

- (instancetype)initWithView:(UIView*)view
{
	if(self = [super init]) {
		view_ = view;
		frame_ = view_.frame;
		CLogTrace(@"C_FRAME", @"%@ initWithView:%@", self, view_);
	}
	
	
	return self;
}

- (instancetype)initWithRect:(CGRect)rect
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

@implementation UIBezierPath (UIViewUtils)

- (UIBezierPath*)pathByReversingPath
{
    UIBezierPath* reversedPath = nil;
    if([self respondsToSelector:@selector(bezierPathByReversingPath)]) {
        reversedPath = [self bezierPathByReversingPath];
    } else {
        CGPathRef reversedCGPath = CreatePathReversed(self.CGPath);
        reversedPath = [UIBezierPath bezierPathWithCGPath:reversedCGPath];
        CGPathRelease(reversedCGPath);
    }

    return reversedPath;
}

@end

@interface CLayoutConstraintsGroup ()

@property(weak, nonatomic) id owner;
@property(nonatomic) NSMutableArray *mutableConstraints;

@end

@implementation CLayoutConstraintsGroup

@synthesize mutableConstraints = _mutableConstraints;
@synthesize name = _name;

- (instancetype)initWithName:(NSString*)name owner:(id)owner
{
    if(self = [super init]) {
        _name = name;
        _owner = owner;
        _mutableConstraints = [NSMutableArray new];
    }
    return self;
}

+ (instancetype)groupWithOwner:(id)owner NS_RETURNS_RETAINED
{
    return [self groupWithName:nil owner:owner];
}

+ (instancetype)groupWithName:(NSString *)name owner:(id)owner NS_RETURNS_RETAINED
{
    return [[CLayoutConstraintsGroup alloc] initWithName:name owner:owner];
}

- (void)dealloc {
    [self removeAllConstraints];
}

- (NSArray *)constraints {
    return [_mutableConstraints copy];
}

- (void)addConstraint:(NSLayoutConstraint *)constraint withPriority:(UILayoutPriority)priority {
    constraint.priority = priority;
    [_mutableConstraints addObject:constraint];
    [self.owner addConstraint:constraint];
    constraint.layoutGroupName = self.name;
    CLogDebug(@"LAYOUT_CONSTRAINTS_GROUP", @"ADDED   %@ %@", self.owner, constraint);
}

- (void)addConstraints:(NSArray *)constraints withPriority:(UILayoutPriority)priority {
    for(NSLayoutConstraint *constraint in constraints) {
        [self addConstraint:constraint withPriority:priority];
    }
}

- (void)removeConstraint:(NSLayoutConstraint *)constraint {
    [_mutableConstraints removeObject:constraint];
    [self.owner removeConstraint:constraint];
    constraint.layoutGroupName = nil;
    CLogDebug(@"LAYOUT_CONSTRAINTS_GROUP", @"REMOVED %@ %@", self.owner, constraint);
}

- (void)addConstraint:(NSLayoutConstraint *)constraint {
    [self addConstraint:constraint withPriority:constraint.priority];
}

- (void)addConstraints:(NSArray *)constraints {
    for(NSLayoutConstraint *constraint in constraints) {
        [self addConstraint:constraint withPriority:constraint.priority];
    }
}

- (void)removeConstraints:(NSArray *)constraints {
    for(NSLayoutConstraint *constraint in constraints) {
        [self removeConstraint:constraint];
    }
}

- (void)removeAllConstraints {
    [self removeConstraints:self.constraints];
}

@end

@implementation NSLayoutConstraint (UIViewUtils)

- (NSString *)layoutGroupName {
    return [self associatedObjectForKey:@"layoutGroupName"];
}

- (void)setLayoutGroupName:(NSString *)layoutGroupName {
    [self setAssociatedObject:layoutGroupName forKey:@"layoutGroupName"];
}

@end

@implementation CSpacerView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layoutView = YES;
//        self.debugColor = [UIColor redColor];
        [self setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
        [self setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (instancetype)init {
    CGRect frame = {CGPointZero, self.intrinsicContentSize};
    if(self = [self initWithFrame:frame]) {
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(20, 20);
}

+ (instancetype)addSpacerViewToSuperview:(UIView *)superview {
    CSpacerView *view = [CSpacerView new];
    [superview addSubview:view];
    return view;
}

@end