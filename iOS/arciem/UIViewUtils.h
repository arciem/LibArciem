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

extern NSString* const sTapInBackgroundNotification;

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
- (CGRect)subviewFramesUnion;
- (void)sizeToFitSubviews;
- (void)removeAllSubviews;
//- (void)viewHierarchyPerformSelector:(SEL)selector withObject:(id)object;

- (void)addSubview:(UIView *)view animated:(BOOL)animated;
- (void)removeFromSuperviewAnimated:(BOOL)animated;
- (void)appearanceAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)disappearanceAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

+ (void)distributeViewsVertically:(NSArray*)views;
+ (UIEdgeInsets)edgeInsetsNegate:(UIEdgeInsets)insets;

// See: http://stackoverflow.com/questions/2997501/cgcontextsetshadow-shadow-direction-reversed-between-ios-3-0-and-4-0
+ (NSInteger)shadowVerticalMultiplier;

@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

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

@end
