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
#import "CObserver.h"

NSString *const CAdvanceToNextKeyViewNotification = @"CAdvanceToNextKeyViewNotification";

@interface CTextFieldItemTableViewCell ()

@property (nonatomic) NSMutableArray *textFields;
@property (nonatomic) NSMutableArray *modelObservers;
@property (nonatomic) CObserver *selectableObserver;
@property (nonatomic) CObserver *selectedObserver;
@property (readonly, nonatomic) BOOL needsCheckbox;
@property (nonatomic) UIButton *checkboxButton;

@end

@implementation CTextFieldItemTableViewCell

- (void)setup
{
	[super setup];
}

- (BOOL)needsCheckbox {
    return self.rowItem.model.selectable;
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [UIView animateWithDuration:0.4 animations:^{
        if(editing) {
            self.checkboxButton.alpha = 0.0;
        } else {
            self.checkboxButton.alpha = 1.0;
        }
    }];
}

- (void)updateConstraints {
    [super updateConstraints];
    
	NSUInteger count = self.models.count;
	
	CGFloat gap = IsPad() ? 20 : 10;
	if(count > 2) gap += 30;
    
    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CTextFieldItemTableViewCell_contentView" owner:self.contentView];

    BOOL hasCheckbox = self.checkboxButton != nil;
    BOOL checkboxVisible = hasCheckbox && !self.editing;
    
    if(hasCheckbox) {
        [group addConstraint:[self.checkboxButton constrainCenterYEqualToCenterYOfItem:self.contentView]];
        [group addConstraint:[self.checkboxButton constrainLeadingEqualToLeadingOfItem:self.contentView offset:15]];
    }
    
    __block UITextField *lastField;
    BSELF;
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
            // If there is a checkbox
            if(checkboxVisible) {
                // Constrain its left side to the checkbox's right side
                [group addConstraint:[field constrainLeadingEqualToTrailingOfItem:bself.checkboxButton offset:36]];
            } else {
                // Constrain its left side to the superview's left side
                [group addConstraint:[field constrainLeadingEqualToLeadingOfItem:bself.contentView offset:bself.contentInset.left]];
            }
        }
        
        // If this is the last field
        if(idx == count - 1) {
            // Constrain its right side to the superview's right side
            [group addConstraint:[field constrainTrailingEqualToTrailingOfItem:bself.contentView offset:-bself.contentInset.right]];
        }

        CFieldValidationView *validationView = bself.validationViews[idx];
        
        // If there's more than one field in this cell and this is the last field,
        if(count > 1 && idx == count - 1) {
            // put it's validation view on the right.
            [group addConstraint:[validationView constrainLeadingEqualToTrailingOfItem:field offset:8]];
        } else {
            // put it's validation view on the left.
            [group addConstraint:[field constrainLeadingEqualToTrailingOfItem:validationView offset:8]];
            // If this is the first validation view and there is a checkbox
            if(idx == 0 && checkboxVisible) {
                [group addConstraint:[validationView constrainLeadingEqualToTrailingOfItem:bself.checkboxButton offset:8]];
            }
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
	} else if([keyboardType isEqualToString:@"numbersAndPunctuation"]) {
		result = UIKeyboardTypeNumbersAndPunctuation;
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
			CMonthAndYearPicker* picker = [CMonthAndYearPicker new];
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
			UIDatePicker* picker = [UIDatePicker new];
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

- (void)syncToSelectable {
    if(self.needsCheckbox) {
        if(self.checkboxButton == nil) {
            self.checkboxButton = [[self class] newCheckboxButton];
            self.checkboxButton.userInteractionEnabled = NO;
            [self.contentView addSubview:self.checkboxButton];
            [self setNeedsUpdateConstraints];
        }
    } else {
        if(self.checkboxButton != nil) {
            [self.checkboxButton removeFromSuperview];
            self.checkboxButton = nil;
            [self setNeedsUpdateConstraints];
        }
    }
}

- (void)syncToSelected {
    self.checkboxButton.selected = self.rowItem.model.selected;
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	[self setNumberOfTextFieldsTo:self.models.count];

    self.selectableObserver = [CObserver newObserverWithKeyPath:@"selectable" ofObject:self.rowItem.model action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
        [self syncToSelectable];
    }];
    
    [self syncToSelectable];
    
    self.selectedObserver = [CObserver newObserverWithKeyPath:@"selected" ofObject:self.rowItem.model action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
        [self syncToSelected];
    }];
    
    [self syncToSelected];
    
    self.modelObservers = [NSMutableArray new];
    BSELF;
	[self.textFields enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger index, BOOL *stop) {
		CItem* model = (bself.models)[index];

		textField.placeholder = model.title;
        textField.returnKeyType = UIReturnKeyDefault;
        
        UIToolbar *toolbar = [UIToolbar new];
        UIBarButtonItem *spacerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonTapped:)];
        NSArray *items = @[spacerItem, nextButtonItem];
        toolbar.items = items;
        textField.inputAccessoryView = toolbar;
        [toolbar sizeToFit];
        
        if([model isKindOfClass:[CStringItem class]]) {
            CStringItem *stringItem = (CStringItem *)model;
            textField.text = stringItem.stringValue;
            CObserver *observer = [CObserver newObserverWithKeyPath:@"stringValue" ofObject:model action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
                textField.text = stringItem.stringValue;
            }];
            [bself.modelObservers addObject:observer];
        } else if([model isKindOfClass:[CDateItem class]]) {
            CDateItem *dateItem = (CDateItem *)model;
            textField.text = dateItem.formattedDateValue;
            CObserver *observer = [CObserver newObserverWithKeyPath:@"dateValue" ofObject:model action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
                textField.text = dateItem.formattedDateValue;
            }];
            [bself.modelObservers addObject:observer];
        }

		if([model isKindOfClass:[CStringItem class]]) {
			CStringItem* stringItem = (CStringItem*)model;
			textField.text = stringItem.stringValue;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.autocapitalizationType = [bself autocapitalizationTypeForModel:stringItem];
			textField.keyboardType = [bself keyboardTypeForModel:stringItem];
			textField.secureTextEntry = stringItem.secureTextEntry;
            textField.keyboardAppearance = stringItem.secureTextEntry ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
		} else {
			UIControl* control = [bself inputViewForModel:model];
			textField.inputView = control;
			textField.clearButtonMode = UITextFieldViewModeNever;
			[control addTarget:bself action:@selector(inputViewValueChanged:event:) forControlEvents:UIControlEventValueChanged];
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

- (void)advanceToNextKeyViewFromKeyView:(UIView *)keyView {
    [[NSNotificationCenter defaultCenter] postNotificationName:CAdvanceToNextKeyViewNotification object:keyView];
}

- (void)nextButtonTapped:(id)sender {
    UIView *keyView = (UIView *)[self findFirstResponder];
    [self advanceToNextKeyViewFromKeyView:keyView];
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
	model.editing = YES;

	if(textField.clearsOnBeginEditing) {
		model.value = @"";
	}
	
	[self.delegate rowItemTableViewCellDidGainFocus:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // KLUDGE: Prevents rogue animation of text in field the first time leaving it.
    [textField setNeedsLayout];
    [textField layoutIfNeeded];

	CStringItem* model = [self modelForTextField:textField];
	[model validate];
	model.editing = NO;
	self.activeItem = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self advanceToNextKeyViewFromKeyView:textField];
    return NO;
}

@end
