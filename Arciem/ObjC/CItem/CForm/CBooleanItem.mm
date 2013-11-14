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

#import "CBooleanItem.h"
#import "CMultiChoiceItem.h"
#import "CCheckboxTableRowItem.h"
#import "CSwitchTableRowItem.h"
#import "ObjectUtils.h"
#import "ErrorUtils.h"

NSString* const CBooleanItemErrorDomain = @"CBooleanItemErrorDomain";

NSString* const CBooleanItemInterfaceCheckbox = @"checkbox";
NSString* const CBooleanItemInterfaceSwitch = @"switch";

@implementation CBooleanItem

@dynamic booleanValue;

+ (CBooleanItem*)booleanItem
{
	return [self new];
}

+ (CBooleanItem*)booleanItemWithDictionary:(NSDictionary*)dict
{
	return [[self alloc] initWithDictionary:dict];
}

+ (CBooleanItem*)booleanItemWithTitle:(NSString*)title key:(NSString*)key boolValue:(BOOL)boolValue
{
	NSNumber* value = @(boolValue);
	return [[self alloc] initWithDictionary:@{@"title": title,
											 @"key": key,
											 @"value": value,
											 @"type": @"boolean"}];
}

- (BOOL)booleanValue
{
	return [(NSNumber*)self.value boolValue];
}

- (void)setBooleanValue:(BOOL)boolValue
{
	self.value = @(boolValue);
}

- (void)setValidValue:(NSNumber *)validValue {
    if(validValue == nil) {
        [self.dict removeObjectForKey:@"validValue"];
    } else {
        (self.dict)[@"validValue"] = validValue;
    }
}

- (NSNumber *)validValue {
    return (NSNumber *)(self.dict)[@"validValue"];
}

- (NSString *)interface {
    NSString *interface = (NSString *)(self.dict)[@"interface"];
    if(interface == nil) {
        interface = CBooleanItemInterfaceCheckbox;
    }
    return interface;
}

- (void)setInterface:(NSString *)interface {
    (self.dict)[@"interface"] = interface;
}

- (BOOL)didSelect
{
    [super didSelect];
	BOOL shouldDeselect = YES;

	if([self.superitem isKindOfClass:[CMultiChoiceItem class]]) {
		CMultiChoiceItem* parent = (CMultiChoiceItem*)self.superitem;
		[parent selectSubitem:self];
	} else {
		self.booleanValue = !self.booleanValue;
	}

	return shouldDeselect;
}

- (NSArray*)tableRowItems
{
	CTableRowItem* item;
    if([self.interface isEqualToString:CBooleanItemInterfaceCheckbox]) {
        item = [CCheckboxTableRowItem itemWithKey:self.key title:self.title booleanItem:self];
    } else if([self.interface isEqualToString:CBooleanItemInterfaceSwitch]) {
        item = [CSwitchTableRowItem itemWithKey:self.key title:self.title booleanItem:self];
    }
	return @[item];
}

- (NSError*)validate
{
	NSError* error = [super validate];
	
	if(error == nil) {
        NSNumber *validValue = self.validValue;
        if(validValue != nil) {
            BOOL validBoolValue = [validValue boolValue];
            if(self.booleanValue != validBoolValue) {
                NSString* message = @"%@ must be %@";
                error = [NSError errorWithDomain:CBooleanItemErrorDomain code:CBooleanItemErrorInvalidValue localizedFormat:message, self.title, [self formatBoolValueForKey:@"validValue" compact:NO]];
            }
        }
	}
	return error;
}

@end
