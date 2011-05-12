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

static UIInterfaceOrientation gPortraitInterfaceOrientationOnly; // global to all instances of CViewController and subclasses

@interface CViewController ()

@property(nonatomic, retain) CActivityShieldView* activityShieldView;

@end

@implementation CViewController

@synthesize interfaceLocked = interfaceLocked_;
@synthesize state = state_;
@synthesize locksInterfaceDuringActivity = locksInterfaceDuringActivity_;
@synthesize backButtonViewController = backButtonViewController_;
@synthesize transitionForNextPush = transitionForNextPush_;
@synthesize activityShieldView = activityShieldView_;

#pragma mark -
#pragma mark Lifecycle

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

	if((self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	}
	
	return self;
}


- (void)unload
{
	// behavior provided by subclasses
}

- (void)dealloc
{
	self.backButtonViewController = nil;
	[self unload];
	[super dealloc];
}

- (void)viewDidUnload
{
	[self unload];
	[super viewDidUnload];
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

#pragma mark -
#pragma mark State

- (void)stateDidChangeFrom:(CViewControllerState)oldState to:(CViewControllerState)newState
{
	// behavior provided by subclasses
}

#pragma mark -
#pragma mark State

- (CViewControllerState)state
{
	return state_;
}

- (void)setState:(CViewControllerState)newState
{
	CViewControllerState oldState = state_;
	
	if(oldState != newState) {
		state_ = newState;
		[self stateDidChangeFrom:oldState to:newState];
		if(self.locksInterfaceDuringActivity) {
			self.interfaceLocked = newState == CViewControllerStateActivity;
		}
	}
}

- (BOOL)interfaceLocked
{
	return interfaceLocked_;
}

- (void)interfaceLockDidChangeTo:(BOOL)locked
{
	// behavior provided by subclasses
}

- (void)setInterfaceLocked:(BOOL)locked
{
	if(interfaceLocked_ != locked) {
		interfaceLocked_ = locked;
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

#pragma mark -
#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (gPortraitInterfaceOrientationOnly || IsPhone()) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	} else {
		return YES;
	}
}

#pragma mark -
#pragma mark CImageViewLayoutDelegate

- (void)viewLayoutSubviews:(UIView*)view
{
}

#pragma mark -
#pragma mark Shield view

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

- (void)addActivityShieldView
{
	if(self.activityShieldView != nil) {
		UIView* parentView = [self activityShieldViewParentView];
		[parentView addSubview:self.activityShieldView animated:YES];
	}
}

- (void)addActivityShieldViewDelayed
{
	[self performSelector:@selector(addActivityShieldView) withObject:nil afterDelay:0.5];
}

- (void)setActivityShieldViewVisible:(BOOL)visible
{
	if(self.activityShieldViewVisible != visible) {
		[self activityShieldViewParentView].userInteractionEnabled = !visible;
		if(visible) {
			UIView* parentView = [self activityShieldViewParentView];
			self.activityShieldView = [[[CActivityShieldView alloc] initWithFrame:parentView.bounds] autorelease];
			//			[self addActivityShieldView];
			[self addActivityShieldViewDelayed];
			
		} else {
			[self.activityShieldView removeFromSuperviewAnimated:YES];
			self.activityShieldView = nil;
		}
	}
}

@end
