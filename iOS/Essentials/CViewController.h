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

enum
{
	CViewControllerStateValid,
	CViewControllerStateInvalid,
	CViewControllerStateActivity
};
typedef NSUInteger CViewControllerState;

extern NSString* const InterfaceDidChangeOrientationNotification;
extern NSString* const InterfaceWillChangeOrientationNotification;

@interface CViewController : UIViewController<CViewLayoutDelegate>

@property(nonatomic, getter = isInterfaceLocked) BOOL interfaceLocked;
@property(nonatomic) CViewControllerState state;
@property(nonatomic) BOOL locksInterfaceDuringActivity;
@property(assign, nonatomic) UIViewController* backButtonViewController;
@property(assign, nonatomic) UIViewAnimationTransition transitionForNextPush;
@property(nonatomic) BOOL activityShieldViewVisible;

// Called during -viewDidUnload and -dealloc. Subclasses should release any references held to objects that would have been connected when loading the controller's Nib or constructing it's views. Be sure to call super's implementation.
- (void)unload;

// Called during -initWithNibName:bundle: and -awakeFromNib. Subclasses should do any one-time initialization here. Be sure to call super's implementation.
- (void)setup;

// Called by CNavigationController when popViewControllerAnimated is called. Pop does not happen if shouldPopViewController returns NO. Default implementation returns YES.
- (BOOL)shouldPopViewController;

// behavior provided by subclasses
- (void)stateDidChangeFrom:(CViewControllerState)oldState to:(CViewControllerState)newState;
- (void)interfaceLockDidChangeTo:(BOOL)locked;
- (void)viewLayoutSubviews:(UIView*)view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithDeviceNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
