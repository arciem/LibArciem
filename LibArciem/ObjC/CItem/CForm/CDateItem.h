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

#import "CItem.h"

extern NSString* const CDateItemErrorDomain;

enum {
	CDateItemErrorTooEarly = 1000,
	CDateItemErrorTooLate
};

@interface CDateItem : CItem

@property (strong, nonatomic) NSDate* dateValue;
@property (readonly, nonatomic) NSString* formattedDateValue;
@property (strong, nonatomic) NSDate* minDate;
@property (strong, nonatomic) NSDate* maxDate;
@property (strong, nonatomic) NSString* stringValue;
@property (nonatomic) NSUInteger fieldWidthCharacters;
@property (strong, nonatomic) NSString* datePickerMode; // time, date, dateAndTime, countDownTimer, monthAndYear

- (BOOL)shouldChangeCharactersInRange:(NSRange)range inString:(NSString*)fromString toReplacementString:(NSString*)string resultString:(NSString**)resultString;

@end
