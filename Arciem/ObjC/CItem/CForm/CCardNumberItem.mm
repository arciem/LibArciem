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

#import "CCardNumberItem.h"
#import "StringUtils.h"
#import "ErrorUtils.h"
#import "ObjectUtils.h"
#import "CCardNumberTableRowItem.h"
#import "random.hpp"

/*****
 
 Test Card Numbers
 See http://www.paypalobjects.com/en_US/vhelp/paypalmanager_help/credit_card_numbers.htm
 
 American Express				3782 8224 6310 005
 American Express				3714 4963 5398 431
 American Express Corporate		3787 3449 3671 000
 
 Diner's Club					3056 9309 0259 04
 Diner's Club					3852 0000 0232 37
 
 Discover						6011 1111 1111 1117
 Discover						6011 0009 9013 9424
 
 JCB							3530 1113 3330 0000
 JCB							3566 0020 2036 0505
 
 MasterCard						5555 5555 5555 4444
 MasterCard						5105 1051 0510 5100
 
 Visa							4111 1111 1111 1111
 Visa							4012 8888 8888 1881
 Visa							4222 2222 2222 2
 
 *****/
NSString* const CCardNumberItemErrorDomain = @"CCardNumberItemErrorDomain";

NSString* const CCardSchemeUnknown = @"any";
NSString* const CCardSchemeVisa = @"visa";
NSString* const CCardSchemeMastercard = @"mastercard";
NSString* const CCardSchemeAmex = @"amex";
NSString* const CCardSchemeDinersClub = @"diners";
NSString* const CCardSchemeDiscover = @"discover";
NSString* const CCardSchemeJCB = @"jcb";

// See http://www.regular-expressions.info/creditcard.html
static NSString* const kAnyRegularExpression = @"^[0-9]+$";
static NSString* const kVisaRegularExpression = @"^4[0-9]{12}(?:[0-9]{3})?$";
static NSString* const kMastercardRegularExpression = @"^5[1-5][0-9]{14}$";
static NSString* const kAmexRegularExpression = @"^3[47][0-9]{13}$";
static NSString* const kDinersClubRegularExpression = @"^3(?:0[0-5]|[68][0-9])[0-9]{11}$";
static NSString* const kDiscoverRegularExpression = @"^6(?:011|5[0-9]{2})[0-9]{12}$";
static NSString* const kJCBRegularExpression = @"^(?:2131|1800|35\\d{3})\\d{11}$";

static NSString* const kAnyMinimalRegularExpression = @"^[0-9]+$";
static NSString* const kVisaMinimalRegularExpression = @"^4";
static NSString* const kMastercardMinimalRegularExpression = @"^5[1-5]";
static NSString* const kAmexMinimalRegularExpression = @"^3[47]";
static NSString* const kDinersClubMinimalRegularExpression = @"^3(?:0[0-5]|[68])";
static NSString* const kDiscoverMinimalRegularExpression = @"^6(?:011|5)";
static NSString* const kJCBMinimalRegularExpression = @"^(?:2131|1800|35)";

@interface CCardNumberItem ()

@property (strong, readwrite, nonatomic) NSString* cardType;

@end

@implementation CCardNumberItem

@synthesize cardType = cardType_;

- (void)setup
{
	[super setup];
	self.validCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 -"];
	self.keyboardType = @"numberPad";
    self.maxLength = 16;
}

- (NSArray*)validCardTypes
{
	return (self.dict)[@"validCardTypes"];
}

- (void)setValidCardTypes:(NSArray *)validCardTypes
{
	(self.dict)[@"validCardTypes"] = validCardTypes;
}

+ (BOOL)automaticallyNotifiesObserversOfCardType
{
	return NO;
}

- (NSString*)cardType
{
	return cardType_;
}

- (void)setCardType:(NSString *)cardType
{
	if(!Same(cardType_, cardType)) {
		[self willChangeValueForKey:@"cardType"];
		cardType_ = cardType;
		[self didChangeValueForKey:@"cardType"];
	}
}

+ (NSDictionary *)cardTypeRegularExpressions {
    static NSDictionary *dict;
	if(dict == nil) {
		dict = @{CCardSchemeUnknown: kAnyRegularExpression,
                 CCardSchemeVisa: kVisaRegularExpression,
                 CCardSchemeMastercard: kMastercardRegularExpression,
                 CCardSchemeAmex: kAmexRegularExpression,
                 CCardSchemeDinersClub: kDinersClubRegularExpression,
                 CCardSchemeDiscover: kDiscoverRegularExpression,
                 CCardSchemeJCB: kJCBRegularExpression};
	}
	return dict;
}

+ (NSDictionary *)cardTypeMinimalRegularExpressions {
    static NSDictionary *dict;
	if(dict == nil) {
		dict = @{CCardSchemeUnknown: kAnyMinimalRegularExpression,
                 CCardSchemeVisa: kVisaMinimalRegularExpression,
                 CCardSchemeMastercard: kMastercardMinimalRegularExpression,
                 CCardSchemeAmex: kAmexMinimalRegularExpression,
                 CCardSchemeDinersClub: kDinersClubMinimalRegularExpression,
                 CCardSchemeDiscover: kDiscoverMinimalRegularExpression,
                 CCardSchemeJCB: kJCBMinimalRegularExpression};
	}
	return dict;
}

+ (NSString *)generateRandomDigit {
    NSInteger d = (NSInteger)arciem::random_range(0, 10);
    return [NSString stringWithFormat:@"%ld", (long)d];
}

+ (NSString *)generateSampleNumberWithTotalDigits:(NSUInteger)totalDigits prefixes:(NSArray *)prefixes {
    NSMutableString *str = [NSMutableString new];
    NSUInteger digitsLeft = totalDigits;
    
    NSInteger prefixIndex = arciem::random_range(0, prefixes.count);
    NSString *prefix = prefixes[prefixIndex];
    [str appendString:prefix];
    digitsLeft -= prefix.length;
    
    while (digitsLeft > 1) {
        [str appendString:[self generateRandomDigit]];
        digitsLeft--;
    }
    
    [str appendString:[self luhnDigitForString:str]];
    
    return [str copy];
}

+ (NSDictionary *)cardTypeNumberGenerators {
    static NSDictionary *dict;
    BSELF;
	if(dict == nil) {
		dict = @{
                 CCardSchemeVisa: [^ NSString* (void){
                     return [bself generateSampleNumberWithTotalDigits:16 prefixes:@[@"4"]];
                 } copy],
                 CCardSchemeMastercard: [^ NSString* (void){
                     return [bself generateSampleNumberWithTotalDigits:16 prefixes:@[@"51", @"52", @"53", @"54", @"55"]];
                 } copy],
                 CCardSchemeAmex: [^ NSString* (void){
                     return [bself generateSampleNumberWithTotalDigits:15 prefixes:@[@"34", @"37"]];
                 } copy],
                 CCardSchemeDinersClub: [^ NSString* (void){
                     return [bself generateSampleNumberWithTotalDigits:16 prefixes:@[@"300", @"301", @"302", @"303", @"304", @"305", @"36", @"38"]];
                 } copy],
                 CCardSchemeDiscover: [^ NSString* (void){
                     return [bself generateSampleNumberWithTotalDigits:16 prefixes:@[@"6011", @"65"]];
                 } copy],
                 CCardSchemeJCB: [^ NSString* (void){
                     return [bself generateSampleNumberWithTotalDigits:16 prefixes:@[@"2131", @"1800", @"35"]];
                 } copy]
                 };
	}
    return dict;
}

+ (NSString *)newSampleNumberForCardType:(NSString *)cardType {
    NSString *result;
    NSString *(^generator)(void) = ([self cardTypeNumberGenerators])[cardType];
    if(generator != NULL) {
        result = generator();
    }
    return result;
}

- (NSError*)validate
{
	__block NSError* error = [super validate];
	
	if(error != nil) {
        self.cardType = nil;
    } else {
		static NSCharacterSet* nonDigits;
        if(nonDigits == nil) {
            nonDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        }

		NSString *str = StripCharactersInSet(self.stringValue, nonDigits);

        __block NSString* resultCardType = nil;
        [self.validCardTypes enumerateObjectsUsingBlock:^(NSString* cardType, NSUInteger idx, BOOL *stop) {
            NSString* minimalRegex = ([[self class] cardTypeMinimalRegularExpressions])[cardType];
            NSAssert1(minimalRegex != nil, @"No minimal regular expression for card type:%@", cardType);
            if([self string:str matchesRegularExpression:minimalRegex]) {
                if(self.validCardTypes.count == 0 || [self.validCardTypes containsObject:cardType]) {
                    resultCardType = cardType;
                    NSString* regex = ([[self class] cardTypeRegularExpressions])[cardType];
                    NSAssert1(regex != nil, @"No regular expression for card type:%@", cardType);
                    if(![self string:str matchesRegularExpression:regex]) {
                        error = [NSError errorWithDomain:CCardNumberItemErrorDomain code:CCardNumberItemErrorIncomplete localizedFormat:@"Incomplete card number."];
                    }
                }
                *stop = YES;
            }
        }];
        
        if(resultCardType == nil) {
            error = [NSError errorWithDomain:CCardNumberItemErrorDomain code:CCardNumberItemErrorUnknownType localizedFormat:@"Unknown or unacceptable card type."];
        }
        self.cardType = resultCardType;

        if(error == nil) {
            if(![[self class] luhnCheckString:str]) {
                error = [NSError errorWithDomain:CCardNumberItemErrorDomain code:CCardNumberItemErrorBadCheckDigit localizedFormat:@"Invalid card number. Please check to make sure it was entered correctly."];
            }
        }
	}
	
	return error;
}

// See http://en.wikipedia.org/wiki/Luhn_algorithm
// See http://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers#Objective-C

+ (NSInteger)luhnSumString:(NSString *)string {
	NSArray *stringAsChars = [string allCharacters];
	
	BOOL isOdd = YES;
	NSInteger oddSum = 0;
	NSInteger evenSum = 0;
	
	for (NSInteger i = string.length - 1; i >= 0; i--) {
		
		NSInteger digit = [(NSString *)stringAsChars[i] intValue];
		
		if (isOdd)
			oddSum += digit;
		else
			evenSum += digit/5 + (2*digit) % 10;
		
		isOdd = !isOdd;
	}
    
    return oddSum + evenSum;
}

+ (BOOL)luhnCheckString:(NSString*)string {
	return ([self luhnSumString:string] % 10 == 0);
}

+ (NSString *)luhnDigitForString:(NSString *)string {
    NSInteger s = [self luhnSumString:[string stringByAppendingString:@"0"]];
    NSInteger d = s % 10;
    if(d > 0) {
        d = 10 - d;
    }
//    NSInteger d = ( 10 - [self luhnSumString:string] % 10 ) % 10;
    return [NSString stringWithFormat:@"%ld", (long)d];
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	CCardNumberTableRowItem* rowItem = [CCardNumberTableRowItem newItemWithKey:self.key title:self.title cardNumberItem:self];
	return @[rowItem];
}

@end
