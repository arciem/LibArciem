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

#import "CSidebarContainerViewController.h"

#import "UIViewUtils.h"
#import "DeviceUtils.h"
#import "Geom.h"
#import "CShadowView.h"
#import "DeviceUtils.h"

NSString *const SidebarContainerViewControllerWillShrinkCenterViewController = @"SidebarContainerViewControllerWillShrinkCenterViewController";
NSString *const SidebarContainerViewControllerWillObscureCenterViewController = @"SidebarContainerViewControllerWillObscureCenterViewController";
NSString *const SidebarContainerViewControllerWillRevealCenterViewController = @"SidebarContainerViewControllerWillRevealCenterViewController";

NSString *const SidebarContainerViewControllerWillSwipeOpenLeftViewController = @"SidebarContainerViewControllerWillSwipeOpenLeftViewController";
NSString *const SidebarContainerViewControllerWillSwipeClosedLeftViewController = @"SidebarContainerViewControllerWillSwipeClosedLeftViewController";
NSString *const SidebarContainerViewControllerWillSwipeOpenRightViewController = @"SidebarContainerViewControllerWillSwipeOpenRightViewController";
NSString *const SidebarContainerViewControllerWillSwipeClosedRightViewController = @"SidebarContainerViewControllerWillSwipeClosedRightViewController";

static const NSUInteger kRevealAnimationOptions = UIViewAnimationOptionLayoutSubviews;
static const CGFloat kSwipeSensitiveWidthFraction = 0.05;
static const CGFloat kSwipeSensitiveMinWidth = 40.0;
static const CGFloat kShadowWidth = 15.0;

@interface CSidebarContainerViewController ()

@property (nonatomic) CGFloat sidebarWidth;
@property (nonatomic) CGFloat swipeSensitiveWidth;
@property (nonatomic) CGFloat centerOpenWidth;
@property (readonly, nonatomic) CView* shieldView;
@property (nonatomic) CShadowView* leftShadowView;
@property (nonatomic) CShadowView* rightShadowView;

@end

@implementation CSidebarContainerViewController

@synthesize centerViewController = _centerViewController;
@synthesize leftViewController = _leftViewController;
@synthesize rightViewController = _rightViewController;
@synthesize leftViewVisible = _leftViewVisible;
@synthesize rightViewVisible = _rightViewVisible;
@synthesize centerSwipeRightRecognizer = _centerSwipeRightRecognizer;
@synthesize centerSwipeLeftRecognizer = _centerSwipeLeftRecognizer;
@synthesize rightSwipeRightRecognizer = _rightSwipeRightRecognizer;
@synthesize leftSwipeLeftRecognizer = _leftSwipeLeftRecognizer;
@synthesize shieldView = _shieldView;

- (void)setup
{
	[super setup];
    
	self.minCenterViewControllerWidth = 320;
    if(IsOSVersionAtLeast7()) {
        self.centerOpenWidth = 62;
    } else {
        self.centerOpenWidth = 52;
    }
	self.sidebarWidth = self.minCenterViewControllerWidth - self.centerOpenWidth;
}

- (UISwipeGestureRecognizer *)centerSwipeRightRecognizer {
    if(_centerSwipeRightRecognizer == nil) {
        _centerSwipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(centerSwipeRightGesture:)];
        _centerSwipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        _centerSwipeRightRecognizer.delaysTouchesBegan = YES;
        _centerSwipeRightRecognizer.delegate = self;
    };
    return _centerSwipeRightRecognizer;
}

- (UISwipeGestureRecognizer *)centerSwipeLeftRecognizer {
    if(_centerSwipeLeftRecognizer == nil) {
        _centerSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(centerSwipeLeftGesture:)];
        _centerSwipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        _centerSwipeLeftRecognizer.delaysTouchesBegan = YES;
        _centerSwipeLeftRecognizer.delegate = self;
    };
    return _centerSwipeLeftRecognizer;
}

- (UISwipeGestureRecognizer *)rightSwipeRightRecognizer {
    if(_rightSwipeRightRecognizer == nil) {
        _rightSwipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeRightGesture:)];
        _rightSwipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    };
    return _rightSwipeRightRecognizer;
}

- (UISwipeGestureRecognizer *)leftSwipeLeftRecognizer {
    if(_leftSwipeLeftRecognizer == nil) {
        _leftSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeLeftGesture:)];
        _leftSwipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    };
    return _leftSwipeLeftRecognizer;
}

- (CView *)shieldView {
    if(_shieldView == nil) {
        _shieldView = [CView new];
        _shieldView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        _shieldView.opaque = NO;
        _shieldView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _shieldView.alpha = 0.0;
        [self.view addSubview:_shieldView];
    };
    return _shieldView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blueColor];
    
    self.leftShadowView = [CShadowView new];
    self.leftShadowView.edge = CShadowViewEdgeLeft;
    [self.view addSubview:self.leftShadowView];
    
    self.rightShadowView = [CShadowView new];
    self.rightShadowView.edge = CShadowViewEdgeRight;
    [self.view addSubview:self.rightShadowView];
}

- (UIViewController*)centerViewController
{
	return _centerViewController;
}

- (void)updateAncillaryViewsWithCenterViewFrame:(CGRect)frame {
    self.shieldView.frame = UIEdgeInsetsInsetRect(frame, self.shieldViewInsets);
	self.leftShadowView.frame = CGRectMake(CGRectGetMinX(frame) - kShadowWidth, CGRectGetMinY(frame), kShadowWidth, CGRectGetHeight(frame));
	self.rightShadowView.frame = CGRectMake(CGRectGetMaxX(frame), CGRectGetMinY(frame), kShadowWidth, CGRectGetHeight(frame));
}

- (void)setCenterViewController:(UIViewController *)centerViewController
{
    [_centerViewController willMoveToParentViewController:nil];

	if(IsPad()) {
		[_centerViewController.view removeGestureRecognizer:self.centerSwipeRightRecognizer];
		[_centerViewController.view removeGestureRecognizer:self.centerSwipeLeftRecognizer];
	}
	
	[_centerViewController.view removeFromSuperview];
	[_centerViewController removeFromParentViewController];
    
	_centerViewController = centerViewController;
	
	if(_centerViewController != nil) {
		[self addChildViewController:_centerViewController];
		_centerViewController.view.frame = self.view.bounds;
		if(IsPad()) {
			[_centerViewController.view addGestureRecognizer:self.centerSwipeRightRecognizer];
			[_centerViewController.view addGestureRecognizer:self.centerSwipeLeftRecognizer];
		}
		[self.view addSubview:_centerViewController.view];
        [_centerViewController didMoveToParentViewController:self];
        
        [self updateAncillaryViewsWithCenterViewFrame:_centerViewController.view.frame];
        [self.shieldView bringToFront];
	}
}

- (UIViewController*)leftViewController
{
	return _leftViewController;
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    [_leftViewController willMoveToParentViewController:nil];

	[_leftViewController.view removeGestureRecognizer:self.leftSwipeLeftRecognizer];
	[_leftViewController.view removeFromSuperview];
	[_leftViewController removeFromParentViewController];
	
	_leftViewController = leftViewController;
	
	if(_leftViewController != nil) {
		[self addChildViewController:_leftViewController];
		[self.view insertSubview:_leftViewController.view atIndex:0];
		_leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
		CFrame* frame = [CFrame frameWithView:_leftViewController.view];
		frame.width = self.sidebarWidth;
		frame.left = self.view.boundsLeft;
		frame.top = self.view.boundsTop;
		frame.height = self.view.boundsHeight;
		[_leftViewController.view addGestureRecognizer:self.leftSwipeLeftRecognizer];
        [_leftViewController didMoveToParentViewController:self];
	}
}

- (UIViewController*)rightViewController
{
	return _rightViewController;
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    [_rightViewController willMoveToParentViewController:nil];

	[_rightViewController.view removeGestureRecognizer:self.rightSwipeRightRecognizer];
	[_rightViewController.view removeFromSuperview];
	[_rightViewController removeFromParentViewController];
	
	_rightViewController = rightViewController;
	
	if(_rightViewController != nil) {
		[self addChildViewController:_rightViewController];
		[self.view insertSubview:_rightViewController.view atIndex:0];
		_rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
		CFrame* frame = [CFrame frameWithView:_rightViewController.view];
		frame.width = self.sidebarWidth;
		frame.right = self.view.boundsRight;
		frame.top = self.view.boundsTop;
		frame.height = self.view.boundsHeight;
		[_rightViewController.view addGestureRecognizer:self.rightSwipeRightRecognizer];
        [_rightViewController didMoveToParentViewController:self];
	}
}

- (BOOL)leftViewVisible
{
	return _leftViewVisible;
}

+ (BOOL)automaticallyNotifiesObserversOfLeftViewVisible
{
	return NO;
}

- (void)updateShieldViewForSidebarVisibility:(BOOL)sidebarVisible {
    if(IsPhone()) {
        if(sidebarVisible) {
            self.shieldView.alpha = 1.0;
            [self.shieldView addGestureRecognizer:self.centerSwipeRightRecognizer];
            [self.shieldView addGestureRecognizer:self.centerSwipeLeftRecognizer];
        } else {
            self.shieldView.alpha = 0.0;
            [self.shieldView removeGestureRecognizer:self.centerSwipeRightRecognizer];
            [self.shieldView removeGestureRecognizer:self.centerSwipeLeftRecognizer];
        }
    }
}

- (void)setLeftViewVisible:(BOOL)leftViewVisible
{
	if(_leftViewVisible != leftViewVisible) {
		[self willChangeValueForKey:@"leftViewVisible"];
		_leftViewVisible = leftViewVisible;
		CGRect frame = self.centerViewController.view.frame;
		if(leftViewVisible) {
			if(self.rightViewVisible) {
				[self willChangeValueForKey:@"rightViewVisible"];
				frame = [Geom setRectMaxX:frame to:self.view.boundsRight];
				_rightViewVisible = NO;
				[self didChangeValueForKey:@"rightViewVisible"];
			}
			self.rightViewVisible = NO;
			frame = [Geom setRectMinX:frame to:self.leftViewController.view.right];
			if(frame.size.width < self.minCenterViewControllerWidth) {
				[[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillObscureCenterViewController object:self];
				frame = [Geom insetRectMaxX:frame by:-(self.minCenterViewControllerWidth - frame.size.width)];
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillShrinkCenterViewController object:self];
			}
			[self.view sendSubview:self.rightViewController.view belowSubview:self.leftViewController.view];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillRevealCenterViewController object:self];
			frame = [Geom setRectMinX:frame to:self.view.boundsLeft];
			frame = [Geom setRectMaxX:frame to:self.view.boundsRight];
		}
		self.centerViewController.view.frame = frame;
        [self updateAncillaryViewsWithCenterViewFrame:frame];
        [self updateShieldViewForSidebarVisibility:_leftViewVisible];
		[self didChangeValueForKey:@"leftViewVisible"];
	}
}

- (BOOL)rightViewVisible
{
	return _rightViewVisible;
}

+ (BOOL)automaticallyNotifiesObserversOfRightViewVisible
{
	return NO;
}

- (void)setRightViewVisible:(BOOL)rightViewVisible
{
	if(_rightViewVisible != rightViewVisible) {
		[self willChangeValueForKey:@"rightViewVisible"];
		_rightViewVisible = rightViewVisible;
		CGRect frame = self.centerViewController.view.frame;
		if(rightViewVisible) {
			if(self.leftViewVisible) {
				[self willChangeValueForKey:@"leftViewVisible"];
				frame = [Geom setRectMinX:frame to:self.view.boundsLeft];
				_leftViewVisible = NO;
				[self didChangeValueForKey:@"leftViewVisible"];
			}
			frame = [Geom setRectMaxX:frame to:self.rightViewController.view.left];
			if(frame.size.width < self.minCenterViewControllerWidth) {
				[[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillObscureCenterViewController object:self];
				frame = [Geom insetRectMinX:frame by:-(self.minCenterViewControllerWidth - frame.size.width)];
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillShrinkCenterViewController object:self];
			}
			[self.view sendSubview:self.leftViewController.view belowSubview:self.rightViewController.view];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillRevealCenterViewController object:self];
			frame = [Geom setRectMinX:frame to:self.view.boundsLeft];
			frame = [Geom setRectMaxX:frame to:self.view.boundsRight];
		}
		self.centerViewController.view.frame = frame;
        [self updateAncillaryViewsWithCenterViewFrame:frame];
        [self updateShieldViewForSidebarVisibility:_rightViewVisible];
		[self didChangeValueForKey:@"rightViewVisible"];
	}
}

- (void)setLeftViewVisible:(BOOL)leftViewVisible animated:(BOOL)animated
{
	if(self.leftViewVisible != leftViewVisible) {
        [self updateAncillaryViewsWithCenterViewFrame:self.centerViewController.view.frame];
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[UIView animateWithDuration:(animated ? 0.3 : 0.0) delay:0.0 options:kRevealAnimationOptions animations:^{
			self.leftViewVisible = leftViewVisible;
		} completion:^(BOOL finished) {
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}];
	}
}

- (void)setRightViewVisible:(BOOL)rightViewVisible animated:(BOOL)animated
{
	if(self.rightViewVisible != rightViewVisible) {
        [self updateAncillaryViewsWithCenterViewFrame:self.centerViewController.view.frame];
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[UIView animateWithDuration:(animated ? 0.3 : 0.0) delay:0.0 options:kRevealAnimationOptions animations:^{
			self.rightViewVisible = rightViewVisible;
		} completion:^(BOOL finished) {
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}];
	}
}

- (void)toggleLeftViewVisibleAnimated:(BOOL)animated
{
	[self setLeftViewVisible:!self.leftViewVisible animated:animated];
}

- (void)toggleRightViewVisibleAnimated:(BOOL)animated
{
	[self setRightViewVisible:!self.rightViewVisible animated:animated];
}

- (CGFloat)swipeSensitiveWidth
{
    if(IsPhone()) {
        return self.centerViewController.view.boundsWidth / 2;
    } else {
        return fmaxf(self.centerViewController.view.boundsWidth * kSwipeSensitiveWidthFraction, kSwipeSensitiveMinWidth);
    }
}

- (void)centerSwipeRightGesture:(UISwipeGestureRecognizer*)recognizer
{
	CGPoint loc = [recognizer locationInView:self.centerViewController.view];
	if(loc.x < self.centerViewController.view.boundsLeft + self.swipeSensitiveWidth) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillSwipeOpenLeftViewController object:self];
		[self setLeftViewVisible:YES animated:YES];
	} else if (loc.x > self.centerViewController.view.boundsRight - self.swipeSensitiveWidth) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillSwipeClosedRightViewController object:self];
		[self setRightViewVisible:NO animated:YES];
	}
}

- (void)centerSwipeLeftGesture:(UISwipeGestureRecognizer*)recognizer
{
	CGPoint loc = [recognizer locationInView:self.centerViewController.view];
	if(loc.x < self.centerViewController.view.boundsLeft + self.swipeSensitiveWidth) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillSwipeClosedLeftViewController object:self];
		[self setLeftViewVisible:NO animated:YES];
	} else if (loc.x > self.centerViewController.view.boundsRight - self.swipeSensitiveWidth) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillSwipeOpenRightViewController object:self];
		[self setRightViewVisible:YES animated:YES];
	}
}

- (void)rightSwipeRightGesture:(UISwipeGestureRecognizer*)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillSwipeClosedRightViewController object:self];
	[self setRightViewVisible:NO animated:YES];
}

- (void)leftSwipeLeftGesture:(UISwipeGestureRecognizer*)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SidebarContainerViewControllerWillSwipeClosedLeftViewController object:self];
	[self setLeftViewVisible:NO animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

@end
