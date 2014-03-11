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

#import <UIKit/UIKit.h>

@protocol CTextFieldTableViewCell2Delegate;

@interface CTextFieldTableViewCell2 : UITableViewCell <UITextFieldDelegate>

//- (id)initWithLabelText:(NSString*)labelText;

@property (nonatomic, weak) id <CTextFieldTableViewCell2Delegate> delegate;

@property (weak, readonly, nonatomic) IBOutlet UITextField *textField;
@property (weak, readonly, nonatomic) IBOutlet UILabel *label;

@property(nonatomic, readonly) BOOL isInlineEditing;
@property(nonatomic, getter = isEnabled) BOOL enabled;

@end

// Protocol to be adopted by an object wishing to customize cell behavior with respect to editing.
@protocol CTextFieldTableViewCell2Delegate <NSObject>

@optional

// Invoked before editing begins. The delegate may return NO to prevent editing.
- (BOOL)cellShouldBeginEditing:(CTextFieldTableViewCell2 *)cell;
// Invoked after editing ends.
- (void)cellDidEndEditing:(CTextFieldTableViewCell2 *)cell;

@end
