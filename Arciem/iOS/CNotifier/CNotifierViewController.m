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

#import "CNotifierViewController.h"

#import "UIViewUtils.h"
#import "DeviceUtils.h"
#import "CStatusBar.h"

static const CGFloat kNotifierBarHeight = 30.0;

@interface CNotifierViewController () <CNotifierBarDelegate>

@property (nonatomic) CNotifierBar *notifierBar;
@property (nonatomic) CStatusBarProxy *statusBarProxy;

@end

@implementation CNotifierViewController

@synthesize bodyViewController = _bodyViewController;
@synthesize notifier = _notifier;
@synthesize rowCapacity = _rowCapacity;
@synthesize statusBarHeight = _statusBarHeight;

- (void)setup {
    [super setup];
    
    self.rowCapacity = 1;
}

- (void)viewDidLoad {
    self.notifierBar = [[CNotifierBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kNotifierBarHeight)];
    self.notifierBar.rowCapacity = self.rowCapacity;
    self.notifierBar.statusBarHeight = self.statusBarHeight;
    self.notifierBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    self.notifierBar.debugColor = [UIColor redColor];
    [self.view addSubview:self.notifierBar];
    self.notifierBar.delegate = self;
    self.notifierBar.notifier = self.notifier;
    
    self.statusBarProxy = [CStatusBarProxy proxy];

    [self syncToModalPresentationStyle];
}

- (void)syncToModalPresentationStyle {
    self.statusBarHeight = 20;
    if(IsPad() && self.modalPresentationStyle != UIModalPresentationFullScreen) {
        self.statusBarHeight = 0;
    }
}

- (void)setModalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle {
    [super setModalPresentationStyle:modalPresentationStyle];
    [self syncToModalPresentationStyle];
}

- (UIViewController*)bodyViewController {
    return _bodyViewController;
}

- (void)setBodyViewController:(UIViewController *)bodyViewController {
    [_bodyViewController.view removeFromSuperview];
    [_bodyViewController removeFromParentViewController];
    
    _bodyViewController = bodyViewController;
    
    if(_bodyViewController != nil) {
        [self addChildViewController:_bodyViewController];
        [self.view insertSubview:_bodyViewController.view atIndex:0];
        CFrame* frame = _bodyViewController.view.cframe;
        frame.frame = self.view.bounds;
        frame.flexibleTop = self.notifierBar.boundsBottom;
        _bodyViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (CNotifier*)notifier {
    return _notifier;
}

- (void)setNotifier:(CNotifier *)notifier {
    _notifier = notifier;
    self.notifierBar.notifier = _notifier;
}

- (NSUInteger)rowCapacity {
    return _rowCapacity;
}

- (void)setRowCapacity:(NSUInteger)rowCapacity {
    _rowCapacity = rowCapacity;
    self.notifierBar.rowCapacity = _rowCapacity;
}

- (CGFloat)statusBarHeight {
    return _statusBarHeight;
}

- (void)setStatusBarHeight:(CGFloat)statusBarHeight {
    _statusBarHeight = statusBarHeight;
    self.notifierBar.statusBarHeight = statusBarHeight;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    [[CStatusBar sharedStatusBar] addProxy:self.statusBarProxy];
	[self.notifierBar updateItemsAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[CStatusBar sharedStatusBar] removeProxy:self.statusBarProxy];
}

#pragma mark - CNotifierBarDelegate

- (void)notifierBar:(CNotifierBar *)notifierBar willChangeFrame:(CGRect)newFrame animated:(BOOL)animated {

#if 1
    UIView *view = self.bodyViewController.view;
    CGFloat top = CGRectGetMaxY(newFrame);
    CGFloat delta = top - view.top;
	CGRect frame = self.bodyViewController.view.frame;
	frame.origin.y = top;
	frame.size.height -= delta;
	view.frame = frame;
#else
    // KLUDGE: This causes a crash occasionally due to memory deallocation of cframe. Trying it manually above as a workaround.
    CFrame *bodyViewControllerFrame = self.bodyViewController.view.cframe;
    bodyViewControllerFrame.flexibleTop = CGRectGetMaxY(newFrame);
#endif
}

- (void)notifierBar:(CNotifierBar *)notifierBar wantsStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    [self.statusBarProxy setStatusBarStyle:statusBarStyle animated:animated];
}

@end