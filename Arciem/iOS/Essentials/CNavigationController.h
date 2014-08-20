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

@import UIKit;

extern NSString *const CNavigationControllerWillShowViewControllerNotification;
extern NSString *const CNavigationControllerDidShowViewControllerNotification;

@interface CNavigationController : UINavigationController

@property (nonatomic) NSNumber* overrideDisablesAutomaticKeyboardDismissal;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated willShowViewController:(dispatch_block_t)willShowViewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated didShowViewController:(dispatch_block_t)didShowViewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated willShowViewController:(dispatch_block_t)willShowViewController didShowViewController:(dispatch_block_t)didShowViewController;

@end
