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
#import "CTableTextFieldItem.h"

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

#pragma mark - Lifecycle

- (void)setup
{
	[super setup];

	NSNumber* maxLengthNumber = (self.dict)[@"maxLength"];
	if(maxLengthNumber == nil) {
		maxLength_ = 100;
	} else {
		maxLength_ = [maxLengthNumber unsignedIntValue];
	}
	
	minLength_ = [(self.dict)[@"minLength"] unsignedIntValue];
	
	[self syncToValidCharacters];
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
	return [self stringItemWithDictionary:@{@"title": title,
											 @"key": key,
											 @"value": stringValue}];
}

- (id)copyWithZone:(NSZone *)zone
{
	CStringItem* item = [super copyWithZone:zone];
	
	item.minLength = self.minLength;
	item.maxLength = self.maxLength;
	item.validCharacterSet = self.validCharacterSet;
	item.validRegularExpression = self.validRegularExpression;
	
	return item;
}

#pragma mark - Debugging

- (NSArray*)descriptionStringsCompact:(BOOL)compact
{
	NSArray* comps = @[[self formatValueForKey:@"minLength" compact:compact],
					  [self formatValueForKey:@"maxLength" compact:compact]];
	return [[super descriptionStringsCompact:compact] arrayByAddingObjectsFromArray:comps];
}

#pragma mark - @property stringValue

+ (NSSet*)keyPathsForValuesAffectingStringValue
{
	return [NSSet setWithObject:@"value"];
}

- (id)denullValue:(id)value
{
	return EnsureRealString(value);
}

- (id)ennullValue:(id)value
{
	return EnsureRealString(value);
}

- (NSString*)stringValue
{
	return self.value;
}

- (void)setStringValue:(NSString *)stringValue
{
	self.value = stringValue;
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

#pragma mark - @property autocapitalizationType

- (NSString*)autocapitalizationType
{
	return (self.dict)[@"autocapitalizationType"];
}

- (void)setAutocapitalizationType:(NSString *)autocapitalizationType
{
	(self.dict)[@"autocapitalizationType"] = autocapitalizationType;
}

#pragma mark - @property keyboardType

- (NSString*)keyboardType
{
	return (self.dict)[@"keyboardType"];
}

- (void)setKeyboardType:(NSString *)keyboardType
{
	(self.dict)[@"keyboardType"] = keyboardType;
}

#pragma mark - @property secureTextEntry

- (BOOL)secureTextEntry
{
	return [(self.dict)[@"secureTextEntry"] boolValue];
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
	(self.dict)[@"secureTextEntry"] = @(secureTextEntry);
}

#pragma mark - @property validCharacters

- (NSString*)validCharacters
{
	return (self.dict)[@"validCharacters"];
}

- (void)setValidCharacters:(NSString *)validCharacters
{
	(self.dict)[@"validCharacters"] = validCharacters;
	[self syncToValidCharacters];
}

- (void)syncToValidCharacters
{
	if(!IsEmptyString(self.validCharacters)) {
		self.validCharacterSet = [NSCharacterSet characterSetWithCharactersInString:self.validCharacters];
	}
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

- (BOOL)string:(NSString*)string matchesRegularExpression:(NSString*)regex
{
	BOOL result = YES;
	
	if(regex != nil) {
		NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch | NSRegularExpressionSearch;
		NSRange range = [string rangeOfString:regex options:options];
		result = range.location != NSNotFound;
	}
	
	return result;

}

- (BOOL)stringMatchesValidRegularExpression:(NSString*)string
{
	return [self string:string matchesRegularExpression:self.validRegularExpression];
}

#pragma mark - @property fieldWidthCharacters

- (NSUInteger)fieldWidthCharacters
{
	return [(self.dict)[@"fieldWidthCharacters"] unsignedIntegerValue];
}

- (void)setFieldWidthCharacters:(NSUInteger)width
{
	(self.dict)[@"fieldWidthCharacters"] = @(width);
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
	NSString* toString = [EnsureRealString(fromString) stringByReplacingCharactersInRange:range withString:string];
	if(resultString != nil) {
		if([self.autocapitalizationType isEqualToString:@"all"]) {
			toString = [toString uppercaseString];
		}
		*resultString = toString;
	}
	return [self shouldChangeFromString:fromString toString:toString];
}

#pragma mark - Validation

// May be overridden in subclasses
- (NSString*)formatCharacterCount:(NSUInteger)count
{
	NSString* format = count == 1 ? @"%d character" : @"%d characters";
	return [NSString stringWithFormat:format, count];
}

- (NSError*)validate
{
	NSError* error = [super validate];
	
	if(error == nil) {
		if(self.currentLength > 0) {
			
			if(error == nil) {
				if(self.minLength > 0 && self.minLength == self.maxLength && self.currentLength != self.minLength) {
					NSString* message = @"%@ must be exactly %@ long.";
					error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorWrongLength localizedFormat:message, self.title, [self formatCharacterCount:self.minLength]];
				}
			}
			
			if(error == nil) {
				if(self.currentLength < self.minLength) {
					NSString* message = @"%@ must be at least %@ long.";
					error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorTooShort localizedFormat:message, self.title, [self formatCharacterCount:self.minLength]];
				}
			}
			
			if(error == nil) {
				if(self.remainingLength < 0) {
					NSString* message = @"%@ must be no more than %@ long.";
					error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorTooLong localizedFormat:message, self.title, [self formatCharacterCount:self.maxLength]];
				}				
			}
			
			if(error == nil) {
				if(![self allCharactersValidInString:self.stringValue]) {
					error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorInvalidCharacters localizedFormat:@"%@ contains invalid characters.", self.title];
				}				
			}
			
			if(error == nil) {
				if(![self stringMatchesValidRegularExpression:self.stringValue]) {
					error = [NSError errorWithDomain:CStringItemErrorDomain code:CStringItemErrorSyntaxError localizedFormat:@"%@ is not valid.", self.title];
				}
			}
		}
	}
	
	return error;
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	CTableTextFieldItem* rowItem = [CTableTextFieldItem itemWithKey:self.key title:self.title stringItem:self];
	return @[rowItem];
}

@end
