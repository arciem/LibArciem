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

#import "CTextFieldItemTableViewCell.h"
#import "DeviceUtils.h"
#import "UIViewUtils.h"
#import "CStringItem.h"
#import "CMultiTextItem.h"
#import "StringUtils.h"
#import "TextUtils.h"

@interface CTextFieldItemTableViewCell ()

@property (strong, nonatomic) NSMutableArray* textFields;

@end

@implementation CTextFieldItemTableViewCell

@synthesize textFields = textFields_;

- (void)setup
{
	[super setup];
	self.textLabel.hidden = YES;
}

- (UITextField*)textField
{
	return [self textFieldAtIndex:0];
}

- (UITextField*)textFieldAtIndex:(NSUInteger)index
{
	if(self.textFields == nil) {
		self.textFields = [NSMutableArray array];
	}

	while(self.textFields.count <= index) {
		UITextField* field = [[UITextField alloc] initWithFrame:CGRectZero];
		//		field.backgroundColor = [UIColor greenColor];
		field.borderStyle = UITextBorderStyleRoundedRect;
//		field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		field.contentMode = UIViewContentModeRedraw;
		[self.textFields addObject:field];
		[self.contentView addSubview:field];
		field.delegate = self;
	}
	
	return [self.textFields objectAtIndex:index];
}

- (void)setTextField:(UITextField *)textField atIndex:(NSUInteger)index
{
	UITextField* oldTextField = [self textFieldAtIndex:index];
	if(oldTextField != textField) {
		oldTextField.delegate = nil;
		[oldTextField removeFromSuperview];
		[self.textFields replaceObjectAtIndex:index withObject:textField];
		[self.contentView addSubview:textField];
		textField.delegate = self;
		[self setNeedsLayout];
	}
}

- (void)setNumberOfTextFieldsTo:(NSUInteger)count
{
	while(self.textFields.count > count) {
		UITextField* textField = self.textFields.lastObject;
		textField.delegate = nil;
		[textField removeFromSuperview];
		[self.textFields removeLastObject];
	}
	if(count > 0) {
		[self textFieldAtIndex:count - 1];
	}
}

- (NSArray*)models
{
	NSArray* result = nil;
	
	CItem* model = self.rowItem.model;
	if([model isKindOfClass:[CStringItem class]]) {
		result = self.rowItem.models;
	} else if([model isKindOfClass:[CMultiTextItem class]]) {
		CMultiTextItem* multiTextItem = (CMultiTextItem*)model;
		result = multiTextItem.subitems;
	}
	
	NSAssert1(result != nil, @"Unknown model:%@", model);

	return result;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
//	CLogDebug(nil, @"%@ layoutSubviews", self);

	NSUInteger count = self.models.count;
	
	CGFloat gap = IsPad() ? 20 : 10;

	CGRect layoutFrame = self.layoutFrame;
	
	__block CGRect fieldRect = layoutFrame;
	if(count > 2) gap += 30;
	fieldRect.size.width = layoutFrame.size.width / count - (gap / 2) * (count - 1);
	fieldRect = CGRectIntegral(fieldRect);
	
	NSArray* validationViews = self.validationViews;
	[self.textFields enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
		CGRect r = fieldRect;
		
		CStringItem* model = [self.models objectAtIndex:idx];
		NSUInteger fieldCharacterWidth = model.fieldCharacterWidth;
		if(fieldCharacterWidth > 0) {
			CGFloat xHeight = self.font.xHeight;
			CGFloat width = fieldCharacterWidth * xHeight * 1.2 + 40;
			if(width < r.size.width) {
				CGFloat insetAmount = floorf((r.size.width - width) / 2);
				r = CGRectInset(r, insetAmount, 0);
			}
		}
		
		textField.cframe.frame = r;
		textField.font = self.font;
		
		CFieldValidationView* validationView = [validationViews objectAtIndex:idx];
		CFrame* validationViewFrame = validationView.cframe;
		validationViewFrame.centerY = textField.centerY;
		if(count == 2 && idx == self.textFields.count - 1) {
			validationViewFrame.left = textField.right + 8;
		} else {
			validationViewFrame.right = textField.left - 8;
		}
		
		fieldRect.origin.x += fieldRect.size.width + gap;
	}];
}

- (UIKeyboardType)keyboardTypeForModel:(CStringItem*)model
{
	UIKeyboardType result = UIKeyboardTypeDefault;
	
	NSString* keyboardType = model.keyboardType;
	if([keyboardType isEqualToString:@"emailAddress"]) {
		result = UIKeyboardTypeEmailAddress;
	} else if([keyboardType isEqualToString:@"phonePad"]) {
		result = UIKeyboardTypePhonePad;
	} else if([keyboardType isEqualToString:@"numberPad"]) {
		result = UIKeyboardTypeNumberPad;
	} else if([keyboardType isEqualToString:@"asciiCapable"]) {
		result = UIKeyboardTypeASCIICapable;
	} else if(IsEmptyString(keyboardType) || [keyboardType isEqualToString:@"default"]) {
		// no action
	} else {
		NSAssert1(false, @"Unknown keyboardType:%@", keyboardType);
	}
	
	return result;
}

- (UITextAutocapitalizationType)autocapitalizationTypeForModel:(CStringItem*)model
{
	UITextAutocapitalizationType result = UITextAutocapitalizationTypeSentences;

	NSString* autocapitalizationType = model.autocapitalizationType;
	if([autocapitalizationType isEqualToString:@"none"]) {
		result = UITextAutocapitalizationTypeNone;
	} else if([autocapitalizationType isEqualToString:@"words"]) {
		result = UITextAutocapitalizationTypeWords;
	} else if([autocapitalizationType isEqualToString:@"all"]) {
		result = UITextAutocapitalizationTypeAllCharacters;
	} else if(IsEmptyString(autocapitalizationType) || [autocapitalizationType isEqualToString:@"sentences"]) {
		// no action
	} else {
		NSAssert1(false, @"Unknown autocapitalizationType:%@", autocapitalizationType);
	}
	
	return result;
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	[self setNumberOfTextFieldsTo:self.models.count];

	[self.textFields enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger index, BOOL *stop) {
		CStringItem* model = [self.models objectAtIndex:index];

		textField.placeholder = model.title;
		textField.text = model.stringValue;

		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.autocapitalizationType = [self autocapitalizationTypeForModel:model];
		textField.keyboardType = [self keyboardTypeForModel:model];
		textField.secureTextEntry = model.secureTextEntry;
	}];
}

- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue
{
	[super model:model valueDidChangeFrom:oldValue to:newValue];
}

- (NSUInteger)indexOfTextField:(UITextField*)textField
{
	__block NSUInteger result = NSNotFound;
	
	[self.textFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if(obj == textField) {
			result = idx;
			*stop = YES;
		}
	}];
	
	return result;
}

- (CStringItem*)modelForTextField:(UITextField*)textField
{
	CStringItem* result = nil;
	
	NSUInteger index = [self indexOfTextField:textField];
	if(index != NSNotFound) {
		result = [self.models objectAtIndex:index];
	}
	
	return result;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL shouldChange = NO;
	
	NSString* resultString = nil;
	CStringItem* model = [self modelForTextField:textField];
	shouldChange = [model shouldChangeCharactersInRange:range inString:textField.text toReplacementString:string resultString:&resultString];
	if(shouldChange) {
		model.value = resultString;
		textField.text = resultString;
		[textField setInsertionPointToOffset:range.location + string.length];
		shouldChange = NO;
	}
	
	return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	return [self textField:textField shouldChangeCharactersInRange:NSMakeRange(0, textField.text.length) replacementString:@""];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	CStringItem* model = [self modelForTextField:textField];
	self.activeItem = model;
	model.isEditing = YES;

	if(textField.clearsOnBeginEditing) {
		model.value = @"";
	}
	
	[self.delegate rowItemTableViewCellDidGainFocus:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	CStringItem* model = [self modelForTextField:textField];
	[model validate];
	model.isEditing = NO;
	self.activeItem = nil;
}

#if 0
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField == self.emailTextField) {
		[self.passwordTextField becomeFirstResponder];
	} else if(textField == self.passwordTextField) {
		if(self.emailItem.isValid && self.passwordItem.isValid) {
			[self login];
		} else {
			[self.emailTextField becomeFirstResponder];
		}
	}
	return NO;
}
#endif

@end
