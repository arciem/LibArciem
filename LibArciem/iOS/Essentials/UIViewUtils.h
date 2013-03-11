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

#import <UIKit/UIKit.h>
#import "Geom.h"

extern NSString* const sTapInBackgroundNotification;

// See http://clang.llvm.org/docs/AutomaticReferenceCounting.html#optimization.precise
#define CFRAME __attribute__((objc_precise_lifetime)) CFrame*

@class CFrame;

@interface UIView (UIViewUtils)

- (void)fillRect:(CGRect)rect color:(UIColor*)color;
- (void)tableHeaderFillWithTintColor:(UIColor*)tintColor;
- (void)drawCrossedBox:(CGRect)rect color:(UIColor*)color lineWidth:(float)lineWidth originIndicators:(BOOL)originIndicators;
- (void)drawCrossedBox:(CGRect)rect color:(UIColor*)color lineWidth:(float)lineWidth;
- (UIImage*)capture;

- (void)sendTapInBackgroundNotification;

- (void)bringSubview:(UIView*)view aboveSubview:(UIView*)siblingSubview;
- (void)sendSubview:(UIView*)view belowSubview:(UIView*)siblingSubview;

- (void)printViewHierarchy;
- (void)printResponderChain;
- (UIResponder*)findNextResponderRespondingToSelector:(SEL)selector;
- (UIResponder*)findFirstResponder;
- (void)resignAnyFirstResponder;
- (CGRect)subviewFramesUnion;
- (void)sizeToFitSubviews;
- (void)removeAllSubviews;
//- (void)viewHierarchyPerformSelector:(SEL)selector withObject:(id)object;

- (void)addSubview:(UIView *)view animated:(BOOL)animated;
- (void)removeFromSuperviewAnimated:(BOOL)animated;

- (UIView*)addTopBevelView;
- (UIView*)addBottomBevelView;
- (UIView*)addBevelViewAtY:(CGFloat)y top:(BOOL)top;

@property(readonly, nonatomic) NSUInteger indexInSubviews;

- (void)bringToFront;
- (void)sentToBack;

- (void)bringOneLevelUp;
- (void)sendOneLevelDown;

- (BOOL)isInFront;
- (BOOL)isAtBack;

- (void)swapDepthsWithView:(UIView*)swapView;

+ (void)distributeViewsVertically:(NSArray*)views;
+ (UIEdgeInsets)edgeInsetsNegate:(UIEdgeInsets)insets;

@property(readonly, nonatomic) CGPoint origin;
@property(readonly, nonatomic) CGSize size;
@property(readonly, nonatomic) CGFloat width;
@property(readonly, nonatomic) CGFloat height;

@property(readonly, nonatomic) CGFloat top;
@property(readonly, nonatomic) CGFloat bottom;
@property(readonly, nonatomic) CGFloat left;
@property(readonly, nonatomic) CGFloat right;

@property(readonly, nonatomic) CGFloat centerX;
@property(readonly, nonatomic) CGFloat centerY;

@property(readonly, nonatomic) CGPoint boundsOrigin;
@property(readonly, nonatomic) CGSize boundsSize;
@property(readonly, nonatomic) CGFloat boundsWidth;
@property(readonly, nonatomic) CGFloat boundsHeight;

@property(readonly, nonatomic) CGFloat boundsTop;
@property(readonly, nonatomic) CGFloat boundsBottom;
@property(readonly, nonatomic) CGFloat boundsLeft;
@property(readonly, nonatomic) CGFloat boundsRight;

@property(readonly, nonatomic) CGFloat boundsCenterX;
@property(readonly, nonatomic) CGFloat boundsCenterY;
@property(readonly, nonatomic) CGPoint boundsCenter;

- (CFrame*)cframe NS_RETURNS_RETAINED;

@end

@interface CFrame : NSObject

@property(weak, readonly, nonatomic) UIView* view;
@property(nonatomic) CGRect frame;

@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGPoint center;

// setting these will not change the size of the view, only its position
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;

@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

// setting these will change the size of the view
@property(nonatomic) CGFloat flexibleTop;
@property(nonatomic) CGFloat flexibleBottom;
@property(nonatomic) CGFloat flexibleLeft;
@property(nonatomic) CGFloat flexibleRight;

+ (CFrame*)frameWithView:(UIView*)view NS_RETURNS_RETAINED;
+ (CFrame*)frameWithRect:(CGRect)rect NS_RETURNS_RETAINED;

- (void)sizeToFit;

@end

@interface UIBezierPath (UIViewUtils)

// Useful for pre-iOS 6.0. Under iOS 6.0 or later, uses -bezierPathByReversingPath. Under iOS 5.0, uses its own reversal algorithm, under which multiple subpaths are not currently supported.
- (UIBezierPath*)pathByReversingPath;

@end
