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

#import "CIntegerItem.h"

//#import "CMultiChoiceItem.h"
//#import "CCheckboxTableRowItem.h"
//#import "CSwitchTableRowItem.h"
//#import "ObjectUtils.h"
//#import "ErrorUtils.h"
//#import "StringUtils.h"

NSString* const CIntegerItemErrorDomain = @"CIntegerItemErrorDomain";

//NSString* const CIntegerItemInterfaceCheckbox = @"checkbox";
//NSString* const CIntegerItemInterfaceSwitch = @"switch";

@implementation CIntegerItem

@dynamic integerValue;

+ (CIntegerItem*)newIntegerItem {
	return [self new];
}

+ (CIntegerItem*)newIntegerItemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

+ (CIntegerItem*)newIntegerItemWithTitle:(NSString*)title key:(NSString*)key integerValue:(NSInteger)integerValue {
	NSNumber* value = @(integerValue);
	return [[self alloc] initWithDictionary:@{@"title": EnsureRealString(title),
                                              @"key": EnsureRealString(key),
                                              @"value": Denull(value) == nil ? @(0) : value,
                                              @"type": @"integer"}];
}

- (NSInteger)integerValue {
	return [(NSNumber*)self.value integerValue];
}

- (void)setIntegerValue:(NSInteger)integerValue {
	self.value = @(integerValue);
}

- (void)setMinValidValue:(NSNumber *)minValidValue {
    if(minValidValue == nil) {
        [self.dict removeObjectForKey:@"minValidValue"];
    } else {
        (self.dict)[@"minValidValue"] = minValidValue;
    }
}

- (NSNumber *)minValidValue {
    return (NSNumber *)(self.dict)[@"minValidValue"];
}

- (void)setMaxValidValue:(NSNumber *)maxValidValue {
    if(maxValidValue == nil) {
        [self.dict removeObjectForKey:@"maxValidValue"];
    } else {
        (self.dict)[@"maxValidValue"] = maxValidValue;
    }
}

- (NSNumber *)maxValidValue {
    return (NSNumber *)(self.dict)[@"maxValidValue"];
}

- (NSError*)validateValue
{
	NSError* error = [super validateValue];
	
	if(error == nil) {
        NSNumber *minValidValue = self.minValidValue;
        if(minValidValue != nil) {
            NSInteger validMin = [minValidValue integerValue];
            if(self.integerValue < validMin) {
                NSString* message = @"%@ must be greater than %@";
                error = [NSError errorWithDomain:CIntegerItemErrorDomain code:CIntegerItemErrorInvalidValue localizedFormat:message, self.title, [self formatNumberForKey:@"minValidValue" hidingIfZero:NO]];
            }
        }
	}

    if(error == nil) {
        NSNumber *maxValidValue = self.maxValidValue;
        if(maxValidValue != nil) {
            NSInteger validMax = [maxValidValue integerValue];
            if(self.integerValue > validMax) {
                NSString* message = @"%@ must be less than %@";
                error = [NSError errorWithDomain:CIntegerItemErrorDomain code:CIntegerItemErrorInvalidValue localizedFormat:message, self.title, [self formatNumberForKey:@"maxValidValue" hidingIfZero:NO]];
            }
        }
	}
    
    return error;
}

@end
