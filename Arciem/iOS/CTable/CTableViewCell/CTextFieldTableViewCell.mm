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

#import "CTextFieldTableViewCell.h"
#import "UIViewUtils.h"

@interface CTextFieldTableViewCell ()

@property (weak, readwrite, nonatomic) IBOutlet UITextField *textField;
@property (weak, readwrite, nonatomic) IBOutlet UILabel *label;
@property(nonatomic, readwrite) BOOL isInlineEditing;

@end

@implementation CTextFieldTableViewCell

- (BOOL)isEnabled
{
    return self.label.enabled;
}

- (void)setEnabled:(BOOL)enabled
{
    self.label.enabled = enabled;
    self.textField.enabled = enabled;
}

- (void)tapInBackground:(NSNotification*)notification
{
//	NSLog(@"tapInBackground:");
	[self.textField resignFirstResponder];
}

- (void)willMoveToWindow:(UIWindow*)window
{
//	NSLog(@"willMoveToWindow:%@", window);
	if(window != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapInBackground:) name:sTapInBackgroundNotification object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:sTapInBackgroundNotification object:nil];
	}
	[super willMoveToWindow:window];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self.textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL beginEditing = YES;
    // Allow the cell delegate to override the decision to begin editing.
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellShouldBeginEditing:)])
	{
        beginEditing = [self.delegate cellShouldBeginEditing:self];
    }
    // Update internal state.
    if (beginEditing) {
		self.isInlineEditing = YES;
		//NSLog(@"isInlineEditing = YES for %p", self);
    }
	return beginEditing;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Update internal state.
    self.isInlineEditing = NO;
	//NSLog(@"isInlineEditing = NO for %p", self);

	// Notify the cell delegate that editing ended.
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidEndEditing:)])
	{
        [self.delegate cellDidEndEditing:self];
    }
}
@end
