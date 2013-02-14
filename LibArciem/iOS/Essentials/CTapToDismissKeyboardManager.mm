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

#import "CTapToDismissKeyboardManager.h"
#import "UIViewUtils.h"

@interface CTapToDismissKeyboardManager ()

@property (strong, nonatomic) UITapGestureRecognizer* tapRecognizer;

@end

@implementation CTapToDismissKeyboardManager

@synthesize tapRecognizer = tapRecognizer_;

- (id)initWithView:(UIView*)view
{
	if(self = [super init]) {
		self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		self.tapRecognizer.delegate = self;
		[view addGestureRecognizer:self.tapRecognizer];
	}
	return self;
}

- (void)dealloc
{
	[self.tapRecognizer.view removeGestureRecognizer:self.tapRecognizer];
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
	UIView* view = self.tapRecognizer.view;
	CGPoint p = [self.tapRecognizer locationInView:view];
	UIView* hitView = [view hitTest:p withEvent:nil];
	if(hitView == view) {
		[view.window resignAnyFirstResponder];
	}
}

#pragma - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	BOOL should = YES;
	
	if ([touch.view isKindOfClass:[UIControl class]]) {
        should = NO;
    }
	
	return should;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return NO;
}

@end
