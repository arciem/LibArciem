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

#import <Foundation/Foundation.h>
#include "time_utils.hpp"

double TimeIntervalMinutes(NSTimeInterval t);
double TimeIntervalHours(NSTimeInterval t);
double TimeIntervalDays(NSTimeInterval t);

double TimeIntervalMomentOfSecond(NSTimeInterval t);
int TimeIntervalSecondOfMinute(NSTimeInterval t);
int TimeIntervalMinuteOfHour(NSTimeInterval t);
int TimeIntervalHourOfDay(NSTimeInterval t);
NSTimeInterval TimeIntervalFromDaysHoursMinutesSeconds(int days, int hours, int minutes, int seconds);

@interface NSDate (DateTimeUtils)
- (BOOL)isEarlierThanDate:(NSDate*)other;
- (BOOL)isLaterThanDate:(NSDate*)other;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate*)other;
- (BOOL)isLaterThanOrEqualToDate:(NSDate*)other;

- (BOOL)isOlderThanDate:(NSDate*)other;
- (BOOL)isYoungerThanDate:(NSDate*)other;
- (BOOL)isOlderThanOrEqualToDate:(NSDate*)other;
- (BOOL)isYoungerThanOrEqualToDate:(NSDate*)other;

- (NSDate*)dateByAddingDays:(int)days;
- (NSDate*)dateByAddingMinutes:(int)minutes;
- (int)daysUntilDate:(NSDate*)other;

- (NSDate*)convertFromTimeZone:(NSTimeZone*)sourceTimeZone toTimeZone:(NSTimeZone*)destinationTimeZone;
- (NSDate*)convertToGMT;
@end

@interface NSDate (Parsing)

+ (NSDate *)parseISO8601:(NSString *)dateString;
+ (NSDate *)parseRFC822:(NSString *)dateString;
+ (NSDate *)parseHTTP:(NSString *)dateString;
+ (NSDateComponents*)componentsForISO8601Interval:(NSString*)str;
+ (NSTimeInterval)durationForISO8601Interval:(NSString*)str;

- (NSString *)formatRFC822;
- (NSString *)formatHTTP;

+ (NSDateFormatter *)iso8601DateFormatter;
+ (NSDateFormatter *)rfc822DateFormatter;
+ (NSDateFormatter *)rfc1123DateFormatter;
+ (NSDateFormatter *)rfc850DateFormatter;
+ (NSDateFormatter *)ascTimeDateFormatter;

@end

@interface NSDateFormatter (DateTimeUtils)

+ (BOOL)usesTwelvehourTime;

@end
