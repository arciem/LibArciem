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

#import "CViewController.h"

// These notifications are posted from within an animation block.
extern NSString *const SidebarContainerViewControllerWillShrinkCenterViewController;
extern NSString *const SidebarContainerViewControllerWillObscureCenterViewController;
extern NSString *const SidebarContainerViewControllerWillRevealCenterViewController;

// These notifications are posted before animation starts.
extern NSString *const SidebarContainerViewControllerWillSwipeOpenLeftViewController;
extern NSString *const SidebarContainerViewControllerWillSwipeClosedLeftViewController;
extern NSString *const SidebarContainerViewControllerWillSwipeOpenRightViewController;
extern NSString *const SidebarContainerViewControllerWillSwipeClosedRightViewController;

@interface CSidebarContainerViewController : CViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIViewController* centerViewController;
@property (strong, nonatomic) UIViewController* leftViewController;
@property (strong, nonatomic) UIViewController* rightViewController;

@property (strong, readonly, nonatomic) UISwipeGestureRecognizer* centerSwipeRightRecognizer;
@property (strong, readonly, nonatomic) UISwipeGestureRecognizer* centerSwipeLeftRecognizer;
@property (strong, readonly, nonatomic) UISwipeGestureRecognizer* leftSwipeLeftRecognizer;
@property (strong, readonly, nonatomic) UISwipeGestureRecognizer* rightSwipeRightRecognizer;

@property (nonatomic) BOOL leftViewVisible;
@property (nonatomic) BOOL rightViewVisible;

@property (nonatomic) CGFloat minCenterViewControllerWidth;
@property (nonatomic) UIEdgeInsets shieldViewInsets;

- (void)setLeftViewVisible:(BOOL)leftViewVisible animated:(BOOL)animated;
- (void)setRightViewVisible:(BOOL)rightViewVisible animated:(BOOL)animated;
- (void)toggleLeftViewVisibleAnimated:(BOOL)animated;
- (void)toggleRightViewVisibleAnimated:(BOOL)animated;

@end
