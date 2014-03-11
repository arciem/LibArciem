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

#import "CSetup.h"
#import "CSetupMainViewController.h"
#import "CSetupNavigationController.h"

static CSetup* sSetup = nil;

@interface CSetup () <CSetupMainViewControllerDelegate>

@property (weak, nonatomic) UIWindow* window;
@property (copy, nonatomic) void(^completion)(BOOL);

- (id)initWithWindow:(UIWindow*)window completion:(void (^)(BOOL serverChanged))completion;
- (void)start;

@end

@implementation CSetup

+ (void)setupWithWindow:(UIWindow*)window completion:(void (^)(BOOL serverChanged))completion
{
	NSAssert(sSetup == nil, @"Setup already in progress.");
	
	sSetup = [[self alloc] initWithWindow:window completion:completion];
	[sSetup start];
}

- (id)initWithWindow:(UIWindow*)window completion:(void (^)(BOOL serverChanged))completion
{
	if(self = [super init]) {
		self.window = window;
		self.completion = completion;
	}
	return self;
}

- (void)start
{
	CSetupMainViewController* setupViewController = [CSetupMainViewController new];
	setupViewController.delegate = self;
	CSetupNavigationController* setupNavigationController = [[CSetupNavigationController alloc] initWithRootViewController:setupViewController];
	
	self.window.rootViewController = setupNavigationController;
	[self.window makeKeyAndVisible];
}

#pragma mark - CSetupMainViewControllerDelegate

- (void)setupMainViewController:(CSetupMainViewController*)viewController didFinishChangingServer:(BOOL)serverChanged
{
	if(self.completion != NULL) {
		self.completion(serverChanged);
		sSetup = nil;
	}
}

@end
