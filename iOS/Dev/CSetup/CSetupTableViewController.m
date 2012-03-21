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

#import "CSetupTableViewController.h"
#import "UIColorUtils.h"
#import "DeviceUtils.h"

@implementation CSetupTableViewController

- (id)init
{
	if(self = [self initWithStyle:UITableViewStyleGrouped]) {
	};
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tableView.opaque = YES;
	self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
	UIColor *color1 = [UIColor colorWithHue:0.588 saturation:0.091 brightness:0.793 alpha:1.000];
	UIColor *color2 = [UIColor colorWithHue:0.577 saturation:0.078 brightness:0.812 alpha:1.000];
	self.tableView.backgroundView.backgroundColor = [UIColor diagonalRight:NO patternColorWithColor1:color1 color2:color2 size:CGSizeMake(64, 64) scale:0.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	BOOL should = YES;
	if(IsPhone()) {
		should = toInterfaceOrientation == UIDeviceOrientationPortrait;
	}
	return should;
}

@end
