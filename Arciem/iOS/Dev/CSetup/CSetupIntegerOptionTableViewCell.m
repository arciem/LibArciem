/*******************************************************************************
 
 Copyright 2014 Arciem LLC
 
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

#import "CSetupIntegerOptionTableViewCell.h"
#import "CIntegerItem.h"

@interface CSetupIntegerOptionTableViewCell () <UITextFieldDelegate>

@property (nonatomic) UITextField* textField;
@property (readonly, nonatomic) CIntegerItem* integerOption;

@end

@implementation CSetupIntegerOptionTableViewCell

@dynamic integerOption;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithReuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.textField.textAlignment = NSTextAlignmentRight;
        self.textField.borderStyle = UITextBorderStyleBezel;
        self.textField.clearsOnBeginEditing = YES;
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
        toolbar.items = @[flexibleSpaceItem, doneButtonItem];
        [toolbar sizeToFit];
        self.textField.inputAccessoryView = toolbar;

        [self.contentView addSubview:self.textField];
		self.textLabel.font = [UIFont boldSystemFontOfSize:12];

        self.textField.delegate = self;
    }
	
	return self;
}

- (void)doneButtonTapped {
    [self.textField endEditing:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.cframe.right = self.contentView.boundsRight - 15;
    self.textField.cframe.centerY = self.contentView.boundsCenterY;
}

- (CIntegerItem*)integerOption {
	return (CIntegerItem*)self.option;
}

- (void)syncToOption {
    self.textField.text = [NSString stringWithFormat:@"%@", self.integerOption.value];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = NO;
    
    NSString *fromString = EnsureRealString(textField.text);
	NSString *toString = [fromString stringByReplacingCharactersInRange:ClampRangeWithinString(range, fromString) withString:string];
    
    static NSRegularExpression *regex;
    if(regex == nil) {
        regex = [NSRegularExpression newRegularExpressionWithPattern:@"^-?[0-9]*$"];
    }
    NSInteger newValue = 0;
    if([toString matchesRegularExpression:regex]) {
        shouldChange = YES;
        newValue = [toString integerValue];
    
        if(shouldChange && self.integerOption.minValidValue != nil) {
            NSInteger minValidValue = self.integerOption.minValidValue.integerValue;
            if(newValue < minValidValue) {
                shouldChange = NO;
            }
        }
        if(shouldChange && self.integerOption.maxValidValue != nil) {
            NSInteger maxValidValue = self.integerOption.maxValidValue.integerValue;
            if(newValue > maxValidValue) {
                shouldChange = NO;
            }
        }
    }

    if(shouldChange) {
        self.integerOption.integerValue = newValue;
    }
    
    return shouldChange;
}

@end
