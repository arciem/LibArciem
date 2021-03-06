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

extern NSString* const CCreditCardTypeUnknown;
extern NSString* const CCreditCardTypeVisa;
extern NSString* const CCreditCardTypeMastercard;
extern NSString* const CCreditCardTypeAmex;
extern NSString* const CCreditCardTypeDinersClub;
extern NSString* const CCreditCardTypeDiscover;
extern NSString* const CCreditCardTypeJCB;

extern NSString* const CCreditCardItemErrorDomain;

enum {
	CCreditCardItemErrorBadCheckDigit = 5000,
    CCreditCardItemErrorBadLength,
	CCreditCardItemErrorUnknownType
};

@interface CCreditCardItem : CStringItem

@property (strong, nonatomic) NSArray* validCardTypes;
@property (strong, readonly, nonatomic) NSString* cardType;

@end
