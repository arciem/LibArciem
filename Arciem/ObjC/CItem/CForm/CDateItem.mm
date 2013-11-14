/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CDateItem.h"
#import "ISO8601DateFormatter.h"
#import "ErrorUtils.h"
#import "DateTimeUtils.h"

NSString* const CDateItemErrorDomain = @"CDateItemErrorDomain";

static ISO8601DateFormatter* sFormatter = nil;
static NSCalendar* sCalendar = nil;

@interface CDateItem ()

@property (readonly, nonatomic) ISO8601DateFormatter* formatter;
@property (readonly, nonatomic) NSCalendar* calendar;

@end

@implementation CDateItem

- (ISO8601DateFormatter*)formatter {
	if(sFormatter == nil) {
		sFormatter = [ISO8601DateFormatter new];
	}
	
	return sFormatter;
}

- (NSCalendar*)calendar {
	if(sCalendar == nil) {
		sCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	
	return sCalendar;
}

- (NSDate*)dateForString:(NSString*)str {
    NSDate* date;
    if([str isEqualToString:@"now"]) {
        date = [NSDate date];
    } else if([str isEqualToString:@"currentMonth"]) {
        NSDateComponents* comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
        date = [self.calendar dateFromComponents:comps];
    } else if([str isEqualToString:@"currentMonthPlusOneYear"]) {
        NSDateComponents* comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
        comps.year++;
        date = [self.calendar dateFromComponents:comps];
    } else {
        date = [self.formatter dateFromString:str];
    }
    return date;
}

- (void)setup {
	[super setup];
	
	if([self.value isKindOfClass:[NSString class]]) {
		NSString* str = (NSString*)self.value;
		NSDate* date = [self dateForString:str];
		self.dateValue = date;
	}
	
	if([self.minDate isKindOfClass:[NSString class]]) {
		NSString* str = (NSString*)self.minDate;
		NSDate* date = [self dateForString:str];
		self.minDate = date;
	}

	if([self.maxDate isKindOfClass:[NSString class]]) {
		NSString* str = (NSString*)self.maxDate;
		NSDate* date = nil;

		NSDateComponents* comps = [NSDate componentsForISO8601Interval:str];
		if(comps != nil) {
			if(self.minDate != nil) {
				date = [self.calendar dateByAddingComponents:comps toDate:self.minDate options:0];
			}
		}

		if(date == nil) {
			date = [self.formatter dateFromString:str];
		}
		
		self.maxDate = date;
	}
}

- (BOOL)shouldChangeCharactersInRange:(NSRange)range inString:(NSString*)fromString toReplacementString:(NSString*)string resultString:(NSString**)resultString {
	return NO;
}

#pragma mark - @property dateValue

+ (NSSet*)keyPathsForValuesAffectingDateValue {
	return [NSSet setWithObject:@"value"];
}

- (NSDate*)dateValue {
	return self.value;
}

- (void)setDateValue:(NSDate *)dateValue {
	self.value = dateValue;
}

#pragma mark - @property minDate

+ (BOOL)automaticallyNotifiesObserversOfMinDate {
	return NO;
}

- (NSDate*)minDate {
	return (self.dict)[@"minDate"];
}

- (void)setMinDate:(NSDate *)minDate {
	(self.dict)[@"minDate"] = minDate;
}

#pragma mark - @property maxDate

+ (BOOL)automaticallyNotifiesObserversOfMaxDate {
	return NO;
}

- (NSDate*)maxDate {
	return (self.dict)[@"maxDate"];
}

- (void)setMaxDate:(NSDate *)maxDate {
	(self.dict)[@"maxDate"] = maxDate;
}

#pragma mark - Validation

- (NSError*)validate {
	NSError* error = [super validate];
	
	if(error == nil) {
		if(self.minDate != nil && [self.dateValue compare:self.minDate] == NSOrderedAscending) {
			NSString* message = @"%@ is too early.";
			error = [NSError errorWithDomain:CDateItemErrorDomain code:CDateItemErrorTooEarly localizedFormat:message, self.title];
		}
	}

	if(error == nil) {
		if(self.maxDate != nil && [self.maxDate compare:self.dateValue] == NSOrderedAscending) {
			NSString* message = @"%@ is too late.";
			error = [NSError errorWithDomain:CDateItemErrorDomain code:CDateItemErrorTooLate localizedFormat:message, self.title];
		}
	}

	return error;
}

#pragma mark - @property value

- (void)setValue:(id)value {
	if([value isKindOfClass:[NSString class]]) {
		self.value = [self.formatter dateFromString:value];
	} else {
        [super setValue:value];
    }
}

#pragma mark - @property stringValue

- (NSString*)stringValue {
	return self.dateValue.description;
}

- (void)setStringValue:(NSString *)stringValue {
    self.dateValue = [self.formatter dateFromString:self.value];
}

#pragma mark - @property fieldWidthCharacters

- (NSUInteger)fieldWidthCharacters {
	return [(self.dict)[@"fieldWidthCharacters"] unsignedIntegerValue];
}

- (void)setFieldWidthCharacters:(NSUInteger)width {
	(self.dict)[@"fieldWidthCharacters"] = @(width);
}

#pragma mark - @property datePickerMode

- (NSString*)datePickerMode {
	return (self.dict)[@"datePickerMode"];
}

- (void)setDatePickerMode:(NSString *)datePickerMode {
	(self.dict)[@"datePickerMode"] = datePickerMode;
}

#pragma mark - @property formattedDateValue

- (NSString*)formattedDateValue {
	NSString* result;
    
    static NSDateFormatter* dateFormatter;
    if(dateFormatter == nil) {
        NSString* format = [NSDateFormatter dateFormatFromTemplate:@"yMMMM" options:0 locale:[NSLocale currentLocale]];
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:format];
    }
	
	result = [dateFormatter stringFromDate:self.dateValue];

	return result;
}

#pragma mark - @property yearAndMonthFormattedDateValue

- (NSString *)yearAndMonthFormattedDateValue {
	NSString* result;

    static NSDateFormatter* dateFormatter;
    if(dateFormatter == nil) {
        NSString* format = [NSDateFormatter dateFormatFromTemplate:@"y-MM" options:0 locale:nil];
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:format];
    }
	
	result = [dateFormatter stringFromDate:self.dateValue];
    
	return result;
}
@end
