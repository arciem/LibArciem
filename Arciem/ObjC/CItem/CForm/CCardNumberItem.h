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

#import "CStringItem.h"

extern NSString* const CCardSchemeUnknown;
extern NSString* const CCardSchemeVisa;
extern NSString* const CCardSchemeMastercard;
extern NSString* const CCardSchemeAmex;
extern NSString* const CCardSchemeDinersClub;
extern NSString* const CCardSchemeDiscover;
extern NSString* const CCardSchemeJCB;

extern NSString* const CCardNumberItemErrorDomain;

enum {
	CCardNumberItemErrorUnknownType = 5000,
    CCardNumberItemErrorIncomplete,
	CCardNumberItemErrorBadCheckDigit
};

@interface CCardNumberItem : CStringItem

@property (nonatomic) NSArray* validCardTypes;
@property (readonly, nonatomic) NSString* cardType;

+ (NSString *)generateSampleForCardType:(NSString *)cardType;

@end
