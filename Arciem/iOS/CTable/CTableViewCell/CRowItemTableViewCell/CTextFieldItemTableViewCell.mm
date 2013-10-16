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
#import "CDateItem.h"
#import "ObjectUtils.h"
#import "CMonthAndYearPicker.h"

@interface CTextFieldItemTableViewCell ()

@property (nonatomic) NSMutableArray* textFields;

@end

@implementation CTextFieldItemTableViewCell

@synthesize textFields = textFields_;

- (void)setup
{
	[super setup];
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
        field.translatesAutoresizingMaskIntoConstraints = NO;
		//		field.backgroundColor = [UIColor greenColor];
        [field setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		field.borderStyle = UITextBorderStyleRoundedRect;
//		field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		field.contentMode = UIViewContentModeRedraw;
        field.font = self.font;
		[self.textFields addObject:field];
		[self.contentView addSubview:field];
		field.delegate = self;
		[self setNeedsUpdateConstraints];
	}
	
	return (self.textFields)[index];
}

- (void)setTextField:(UITextField *)textField atIndex:(NSUInteger)index
{
	UITextField* oldTextField = [self textFieldAtIndex:index];
	if(oldTextField != textField) {
		oldTextField.delegate = nil;
		[oldTextField removeFromSuperview];
		(self.textFields)[index] = textField;
		[self.contentView addSubview:textField];
		textField.delegate = self;
		[self setNeedsUpdateConstraints];
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
	} else if([model isKindOfClass:[CDateItem class]]) {
		result = self.rowItem.models;
	} else if([model isKindOfClass:[CMultiTextItem class]]) {
		CMultiTextItem* multiTextItem = (CMultiTextItem*)model;
		result = multiTextItem.subitems;
	}
	
	NSAssert1(result != nil, @"Unknown model:%@", model);

	return result;
}

#if 0
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
	
	NSArray* validationViews = self.validationViews;
	[self.textFields enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
		
		textField.font = self.font;

		CFrame* textFieldFrame = textField.cframe;
		textFieldFrame.frame = fieldRect;
		
		CStringItem* model = (self.models)[idx];
		NSUInteger fieldWidthCharacters = model.fieldWidthCharacters;
		if(fieldWidthCharacters > 0) {
			CGFloat characterWidthPoints = [@"0" sizeWithFont:self.font].width;
			textFieldFrame.width = fieldWidthCharacters * characterWidthPoints + 20;
			if(textField.clearButtonMode != UITextFieldViewModeNever) {
				textFieldFrame.width += 50;
			}
		}
		
		CFieldValidationView* validationView = validationViews[idx];
		CFrame* validationViewFrame = validationView.cframe;
		validationViewFrame.centerY = textFieldFrame.centerY;
		if(count == 2 && idx == self.textFields.count - 1) {
			textFieldFrame.right = CGRectGetMaxX(self.layoutFrame);
			validationViewFrame.left = textFieldFrame.right + 8;
		} else {
			validationViewFrame.right = textFieldFrame.left - 8;
		}
		
		fieldRect.origin.x += textFieldFrame.width + gap;
	}];
}
#endif

- (void)updateConstraints {
    [super updateConstraints];
    
	NSUInteger count = self.models.count;
	
	CGFloat gap = IsPad() ? 20 : 10;
	if(count > 2) gap += 30;
    
    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CTextFieldItemTableViewCell_contentView" owner:self.contentView];

    __block UITextField *lastField;
    [self.textFields enumerateObjectsUsingBlock:^(UITextField* field, NSUInteger idx, BOOL *stop) {
        
        // If there was a previous field
        if(lastField != nil) {
            // Constrain the gap between this field and the previous field to a constant
            [group addConstraint:[field constrainLeadingEqualToTrailingOfItem:lastField offset:gap]];
            
            // Constrain the width of this field to equal the width of the previous field.
            [group addConstraint:[field constrainWidthEqualToItem:lastField]];
        }

        // If this is the first field
        if(idx == 0) {
            // Constraint its left side to the superview's left side
            [group addConstraint:[field constrainLeadingEqualToLeadingOfItem:self.contentView offset:self.contentInset.left]];
        }
        
        // If this is the last field
        if(idx == count - 1) {
            // Constrain its right side to the superview's right side
            [group addConstraint:[field constrainTrailingEqualToTrailingOfItem:self.contentView offset:-self.contentInset.right]];
        }

        CFieldValidationView *validationView = self.validationViews[idx];
        
        // If there's more than one field in this cell and this is the last field,
        if(count > 1 && idx == count - 1) {
            // put it's validation view on the right.
            [group addConstraint:[validationView constrainLeadingEqualToTrailingOfItem:field offset:8]];
        } else {
            // put it's validation view on the left.
            [group addConstraint:[field constrainLeadingEqualToTrailingOfItem:validationView offset:8]];
        }
        
        [group addConstraint:[validationView constrainCenterYEqualToCenterYOfItem:field]];
        
        lastField = field;
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

- (UIControl*)inputViewForModel:(CItem*)model
{
	UIControl* inputView = nil;
	
	if([model isKindOfClass:[CDateItem class]]) {
		CDateItem* dateItem = (CDateItem*)model;
		
		if([dateItem.datePickerMode isEqualToString:@"monthAndYear"]) {
			CMonthAndYearPicker* picker = [[CMonthAndYearPicker alloc] init];
			picker.minimumDate = dateItem.minDate;
			picker.maximumDate = dateItem.maxDate;
			picker.date = dateItem.dateValue;
			
			inputView = picker;
		} else {
			UIDatePickerMode datePickerMode = UIDatePickerModeDateAndTime;
			if([dateItem.datePickerMode isEqualToString:@"time"]) {
				datePickerMode = UIDatePickerModeTime;
			} else if([dateItem.datePickerMode isEqualToString:@"date"]) {
				datePickerMode = UIDatePickerModeDate;
			} else if([dateItem.datePickerMode isEqualToString:@"dateAndTime"]) {
				datePickerMode = UIDatePickerModeDateAndTime;
			} else if([dateItem.datePickerMode isEqualToString:@"countDownTimer"]) {
				datePickerMode = UIDatePickerModeCountDownTimer;
			} else {
				NSAssert1(NO, @"Unknown date picker mode:%@", dateItem.datePickerMode);
			}
			UIDatePicker* picker = [[UIDatePicker alloc] init];
			picker.date = dateItem.dateValue;
			picker.datePickerMode = datePickerMode;
			picker.minimumDate = dateItem.minDate;
			picker.maximumDate = dateItem.maxDate;
			
			inputView = picker;
		}
	} else {
		NSAssert1(NO, @"Cannot create input view for model:%@", model);
	}
	
	return inputView;
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	[self setNumberOfTextFieldsTo:self.models.count];

	[self.textFields enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger index, BOOL *stop) {
		CItem* model = (self.models)[index];

		textField.placeholder = model.title;
        if([model isKindOfClass:[CStringItem class]]) {
            CStringItem *stringItem = (CStringItem *)model;
            textField.text = stringItem.stringValue;
        }

		if([model isKindOfClass:[CStringItem class]]) {
			CStringItem* stringItem = (CStringItem*)model;
			textField.text = stringItem.stringValue;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.autocapitalizationType = [self autocapitalizationTypeForModel:stringItem];
			textField.keyboardType = [self keyboardTypeForModel:stringItem];
			textField.secureTextEntry = stringItem.secureTextEntry;
            textField.keyboardAppearance = stringItem.secureTextEntry ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
		} else {
			UIControl* control = [self inputViewForModel:model];
			textField.inputView = control;
			textField.clearButtonMode = UITextFieldViewModeNever;
			[control addTarget:self action:@selector(inputViewValueChanged:event:) forControlEvents:UIControlEventValueChanged];
			[control setAssociatedObject:@(index) forKey:@"index"];
		}
	}];
}

- (void)inputViewValueChanged:(id)sender event:(UIEvent*)event
{
	NSUInteger index = [[sender associatedObjectForKey:@"index"] unsignedIntValue];
	UITextField* textField = [self textFieldAtIndex:index];
	CItem* model = (self.models)[index];
	if([model isKindOfClass:[CDateItem class]]) {
		CDateItem* dateItem = (CDateItem*)model;
		if([sender isKindOfClass:[UIDatePicker class]]) {
			UIDatePicker* picker = (UIDatePicker*)sender;
			dateItem.dateValue = picker.date;
		} else if ([sender isKindOfClass:[CMonthAndYearPicker class]]) {
			CMonthAndYearPicker* picker = (CMonthAndYearPicker*)sender;
			dateItem.dateValue = picker.date;
		} else {
			NSAssert1(NO, @"Unknown sender:%@", sender);
		}
		NSString* formattedDate = dateItem.formattedDateValue;
		textField.text = formattedDate;

//		CLogDebug(nil, @"%@ inputViewValueChanged:%@ event:%@ date:%@ textField:%@", self, sender, event, dateItem.dateValue, textField);
	} else {
		NSAssert1(NO, @"Unknown model:%@", model);
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

- (CStringItem*)modelForTextField:(UITextField*)textField
{
	CStringItem* result = nil;
	
	NSUInteger index = [self indexOfTextField:textField];
	if(index != NSNotFound) {
		result = (self.models)[index];
	}
	
	return result;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    
    BOOL enabled = YES;
    if(state & UITableViewCellStateShowingEditControlMask || state & UITableViewCellStateShowingDeleteConfirmationMask) {
        enabled = NO;
    }
    
	[self.textFields enumerateObjectsUsingBlock:^(UITextField *field, NSUInteger idx, BOOL *stop) {
        field.enabled = enabled;
	}];
    
    [self setNeedsUpdateConstraints];
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
