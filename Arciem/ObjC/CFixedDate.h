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

#import <Foundation/Foundation.h>


@interface CFixedDate : NSObject <NSCopying>
{
	@private
	NSInteger _year;
	NSInteger _month;
	NSInteger _day;
	NSInteger _weekday;
	NSDate* _date;
	NSDate* _GMTDate;
}

+ (CFixedDate*)fixedDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (CFixedDate*)fixedDateWithDate:(NSDate*)date;
+ (CFixedDate*)fixedDateWithGMTDate:(NSDate*)date;
+ (CFixedDate*)fixedDate;
+ (CFixedDate *)distantFuture;
+ (CFixedDate *)distantPast;

- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)weekday;
- (NSDate*)date;
- (NSDate*)GMTDate;

- (NSComparisonResult)compare:(CFixedDate *)other;
- (BOOL)isEqualToDate:(CFixedDate *)other;
- (CFixedDate *)earlierDate:(CFixedDate *)other;
- (CFixedDate *)laterDate:(CFixedDate *)other;

- (BOOL)isEarlierThanDate:(CFixedDate*)other;
- (BOOL)isLaterThanDate:(CFixedDate*)other;
- (BOOL)isEarlierThanOrEqualToDate:(CFixedDate*)other;
- (BOOL)isLaterThanOrEqualToDate:(CFixedDate*)other;

- (BOOL)isOlderThanDate:(CFixedDate*)other;
- (BOOL)isYoungerThanDate:(CFixedDate*)other;
- (BOOL)isOlderThanOrEqualToDate:(CFixedDate*)other;
- (BOOL)isYoungerThanOrEqualToDate:(CFixedDate*)other;

- (CFixedDate*)addDays:(int)days;
- (int)daysUntilDate:(CFixedDate*)other;
@end
