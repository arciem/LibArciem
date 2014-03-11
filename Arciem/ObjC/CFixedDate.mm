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

#import "CFixedDate.h"

static CFixedDate* __distantFuture = nil;
static CFixedDate* __distantPast = nil;

struct FD_DateInfo {
	int y, m, d;
};

@interface CFixedDate ()
{
@private
	NSInteger _year;
	NSInteger _month;
	NSInteger _day;
	NSInteger _weekday;
	NSDate* _date;
	NSDate* _GMTDate;
}

- (int)dayNumber;
- (FD_DateInfo)dateFromDayNumber:(int)n;
@end

@implementation CFixedDate

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}

- (CFixedDate*)initWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
	if((self = [super init])) {
		_year = year;
		_month = month;
		_day = day;
		_weekday = -1;
	}
	
	return self;
}


+ (CFixedDate*)fixedDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
	return [[CFixedDate alloc] initWithYear:year month:month day:day];
}

+ (CFixedDate*)fixedDateWithDate:(NSDate*)date
{
	NSCalendar *theCalendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comps = [theCalendar components:unitFlags fromDate:date];
	return [[CFixedDate alloc] initWithYear:[comps year] month:[comps month] day:[comps day]];
}

+ (CFixedDate*)fixedDateWithGMTDate:(NSDate*)date {
	NSCalendar *theCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSTimeZone *GMTTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	[theCalendar setTimeZone:GMTTimeZone];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comps = [theCalendar components:unitFlags fromDate:date];
	return [[CFixedDate alloc] initWithYear:[comps year] month:[comps month] day:[comps day]];
}

+ (CFixedDate*)fixedDate
{
	return [CFixedDate fixedDateWithDate:[NSDate date]];
}

+ (CFixedDate *)distantFuture
{
	if(__distantFuture == nil) {
		__distantFuture = [CFixedDate fixedDateWithDate:[NSDate distantFuture]];
	}
	
	return __distantFuture;
}

+ (CFixedDate *)distantPast
{
	if(__distantPast == nil) {
		__distantPast = [CFixedDate fixedDateWithDate:[NSDate distantPast]];
	}
	
	return __distantPast;
}

- (NSInteger)year
{
	return _year;
}

- (NSInteger)month
{
	return _month;
}

- (NSInteger)day
{
	return _day;
}

- (NSInteger)weekday
{
	if(_weekday < 0) {
		unsigned unitFlags = NSWeekdayCalendarUnit;
		NSDateComponents* comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:[self date]];
		_weekday = [comps weekday];
	}
	return _weekday;
}

- (NSDate*)date
{
	if(_date == nil) {
		NSDateComponents* c = [[NSDateComponents alloc] init];
		[c setYear:_year];
		[c setMonth:_month];
		[c setDay:_day];
		
		_date = [[NSCalendar currentCalendar] dateFromComponents:c];
	}
	return _date;
}

- (NSDate*)GMTDate {
	if(_GMTDate == nil) {
		NSDateComponents* c = [[NSDateComponents alloc] init];
		[c setYear:_year];
		[c setMonth:_month];
		[c setDay:_day];
		
		NSCalendar *theCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSTimeZone *GMTTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		[theCalendar setTimeZone: GMTTimeZone];
		_GMTDate = [theCalendar dateFromComponents:c];

	}
	return _GMTDate;
}

- (NSComparisonResult)compare:(CFixedDate *)other
{
//	return [[self date] compare:[other date]];
	int myNum = [self dayNumber];
	int otherNum = [other dayNumber];
	if (myNum == otherNum) return NSOrderedSame;
	return (myNum < otherNum ? NSOrderedAscending : NSOrderedDescending);
}

- (BOOL)isEqualToDate:(CFixedDate *)other
{
//	return [[self date] isEqualToDate:[other date]];
	return ([self dayNumber] == [other dayNumber]);

}

- (CFixedDate *)earlierDate:(CFixedDate *)other
{
	return [self isEarlierThanDate:other] ? self : other;
}

- (CFixedDate *)laterDate:(CFixedDate *)other
{
	return [self isLaterThanDate:other] ? self : other;
}

- (BOOL)isEarlierThanDate:(CFixedDate*)other
{
//	return [[self date] isEarlierThanDate:[other date]];
	return ([self dayNumber] < [other dayNumber]);
}

- (BOOL)isLaterThanDate:(CFixedDate*)other
{
//	return [[self date] isLaterThanDate:[other date]];
	return ([self dayNumber] > [other dayNumber]);
}

- (BOOL)isEarlierThanOrEqualToDate:(CFixedDate*)other
{
//	return [[self date] isEarlierThanOrEqualToDate:[other date]];
	return ([self dayNumber] <= [other dayNumber]);
}

- (BOOL)isLaterThanOrEqualToDate:(CFixedDate*)other
{
//	return [[self date] isLaterThanOrEqualToDate:[other date]];
	return ([self dayNumber] >= [other dayNumber]);
}

- (BOOL)isOlderThanDate:(CFixedDate*)other
{
//	return [[self date] isOlderThanDate:[other date]];
	return ([self dayNumber] < [other dayNumber]);
}

- (BOOL)isYoungerThanDate:(CFixedDate*)other
{
//	return [[self date] isYoungerThanDate:[other date]];
	return ([self dayNumber] > [other dayNumber]);
}

- (BOOL)isOlderThanOrEqualToDate:(CFixedDate*)other
{
//	return [[self date] isOlderThanOrEqualToDate:[other date]];
	return ([self dayNumber] <= [other dayNumber]);
}

- (BOOL)isYoungerThanOrEqualToDate:(CFixedDate*)other
{
//	return [[self date] isYoungerThanOrEqualToDate:[other date]];
	return ([self dayNumber] >= [other dayNumber]);
}

- (CFixedDate*)addDays:(int)days
{
//	return [CFixedDate fixedDateWithDate:[[self date] addDays:days]];
		
	FD_DateInfo info = [self dateFromDayNumber:[self dayNumber] + days];
	return [CFixedDate fixedDateWithYear:info.y month:info.m day:info.d]; // set with autorelease... hum...
}

- (int)daysUntilDate:(CFixedDate*)other
{
//	return [[self date] daysUntilDate:[other date]];
	return [other dayNumber] - [self dayNumber];
}

- (int)dayNumber {
	int y = _year, m = _month, d = _day;
	if (m < 3) { m += 12 ; y--; }
	return -678973 + d + ((153 * m - 2) / 5) + 365 * y + y / 4 - y / 100 + y / 400;
}

- (FD_DateInfo)dateFromDayNumber:(int)n {
	int g = 0, J, t, D, M, Y;
	FD_DateInfo info;
	J = n + 2400001;
	// Alg F : To convert a Julian day number, J, to a date D/M/Y
	g = (3 * ((4 * J + 274277) / 146097)) / 4 - 38; // not Julian
	J += 1401 + g;
	t = 4 * J + 3;
	Y = t / 1461;
	t = t % 1461 / 4;
	M = (t * 5 + 461) /153;
	D = ((t * 5 + 2) % 153) / 5;
	if (M > 12) { Y++ ; M -= 12; }
	info.y = Y - 4716;
	info.m = M;
	info.d = D + 1;
	return info;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"CFixedDate [%d %d %d]", (int)_year, (int)_month, (int)_day];
}

@end
