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

#import "CSetupNavigationController.h"
#import "CSetupMainViewController.h"
#import "UIColorUtils.h"
#import "DeviceUtils.h"
#import "UIImageUtils.h"

@implementation CSetupNavigationController

- (void)customizeNavigationBar
{
//	self.navigationBar.tintColor = [UIColor grayColor];

	if([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
		UIColor* color1 = [[UIColor yellowColor] colorByDarkeningFraction:0.0];
		UIColor* color2 = [[[UIColor yellowColor] colorByDarkeningFraction:0.05] colorByColorBurnFraction:0.1];
//		UIColor* color2 = [[UIColor blueColor] colorByLighteningFraction:0.8];
		UIImage* patternImage = [UIColor diagonalRight:YES patternImageWithColor1:color1 color2:color2 size:CGSizeMake(64, 64) scale:0.0];
		UIImage* image = [UIImage navigationBarImageWithBackgroundPatternImage:patternImage];
	
		self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
												  [UIFont boldSystemFontOfSize:0.0], UITextAttributeFont,
												  [UIColor blackColor], UITextAttributeTextColor,
												  [UIColor whiteColor], UITextAttributeTextShadowColor,
												  [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
												  nil];
		[self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self customizeNavigationBar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	BOOL should = YES;
	if(IsPhone()) {
		should = toInterfaceOrientation == UIInterfaceOrientationPortrait;
	}
	return should;
}

@end
