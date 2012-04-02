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

NSString* const CDateItemErrorDomain = @"CDateItemErrorDomain";

static ISO8601DateFormatter* sFormatter = nil;
static NSCalendar* sCalendar = nil;

@interface CDateItem ()

@property (readonly, nonatomic) ISO8601DateFormatter* formatter;
@property (readonly, nonatomic) NSCalendar* calendar;

@end

@implementation CDateItem

- (ISO8601DateFormatter*)formatter
{
	if(sFormatter == nil) {
		sFormatter = [[ISO8601DateFormatter alloc] init];
	}
	
	return sFormatter;
}

- (NSCalendar*)calendar
{
	if(sCalendar == nil) {
		sCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	
	return sCalendar;
}

- (NSDateComponents*)componentsForISO8601Interval:(NSString*)str
{
	NSDateComponents* comps = nil;
	
	// ^P(?=\w*\d)(?:(\d+)Y|Y)?(?:(\d+)M|M)?(?:(\d+)D|D)?(?:T(?:(\d+)H|H)?(?:(\d+)M|M)?(?:((?:\d+)(?:\.\d{1,2})?)?S|S)?)?$
	// P1Y2M3DT4H5M6.7S
	
	NSError* error = nil;
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^P(?=\\w*\\d)(?:(\\d+)Y|Y)?(?:(\\d+)M|M)?(?:(\\d+)D|D)?(?:T(?:(\\d+)H|H)?(?:(\\d+)M|M)?(?:((?:\\d+)(?:\\.\\d{1,2})?)?S|S)?)?$" options:0 error:&error];
	NSAssert1(error == nil, @"Error:%@", error);
	NSTextCheckingResult* match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
	
	if(match != nil) {
		comps = [[NSDateComponents alloc] init];
		for(NSUInteger rangeIndex = 1; rangeIndex < match.numberOfRanges; rangeIndex++) {
			NSRange range = [match rangeAtIndex:rangeIndex];
			if(range.location != NSNotFound) {
				NSString* captureString = [str substringWithRange:range];
				
				switch (rangeIndex) {
					case 1: {
						NSInteger year = [captureString integerValue];
						comps.year = year;
					} break;
					case 2: {
						NSInteger month = [captureString integerValue];
						comps.month = month;
					} break;
					case 3: {
						NSInteger day = [captureString integerValue];
						comps.day = day;
					} break;
					case 4: {
						NSInteger hour = [captureString integerValue];
						comps.hour = hour;
					} break;
					case 5: {
						NSInteger minute = [captureString integerValue];
						comps.minute = minute;
					} break;
					case 6: {
						NSInteger second = (NSInteger)roundf([captureString floatValue]);
						comps.second = second;
					} break;
					default:
						break;
				}
			}
		}
	}
	
	return comps;
}

- (void)setup
{
	[super setup];
	
	if([self.value isKindOfClass:[NSString class]]) {
		self.dateValue = [self.formatter dateFromString:self.value];
	}
	
	if(self.value == nil) {
		self.dateValue = [NSDate date];
	}
	
	if([self.minDate isKindOfClass:[NSString class]]) {
		NSString* str = (NSString*)self.minDate;
		NSDate* date;
		if([str isEqualToString:@"now"]) {
			date = [NSDate date];
		} else if([str isEqualToString:@"currentMonth"]) {
			NSDateComponents* comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
			date = [self.calendar dateFromComponents:comps];
		} else {
			date = [self.formatter dateFromString:str];
		}

		self.minDate = date;
	}

	if([self.maxDate isKindOfClass:[NSString class]]) {
		NSString* str = (NSString*)self.maxDate;
		NSDate* date = nil;

		NSDateComponents* comps = [self componentsForISO8601Interval:str];
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

- (BOOL)shouldChangeCharactersInRange:(NSRange)range inString:(NSString*)fromString toReplacementString:(NSString*)string resultString:(NSString**)resultString
{
	return NO;
}

#pragma mark - @property dateValue

+ (NSSet*)keyPathsForValuesAffectingDateValue
{
	return [NSSet setWithObject:@"value"];
}

- (NSDate*)dateValue
{
	return self.value;
}

- (void)setDateValue:(NSDate *)dateValue
{
	self.value = dateValue;
}

#pragma mark - @property minDate

+ (BOOL)automaticallyNotifiesObserversOfMinDate
{
	return NO;
}

- (NSDate*)minDate
{
	return [self.dict objectForKey:@"minDate"];
}

- (void)setMinDate:(NSDate *)minDate
{
	[self.dict setObject:minDate forKey:@"minDate"];
}

#pragma mark - @property maxDate

+ (BOOL)automaticallyNotifiesObserversOfMaxDate
{
	return NO;
}

- (NSDate*)maxDate
{
	return [self.dict objectForKey:@"maxDate"];
}

- (void)setMaxDate:(NSDate *)maxDate
{
	[self.dict setObject:maxDate forKey:@"maxDate"];
}

#pragma mark - Validation

- (NSError*)validate
{
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

#pragma mark - @property stringValue

- (NSString*)stringValue
{
	return self.dateValue.description;
}

- (void)setStringValue:(NSString *)stringValue
{
	NSAssert(false, @"unimplemented");
}

#pragma mark - @property fieldWidthCharacters

- (NSUInteger)fieldWidthCharacters
{
	return [[self.dict objectForKey:@"fieldWidthCharacters"] unsignedIntegerValue];
}

- (void)setFieldWidthCharacters:(NSUInteger)width
{
	[self.dict setObject:[NSNumber numberWithUnsignedInteger:width] forKey:@"fieldWidthCharacters"];
}

#pragma mark - @property datePickerMode

- (NSString*)datePickerMode
{
	return [self.dict objectForKey:@"datePickerMode"];
}

- (void)setDatePickerMode:(NSString *)datePickerMode
{
	[self.dict setObject:datePickerMode forKey:@"datePickerMode"];
}

#pragma mark - @property formattedDateValue

- (NSString*)formattedDateValue
{
	NSString* result;
	NSString* format = [NSDateFormatter dateFormatFromTemplate:@"yMMMM" options:0 locale:[NSLocale currentLocale]];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	
	result = [dateFormatter stringFromDate:self.dateValue];

	return result;
}
@end
