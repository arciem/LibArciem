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

#import "CStringItem.h"
#import "ObjectUtils.h"
#import "StringUtils.h"
#import "ErrorUtils.h"

NSString* const CStringItemErrorDomain = @"CStringItemErrorDomain";

@interface CStringItem ()

@property (strong, nonatomic) NSCharacterSet* invalidCharacterSet;

@end

@implementation CStringItem

@synthesize minLength = minLength_;
@synthesize maxLength = maxLength_;
@synthesize validCharacterSet = validCharacterSet_;
@synthesize invalidCharacterSet = invalidCharacterSet_;
@synthesize validRegularExpression = validRegularExpression_;
@dynamic stringValue;
@dynamic currentLength;
@dynamic remainingLength;

#pragma mark - Lifecycle

- (id)initWithDictionary:(NSDictionary*)dict
{
	if(self = [super initWithDictionary:dict]) {
		NSNumber* maxLengthNumber = [dict objectForKey:@"maxLength"];
		if(maxLengthNumber == nil) {
			maxLength_ = 100;
		} else {
			maxLength_ = [maxLengthNumber unsignedIntValue];
		}
		
		minLength_ = [[dict objectForKey:@"minLength"] unsignedIntValue];
	}
	
	return self;
}

+ (CItem*)stringItemWithDictionary:(NSDictionary*)dict
{
	return [[self alloc] initWithDictionary:dict];
}

+ (CItem*)stringItem
{
	return [self stringItemWithDictionary:nil];
}

+ (CItem*)stringItemWithTitle:(NSString*)title key:(NSString*)key stringValue:(NSString*)stringValue
{
	return [self stringItemWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
											 title, @"title",
											 key, @"key",
											 stringValue, @"value",
											 nil]];
}

#pragma mark - Debugging

- (NSArray*)descriptionStringsCompact:(BOOL)compact
{
	NSArray* comps = [NSArray arrayWithObjects:
					  [self formatValueForKey:@"minLength" compact:compact],
					  [self formatValueForKey:@"maxLength" compact:compact],
					  nil];
	return [[super descriptionStringsCompact:compact] arrayByAddingObjectsFromArray:comps];
}

#pragma mark - @property stringValue

+ (NSSet*)keyPathsForValuesAffectingStringValue
{
	return [NSSet setWithObject:@"value"];
}

- (NSString*)stringValue
{
	return DenullString(self.value);
}

- (void)setStringValue:(NSString *)stringValue
{
	self.value = EnnullString(stringValue);
}

- (BOOL)isEmpty
{
	return IsEmptyString(self.stringValue);
}

#pragma mark - @property currentLength

+ (NSSet*)keyPathsForValuesAffectingCurrentLength
{
	return [NSSet setWithObject:@"stringValue"];
}

- (NSUInteger)currentLength
{
	return self.stringValue.length;
}

#pragma mark - @property remainingLength

+ (NSSet*)keyPathsForValuesAffectingRemainingLength
{
	return [NSSet setWithObjects:@"currentLength", @"maxLength", nil];
}

- (NSInteger)remainingLengthForLength:(NSUInteger)length
{
	NSInteger result = NSIntegerMax;
	
	if(self.maxLength > 0) {
		result = (NSInteger)self.maxLength - length;
	}
	
	return result;
}

- (NSInteger)remainingLength
{
	return [self remainingLengthForLength:self.currentLength];
}

#pragma mark - @property validCharacterSet

- (NSCharacterSet*)validCharacterSet
{
	return validCharacterSet_;
}

- (void)setValidCharacterSet:(NSCharacterSet *)validCharacterSet
{
	validCharacterSet_ = validCharacterSet;
	self.invalidCharacterSet = [validCharacterSet invertedSet];
}

- (BOOL)allCharactersValidInString:(NSString*)string
{
	BOOL result = YES;
	
	if(self.invalidCharacterSet != nil) {
		NSRange range = [string rangeOfCharacterFromSet:self.invalidCharacterSet];
		result = range.location == NSNotFound;
	}
	
	return result;
}

- (BOOL)stringMatchesValidRegularExpression:(NSString*)string
{
	BOOL result = YES;
	
	if(self.validRegularExpression != nil) {
		NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch | NSRegularExpressionSearch;
		NSRange range = [self.stringValue rangeOfString:self.validRegularExpression options:options];
		result = range.location != NSNotFound;
	}
	
	return result;
}

#pragma mark - Editing

- (BOOL)shouldChangeFromString:(NSString*)fromString toString:(NSString*)toString
{
	BOOL result = YES;
	
	if([self remainingLengthForLength:toString.length] < 0) {
		result = NO;
	} else {
		result = [self allCharactersValidInString:toString];
	}
	
	return result;
}

- (BOOL)shouldChangeCharactersInRange:(NSRange)range inString:(NSString*)fromString toReplacementString:(NSString*)string resultString:(NSString**)resultString
{
	NSString* toString = [DenullString(fromString) stringByReplacingCharactersInRange:range withString:string];
	if(resultString != nil) {
		*resultString = toString;
	}
	return [self shouldChangeFromString:fromString toString:toString];
}

#pragma mark - Validation

- (NSError*)validate
{
	NSError* error = [super validate];
	
	if(error == nil) {
		if(self.currentLength > 0) {
			if(self.currentLength < self.minLength) {
				error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorTooShort localizedFormat:@"%@ must be at least %d characters long.", self.title, self.minLength];
			} else if(self.remainingLength < 0) {
				error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorTooLong localizedFormat:@"%@ must be no more than %d characters long.", self.title, self.maxLength];
			} else if(![self allCharactersValidInString:self.stringValue]) {
				error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorInvalidCharacters localizedFormat:@"%@ contains invalid characters.", self.title];
			} else if(![self stringMatchesValidRegularExpression:self.stringValue]) {
				error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorSyntaxError localizedFormat:@"%@ is not valid.", self.title];
			}
		}
	}
	
	return error;
}

@end
