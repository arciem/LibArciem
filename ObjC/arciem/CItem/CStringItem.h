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

#import "CItem.h"

extern NSString* const CStringItemErrorDomain;

enum {
	CStringItemErrorTooShort = 1000,
	CStringItemErrorTooLong,
	CStringItemErrorInvalidCharacters,
	CStringItemErrorSyntaxError
};

@interface CStringItem : CItem

@property (nonatomic) NSString* stringValue;
@property (readonly, nonatomic) NSUInteger currentLength;
@property (nonatomic) NSUInteger minLength;
@property (nonatomic) NSUInteger maxLength;
@property (readonly, nonatomic) NSInteger remainingLength;
@property (copy, nonatomic) NSCharacterSet* validCharacterSet;
@property (copy, nonatomic) NSString* validRegularExpression;

- (id)initWithDictionary:(NSDictionary*)dict;
+ (CItem*)stringItem;
+ (CItem*)stringItemWithDictionary:(NSDictionary*)dict;
+ (CItem*)stringItemWithTitle:(NSString*)title key:(NSString*)key stringValue:(NSString*)stringValue;

- (BOOL)shouldChangeFromString:(NSString*)fromString toString:(NSString*)toString;
- (BOOL)shouldChangeCharactersInRange:(NSRange)range inString:(NSString*)fromString toReplacementString:(NSString*)string resultString:(NSString**)resultString;

@end
