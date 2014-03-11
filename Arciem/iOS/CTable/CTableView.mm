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

#import "CTableView.h"
#import "UIViewUtils.h"


@implementation CTableView

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
//	NSLog(@"setEditing:%d animated:%d", editing, animated);
	[super setEditing:editing animated:animated];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
//	NSLog(@"touchesEnded");
	[self sendTapInBackgroundNotification];
	[super touchesEnded:touches withEvent:event];
}

- (void)reloadDataFromDeferred:(id)arg
{
//	NSLog(@"%@ reloadDataFromDeferred", self);
	[self reloadData];
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)reloadDataDeferred
{
//	NSLog(@"%@ reloadDataDeferred", self);
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[self performSelector:@selector(reloadDataFromDeferred:) withObject:nil afterDelay:0.1];
}

@end
