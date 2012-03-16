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

#import "CCreditCardItem.h"
#import "StringUtils.h"
#import "ErrorUtils.h"
#import "ObjectUtils.h"
#import "CTableCreditCardItem.h"

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
NSString* const CCreditCardItemErrorDomain = @"CCreditCardItemErrorDomain";

NSString* const CCreditCardTypeUnknown = @"any";
NSString* const CCreditCardTypeVisa = @"visa";
NSString* const CCreditCardTypeMastercard = @"mastercard";
NSString* const CCreditCardTypeAmex = @"amex";
NSString* const CCreditCardTypeDinersClub = @"diners";
NSString* const CCreditCardTypeDiscover = @"discover";
NSString* const CCreditCardTypeJCB = @"jcb";

// See http://www.regular-expressions.info/creditcard.html
static NSString* const kAnyRegularExpression = @"^[0-9]+$";
static NSString* const kVisaRegularExpression = @"^4[0-9]{12}(?:[0-9]{3})?$";
static NSString* const kMastercardRegularExpression = @"^5[1-5][0-9]{14}$";
static NSString* const kAmexRegularExpression = @"^3[47][0-9]{13}$";
static NSString* const kDinersClubRegularExpression = @"^3(?:0[0-5]|[68][0-9])[0-9]{11}$";
static NSString* const kDiscoverRegularExpression = @"^6(?:011|5[0-9]{2})[0-9]{12}$";
static NSString* const kJCBRegularExpression = @"^(?:2131|1800|35\\d{3})\\d{11}$";

static NSDictionary* sCardTypeRegularExpressions;

@interface CCreditCardItem ()

@property (strong, readwrite, nonatomic) NSString* cardType;
@property (readonly, nonatomic) NSDictionary* cardTypeRegularExpressions;

@end

@implementation CCreditCardItem

@synthesize cardType = cardType_;

- (id)initWithDictionary:(NSDictionary *)dict
{
	if(self = [super initWithDictionary:dict]) {
		self.validCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 -"];
	}
	return self;
}

- (NSArray*)validCardTypes
{
	return [self.dict objectForKey:@"validCardTypes"];
}

- (void)setValidCardTypes:(NSArray *)validCardTypes
{
	[self.dict setObject:validCardTypes forKey:@"validCardTypes"];
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

- (NSDictionary*)cardTypeRegularExpressions{
	if(sCardTypeRegularExpressions == nil) {
		sCardTypeRegularExpressions = [NSDictionary dictionaryWithObjectsAndKeys:
									   kAnyRegularExpression, CCreditCardTypeUnknown,
									   kVisaRegularExpression, CCreditCardTypeVisa,
									   kMastercardRegularExpression, CCreditCardTypeMastercard,
									   kAmexRegularExpression, CCreditCardTypeAmex,
									   kDinersClubRegularExpression, CCreditCardTypeDinersClub,
									   kDiscoverRegularExpression, CCreditCardTypeDiscover,
									   kJCBRegularExpression, CCreditCardTypeJCB,
									   nil];
	}
	return sCardTypeRegularExpressions;
}

- (NSError*)validate
{
	__block NSError* error = [super validate];
	
	if(error == nil) {
		NSString* str = self.stringValue;
		NSCharacterSet* nonDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
		str = StripCharactersInSet(str, nonDigits);

		if(![self luhnCheckString:str]) {
			error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorTooLong localizedFormat:@"Invalid card number."];
		} else {
			__block NSString* resultCardType = nil;
			[self.validCardTypes enumerateObjectsUsingBlock:^(NSString* cardType, NSUInteger idx, BOOL *stop) {
				NSString* regex = [self.cardTypeRegularExpressions objectForKey:cardType];
				NSAssert1(regex != nil, @"No regular expression for card type:%@", cardType);
				if([self string:str matchesRegularExpression:regex]) {
					if(self.validCardTypes.count == 0 || [self.validCardTypes containsObject:cardType]) {
						resultCardType = cardType;
					}
					*stop = YES;
				}
			}];
			
			if(resultCardType == nil) {
				error = [NSError errorWithDomain:CCreditCardItemErrorDomain code:CCreditCardItemErrorUnknownType localizedFormat:@"Unknown or unacceptable card type."];
			}
			self.cardType = resultCardType;
		}
	}
	
	if(error != nil) {
		self.cardType = nil;
	}
	
	return error;
}

// See http://en.wikipedia.org/wiki/Luhn_algorithm
// See http://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers#Objective-C
- (BOOL)luhnCheckString:(NSString*)string
{
	NSArray *stringAsChars = [string allCharacters];
	
	BOOL isOdd = YES;
	NSInteger oddSum = 0;
	NSInteger evenSum = 0;
	
	for (NSInteger i = string.length - 1; i >= 0; i--) {
		
		NSInteger digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
		
		if (isOdd) 
			oddSum += digit;
		else 
			evenSum += digit/5 + (2*digit) % 10;
		
		isOdd = !isOdd;				 
	}
	
	return ((oddSum + evenSum) % 10 == 0);
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	CTableCreditCardItem* rowItem = [CTableCreditCardItem itemWithKey:self.key title:self.title creditCardItem:self];
	return [NSArray arrayWithObject:rowItem];
}

@end
