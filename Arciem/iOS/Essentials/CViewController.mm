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

#import "CViewController.h"
#import "DeviceUtils.h"
#import "CActivityShieldView.h"
#import "UIViewUtils.h"

NSString* const InterfaceDidChangeOrientationNotification = @"InterfaceDidChangeOrientationNotification";
NSString* const InterfaceWillChangeOrientationNotification = @"InterfaceWillChangeOrientationNotification";

@interface CViewController ()

@property(nonatomic) CActivityShieldView* activityShieldView;

@end

@implementation CViewController

@synthesize interfaceLocked = _interfaceLocked;
@synthesize state = _state;

#pragma mark - Lifecycle

- (void)setup
{
	// behavior provided by subclasses
}

- (void)awakeFromNib
{
	[self setup];
	[super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self setup];
	}
	
	return self;
}

- (id)initWithDeviceNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if(nibNameOrNil != nil) {
		nibNameOrNil = StringByAppendingDeviceSuffix(nibNameOrNil);
	}
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self setup];
	}
	
	return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if(self.interfaceOrientation != toInterfaceOrientation) {
		NSNotification* notification = [NSNotification notificationWithName:InterfaceWillChangeOrientationNotification object:self];
		[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:nil];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if(self.interfaceOrientation != fromInterfaceOrientation) {
		NSNotification* notification = [NSNotification notificationWithName:InterfaceDidChangeOrientationNotification object:self];
		[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:nil];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// Empty so subclasses can call super with confidence.
}

#pragma mark - State

- (void)stateDidChangeFrom:(CViewControllerState)oldState to:(CViewControllerState)newState
{
	// behavior provided by subclasses
}

- (CViewControllerState)state
{
	return _state;
}

- (void)setState:(CViewControllerState)newState
{
	CViewControllerState oldState = _state;
	
	if(oldState != newState) {
		_state = newState;
		[self stateDidChangeFrom:oldState to:newState];
		if(self.locksInterfaceDuringActivity) {
			self.interfaceLocked = newState == CViewControllerStateActivity;
		}
	}
}

- (BOOL)interfaceLocked
{
	return _interfaceLocked;
}

- (void)interfaceLockDidChangeTo:(BOOL)locked
{
	if(self.locksInterfaceDuringActivity && self.state == CViewControllerStateActivity) {
		self.activityShieldViewVisible = YES;
	} else {
        self.activityShieldViewVisible = NO;
    }
}

- (void)setInterfaceLocked:(BOOL)locked
{
	if(_interfaceLocked != locked) {
		_interfaceLocked = locked;
		if(self.locksInterfaceDuringActivity) {
			self.activityShieldViewVisible = locked;
		}
		[self interfaceLockDidChangeTo:locked];
	}
}

- (BOOL)shouldPopViewController
{
	return YES;
}

#pragma mark - Shield view

- (BOOL)activityShieldViewVisible
{
	return self.activityShieldView != nil;
}

- (UIView*)activityShieldViewParentView
{
	UIView* parentView = self.view.window;
	//	UIView* parentView = [AppDelegate sharedAppDelegate].window;
	//	UIView* parentView = self.view;
	//	UIView* parentView = self.navigationController.view;
	
	return parentView;
}

- (void)setActivityShieldViewVisible:(BOOL)visible {
	if(self.activityShieldViewVisible != visible) {
		[self activityShieldViewParentView].userInteractionEnabled = !visible;
		if(visible) {
			UIView* parentView = [self activityShieldViewParentView];
			self.activityShieldView = [[CActivityShieldView alloc] initWithParentView:parentView] ;
            [self.activityShieldView addToParentDelayed];
		} else {
			[self.activityShieldView removeFromParent];
			self.activityShieldView = nil;
		}
	}
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
	BOOL disables = [super disablesAutomaticKeyboardDismissal];
	
	NSNumber* num = self.overrideDisablesAutomaticKeyboardDismissal;
	if(num != nil) {
		disables = [num boolValue];
	}
	
	return disables;
}

- (UIModalPresentationStyle)effectiveModalPresentationStyle {
    UIModalPresentationStyle style;
    UIViewController *controller = self;
    do {
        style = controller.modalPresentationStyle;
        controller = controller.parentViewController;
    } while(style == UIModalPresentationCurrentContext);
    return style;
}

- (void)setStatusBarStyleIfFullScreen:(UIStatusBarStyle)statusBarStyle {
    if(IsOSVersionAtLeast7()) {
        if(IsPhone() || self.effectiveModalPresentationStyle == UIModalPresentationFullScreen) {
            [UIApplication sharedApplication].statusBarStyle = statusBarStyle;
        }
    }
}

@end
