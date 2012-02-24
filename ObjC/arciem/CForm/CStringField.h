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

#import "CField.h"

extern NSString* const CStringFieldErrorDomain;

enum {
	CStringFieldErrorTooShort = 1000,
	CStringFieldErrorTooLong,
	CStringFieldErrorInvalidCharacters
};

@interface CStringField : CField

@property (readonly, nonatomic) NSString* stringValue;
@property (readonly, nonatomic) NSUInteger currentLength;
@property (nonatomic) NSUInteger minLength;
@property (nonatomic) NSUInteger maxLength;
@property (readonly, nonatomic) NSInteger remainingLength;
@property (copy, nonatomic) NSCharacterSet* validCharacterSet;

- (BOOL)shouldChangeFromString:(NSString*)fromString toString:(NSString*)toString;
- (BOOL)shouldChangeCharactersInRange:(NSRange)range inString:(NSString*)fromString toReplacementString:(NSString*)string resultString:(NSString**)resultString;

@end
