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

static const CGFloat kNotifierBarHeight = 30.0;

@interface CNotifierViewController () <CNotifierBarDelegate>

@property (strong, nonatomic) CNotifierBar *notifierBar;

@end

@implementation CNotifierViewController

@synthesize bodyViewController = _bodyViewController;
@synthesize notifier = _notifier;
@synthesize rowCapacity = _rowCapacity;

- (void)setup {
    [super setup];
    
    self.rowCapacity = 1;
}

- (void)viewDidLoad {
    self.notifierBar = [[CNotifierBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kNotifierBarHeight)];
    self.notifierBar.rowCapacity = self.rowCapacity;
    self.notifierBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    self.notifierBar.debugColor = [UIColor redColor];
    [self.view addSubview:self.notifierBar];
    self.notifierBar.delegate = self;
    self.notifierBar.notifier = self.notifier;
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self.notifierBar updateItemsAnimated:NO];
}

#pragma mark - CNotifierBarDelegate

- (void)notifierBar:(CNotifierBar *)notifierBar willChangeFrame:(CGRect)newFrame animated:(BOOL)animated {
    self.bodyViewController.view.cframe.flexibleTop = CGRectGetMaxY(newFrame);
}

@end
