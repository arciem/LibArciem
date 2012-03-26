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
#import "CPasswordItem.h"
#import "Geom.h"
#import "CEmailItem.h"
#import "CPhoneItem.h"

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
		field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
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
	
	CLogDebug(nil, @"%@ layoutSubviews", self);

	NSUInteger count = self.models.count;
	
	CGRect area = CGRectZero;

	UIFont* font;
	CGFloat gap;
	if(IsPad()) {
		area.size = CGSizeMake(400, 31);
		font = [UIFont boldSystemFontOfSize:20];
		gap = 20;
	} else {
		area.size = CGSizeMake(250, 31);
		font = [UIFont systemFontOfSize:14];
		gap = 10;
	}

	area = CGRectIntegral([Geom alignRectMid:area toPoint:[Geom rectMid:self.contentView.bounds]]);

	CGRect fieldRect = area;
	if(count > 2) gap += 30;
	fieldRect.size.width = area.size.width / count - (gap / 2) * (count - 1);
	fieldRect = CGRectIntegral(fieldRect);
	
	NSArray* validationViews = self.validationViews;
	NSUInteger index = 0;
	for(UITextField* textField in self.textFields) {
		CGRect r = fieldRect;
		
		CStringItem* model = [self.models objectAtIndex:index];
		NSUInteger fieldCharacterWidth = model.fieldCharacterWidth;
		if(fieldCharacterWidth > 0) {
			CGFloat xHeight = font.xHeight;
			CGFloat width = fieldCharacterWidth * xHeight * 1.2 + 40;
			if(width < r.size.width) {
				CGFloat insetAmount = floorf((r.size.width - width) / 2);
				r = CGRectInset(r, insetAmount, 0);
			}
		}
		
		textField.frame = r;
		textField.font = font;
		
		CFieldValidationView* validationView = [validationViews objectAtIndex:index];
		validationView.centerY = textField.centerY;
		if(count == 2 && index == 0) {
			validationView.right = textField.left - 8;
		} else {
			validationView.left = textField.right + 8;
		}
		validationView.frame = CGRectIntegral(validationView.frame);

		fieldRect.origin.x += fieldRect.size.width + gap;
		index++;
	}
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	[self setNumberOfTextFieldsTo:self.models.count];

	NSUInteger index = 0;
	for(UITextField* textField in self.textFields) {
		CStringItem* model = [self.models objectAtIndex:index];
		textField.placeholder = model.title;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		UIKeyboardType keyboardType = UIKeyboardTypeDefault;
		if([model isKindOfClass:[CPasswordItem class]]) {
			textField.secureTextEntry = YES;
//			textField.clearsOnBeginEditing = YES;
		} else {
			textField.secureTextEntry = NO;
//			textField.clearsOnBeginEditing = NO;
		}
		if([model isKindOfClass:[CEmailItem class]]) {
			keyboardType = UIKeyboardTypeEmailAddress;
		} else if([model isKindOfClass:[CPhoneItem class]]) {
			keyboardType = UIKeyboardTypePhonePad;
		}
		textField.keyboardType = keyboardType;
		
		textField.text = model.stringValue;
		
		index++;
	}
	
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

- (CItem*)modelForTextField:(UITextField*)textField
{
	CItem* result = nil;
	
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
	CStringItem* model = (CStringItem*)[self modelForTextField:textField];
	shouldChange = [model shouldChangeCharactersInRange:range inString:textField.text toReplacementString:string resultString:&resultString];
	if(shouldChange) {
		model.value = resultString;
	}
	
	return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	return [self textField:textField shouldChangeCharactersInRange:NSMakeRange(0, textField.text.length) replacementString:@""];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.activeItem = [self modelForTextField:textField];

	if(textField.clearsOnBeginEditing) {
		self.activeItem.value = @"";
	}
	
	[self.delegate rowItemTableViewCellDidGainFocus:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self.activeItem validate];
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
