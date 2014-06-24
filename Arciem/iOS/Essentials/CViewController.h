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
#import "CImageView.h"

typedef NS_ENUM(NSInteger, CViewControllerState) {
	CViewControllerStateValid,
	CViewControllerStateActivity,
	CViewControllerStateInvalid
};

extern NSString* const InterfaceDidChangeOrientationNotification;
extern NSString* const InterfaceWillChangeOrientationNotification;

@interface CViewController : UIViewController

@property(nonatomic, getter = isInterfaceLocked) BOOL interfaceLocked;
@property(nonatomic) CViewControllerState state;
@property(nonatomic) BOOL locksInterfaceDuringActivity;
@property(assign, nonatomic) UIViewController* backButtonViewController;
@property(assign, nonatomic) UIViewAnimationTransition transitionForNextPush;
@property(nonatomic) BOOL activityShieldViewVisible;
@property(nonatomic) NSNumber* overrideDisablesAutomaticKeyboardDismissal;
@property(readonly, nonatomic) UIModalPresentationStyle effectiveModalPresentationStyle;

// Called during -initWithNibName:bundle: and -awakeFromNib. Subclasses should do any one-time initialization here. Be sure to call super's implementation.
- (void)setup;

// Called by CNavigationController when popViewControllerAnimated is called. Pop does not happen if shouldPopViewController returns NO. Default implementation returns YES.
- (BOOL)shouldPopViewController;

// May be overridden in subclasses
- (void)interfaceLockDidChangeTo:(BOOL)locked;

// Behavior provided by subclasses
- (void)stateDidChangeFrom:(CViewControllerState)oldState to:(CViewControllerState)newState;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (instancetype)initWithDeviceNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (void)setStatusBarStyleIfFullScreen:(UIStatusBarStyle)statusBarStyle;

@end
