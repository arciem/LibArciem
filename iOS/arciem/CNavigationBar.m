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

#import "CNavigationBar.h"


@implementation CNavigationBar

@synthesize backgroundImage = backgroundImage_;

- (void)drawRect:(CGRect)rect 
{
	if (self.backgroundImage != nil) {
		CGRect r = self.bounds;
		[self.backgroundImage drawInRect:CGRectMake(0, 0, r.size.width, r.size.height)];
	} else {
		[super drawRect:rect];
	}
} 

- (void)dealloc
{
	self.backgroundImage = nil;
	[super dealloc];
}

@end
