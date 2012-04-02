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

#import "DateTimeUtils.h"

double TimeIntervalMinutes(NSTimeInterval t)
{
    return t / arciem::seconds_per_minute;
}

double TimeIntervalHours(NSTimeInterval t)
{
    return t / arciem::seconds_per_hour;
}

double TimeIntervalDays(NSTimeInterval t)
{
    return t / arciem::seconds_per_day;
}

double TimeIntervalMomentOfSecond(NSTimeInterval t)
{
    return t - (int)t;
}

int TimeIntervalSecondOfMinute(NSTimeInterval t)
{
    return ((int)t) % arciem::seconds_per_minute;
}

int TimeIntervalMinuteOfHour(NSTimeInterval t)
{
    return (((int)t) / arciem::seconds_per_minute) % arciem::minutes_per_hour;
}

int TimeIntervalHourOfDay(NSTimeInterval t)
{
    return (((int)t) / arciem::seconds_per_hour) % arciem::hours_per_day;
}

NSTimeInterval TimeIntervalFromDaysHoursMinutesSeconds(int days, int hours, int minutes, int seconds)
{
    NSTimeInterval i = 0;
    
    i += days * arciem::seconds_per_day;
    i += hours * arciem::seconds_per_hour;
    i += minutes * arciem::seconds_per_minute;
    i += seconds;
    
    return i;
}

@implementation NSDate (DateTimeUtils)

- (BOOL)isEarlierThanDate:(NSDate*)other
{
	return [self compare:other] == NSOrderedAscending;
}

- (BOOL)isLaterThanDate:(NSDate*)other
{
	return [self compare:other] == NSOrderedDescending;
}

- (BOOL)isEarlierThanOrEqualToDate:(NSDate*)other
{
	return [self isEarlierThanDate:other] || [self isEqualToDate:other];
}

- (BOOL)isLaterThanOrEqualToDate:(NSDate*)other
{
	return [self isLaterThanDate:other] || [self isEqualToDate:other];
}

- (BOOL)isOlderThanDate:(NSDate*)other
{
	return [self isEarlierThanDate:other];
}

- (BOOL)isYoungerThanDate:(NSDate*)other
{
	return [self isLaterThanDate:other];
}

- (BOOL)isOlderThanOrEqualToDate:(NSDate*)other
{
	return [self isEarlierThanOrEqualToDate:other];
}

- (BOOL)isYoungerThanOrEqualToDate:(NSDate*)other
{
	return [self isLaterThanOrEqualToDate:other];
}

- (NSDate*)dateByAddingDays:(int)days
{
	NSTimeInterval t = [self timeIntervalSinceReferenceDate];
	t += days * arciem::seconds_per_day;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:t];
}

- (NSDate*)dateByAddingMinutes:(int)minutes
{
	NSTimeInterval t = [self timeIntervalSinceReferenceDate];
	t += minutes * arciem::seconds_per_minute;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:t];
}

- (int)daysUntilDate:(NSDate*)other
{
    return (int)([other timeIntervalSinceDate:self] / arciem::seconds_per_day);
}

- (NSDate*)convertFromTimeZone:(NSTimeZone*)sourceTimeZone toTimeZone:(NSTimeZone*)destinationTimeZone
{
	NSInteger sourceSeconds = [sourceTimeZone secondsFromGMTForDate:self];
	NSInteger destinationSeconds = [destinationTimeZone secondsFromGMTForDate:self];
	NSTimeInterval interval = destinationSeconds - sourceSeconds;
	return [[NSDate alloc] initWithTimeInterval:interval sinceDate:self];
}

- (NSDate*)convertToGMT
{
	return [self convertFromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
}

@end

//
//  GHNSDate+Parsing.m
//
//  Created by Gabe on 3/18/08.
//  Copyright 2008 Gabriel Handford
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

@implementation NSDate (Parsing)

static NSDateFormatter *is8601DateFormatter = nil;
static NSDateFormatter *rfc822DateFormatter = nil;
static NSDateFormatter *rfc1123DateFormatter = nil;
static NSDateFormatter *rfc850DateFormatter = nil;
static NSDateFormatter *ascTimeDateFormatter = nil;

/*!
*/
+ (NSDate *)parseISO8601:(NSString *)dateString { 
  return [[self iso8601DateFormatter] dateFromString:dateString];
}

/*!
 @method parseRFC822
 @abstract Parse RFC822 encoded date
 @param dateString Date string to parse, eg. 'Wed, 01 Mar 2006 12:00:00 -0400'
 @result Date
*/
+ (NSDate *)parseRFC822:(NSString *)dateString {
  return [[self rfc822DateFormatter] dateFromString:dateString];
}

/*!
 @method parseHTTP
 @abstract Parse http date, currently only handles RFC1123 date
 @param dateString Date string to parse
 
 HTTP-date    = rfc1123-date | rfc850-date | asctime-date
 
 Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
 Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
 Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format 
 */
+ (NSDate *)parseHTTP:(NSString *)dateString {  
  NSDate *parsed = nil;
  parsed = [[self rfc1123DateFormatter] dateFromString:dateString];
  if (parsed) return parsed;
  parsed = [[self rfc850DateFormatter] dateFromString:dateString];
  if (parsed) return parsed;
  parsed = [[self ascTimeDateFormatter] dateFromString:dateString];
  return parsed;
}

/*!
  @method formatRFC822
  @abstract Get date formatted for RFC822
  @result The date string, like "Wed, 01 Mar 2006 12:00:00 -0400"
*/
- (NSString *)formatRFC822 {
  return [[[self class] rfc822DateFormatter] stringFromDate:self];
}

/*!
 @method formatHTTP
 @abstract Get date formatted for RFC1123 (HTTP date)
 @result The date string, like "Sun, 06 Nov 1994 08:49:37 GMT"
*/
- (NSString *)formatHTTP {
  return [[[self class] rfc1123DateFormatter] stringFromDate:self];
}

/*! 
 @method rfc822DateFormatter
 @abstract For example, Wed, 01 Mar 2006 12:00:00 -0400
 @result Date formatter for RFC822
*/
+ (NSDateFormatter *)rfc822DateFormatter {  
  if (!rfc822DateFormatter) {
    rfc822DateFormatter = [[NSDateFormatter alloc] init];     
    [rfc822DateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    // Need to force US locale when generating otherwise it might not be 822 compatible
    [rfc822DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];    
    [rfc822DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [rfc822DateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
  }
  
  return rfc822DateFormatter;
}

/*!
 @method iso8601DateFormatter
 @abstract For example, '2007-10-18T16:05:10.000Z'
 @result Date formatter for ISO8601
*/
+ (NSDateFormatter *)iso8601DateFormatter {
  // Example: 2007-10-18T16:05:10.000Z  
  if (!is8601DateFormatter) {
    is8601DateFormatter = [[NSDateFormatter alloc] init];
    [is8601DateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    // Need to force US locale when generating otherwise it might not be 8601 compatible
    [is8601DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];    
    [is8601DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [is8601DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
  }
  return is8601DateFormatter;
}

/*!
 @method rfc1123DateFormatter
 @abstract For example, 'Wed, 01 Mar 2006 12:00:00 GMT'
 @result Date formatter for RFC1123
 */
+ (NSDateFormatter *)rfc1123DateFormatter {
  // Example: "Wed, 01 Mar 2006 12:00:00 GMT"
  if (!rfc1123DateFormatter) {
    rfc1123DateFormatter = [[NSDateFormatter alloc] init];     
    [rfc1123DateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    // Need to force US locale when generating otherwise it might not be 822 compatible
    [rfc1123DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];    
    [rfc1123DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [rfc1123DateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
  }
  
  return rfc1123DateFormatter;
}

+ (NSDateFormatter *)rfc850DateFormatter {
  // Example: Sunday, 06-Nov-94 08:49:37 GMT
  if (!rfc850DateFormatter) {
    rfc850DateFormatter = [[NSDateFormatter alloc] init];
    [rfc850DateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [rfc850DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [rfc850DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [rfc850DateFormatter setDateFormat:@"EEEE, dd-MMM-yy HH:mm:ss zzz"];
  }
  return rfc850DateFormatter;
}

+ (NSDateFormatter *)ascTimeDateFormatter {
  
  // Example: Sun Nov  6 08:49:37 1994
  if (!ascTimeDateFormatter) {
    ascTimeDateFormatter = [[NSDateFormatter alloc] init];
    [ascTimeDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [ascTimeDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [ascTimeDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [ascTimeDateFormatter setDateFormat:@"EEE MMM d HH:mm:ss yyyy"];
  }  
  return ascTimeDateFormatter;
}

@end

@implementation NSDateFormatter (DateTimeUtils)

+ (BOOL)usesTwelvehourTime
{
	NSLocale* locale = [NSLocale currentLocale];
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:locale];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	NSString* dateFormat = [formatter dateFormat];
	NSRange foundRange = [dateFormat rangeOfString:@"a"];
	return foundRange.location != NSNotFound;
}

@end