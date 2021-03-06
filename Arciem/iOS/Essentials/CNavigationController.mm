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

#import "CNavigationController.h"
#import "CViewController.h"

#if 0
@interface UINavigationController (Superclass)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;

@end
#endif

@implementation CNavigationController

@synthesize overrideDisablesAutomaticKeyboardDismissal = overrideDisablesAutomaticKeyboardDismissal_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_NAVIGATION_CONTROLLER", YES);
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if(self = [super initWithRootViewController:rootViewController]) {
		CLogTrace(@"C_NAVIGATION_CONTROLLER", @"%@ initWithRootViewController:", self, rootViewController);
	}
	
	return self;
#if 0
// http://stackoverflow.com/questions/1869331/set-programmatically-a-custom-subclass-of-uinavigationbar-in-uinavigationcontroll
	self = [[[NSBundle mainBundle] loadNibNamed:@"CNavigationController" owner:nil options:nil] objectAtIndex:0];
	self.viewControllers = [NSArray arrayWithObject:rootViewController];
	return self;
#endif
}

- (void)dealloc
{
	CLogTrace(@"C_NAVIGATION_CONTROLLER", @"%@ dealloc", self);
}
#if 0
// http://www.hanspinckaers.com/custom-action-on-back-button-uinavigationcontroller
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	UIViewController* poppedController = nil;
	
	NSArray* viewControllers = self.viewControllers;
	if(viewControllers.count > 1) {
		NSInteger topControllerIndex = viewControllers.count - 1;
		NSInteger uberControllerIndex = topControllerIndex - 1;
		UIViewController* topController = [viewControllers objectAtIndex:topControllerIndex];
		UIViewController* uberController = [viewControllers objectAtIndex:uberControllerIndex];
		if([topController isKindOfClass:[CViewController class]]) {
			CViewController* cTopController = (CViewController*)topController;
			UIViewController* backButtonViewController = cTopController.backButtonViewController;
			if(backButtonViewController != nil) {
				while(topControllerIndex > 0 && uberController != backButtonViewController) {
					[super popViewControllerAnimated:NO];
					[self.navigationBar popNavigationItemAnimated:NO];
					topControllerIndex--;
					uberControllerIndex--;
					uberController = [viewControllers objectAtIndex:uberControllerIndex];
				}
			}
		}
	}
	
	poppedController = [super popViewControllerAnimated:animated];
	
	return poppedController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	BOOL useDefault = YES;
	
	if(animated) {
		if([self.topViewController isKindOfClass:[CViewController class]]) {
			CViewController* cTopController = (CViewController*)self.topViewController;
			if(cTopController.transitionForNextPush != UIViewAnimationTransitionNone) {
				useDefault = NO;
				
				[UIView beginAnimations:nil context:NULL];
				[self pushViewController:viewController animated:NO];
				[UIView setAnimationDuration:.5];
				[UIView setAnimationBeginsFromCurrentState:YES];        
				[UIView setAnimationTransition:cTopController.transitionForNextPush forView:self.view cache:YES];
				[UIView commitAnimations];
				
				cTopController.transitionForNextPush = UIViewAnimationTransitionNone;
			}
		}
	}
	
	if(useDefault) {
		[super pushViewController:viewController animated:animated];
	}
}

#pragma mark - UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	BOOL shouldPop = YES;

	NSArray* viewControllers = self.viewControllers;
	NSInteger topControllerIndex = viewControllers.count - 1;
	UIViewController* topController = [viewControllers objectAtIndex:topControllerIndex];
	if([topController isKindOfClass:[CViewController class]]) {
		CViewController* cTopController = (CViewController*)topController;
		shouldPop = [cTopController shouldPopViewController];
	}
	
	if(shouldPop) {
		// causes navigation item and view controller to be popped.
		shouldPop = [super navigationBar:navigationBar shouldPopItem:item];
	}
	
	return shouldPop;
}
#endif

- (BOOL)disablesAutomaticKeyboardDismissal
{
	BOOL disables = [super disablesAutomaticKeyboardDismissal];
	
	NSNumber* num = self.overrideDisablesAutomaticKeyboardDismissal;
	if(num != nil) {
		disables = [num boolValue];
	}
	
	return disables;
}

@end
