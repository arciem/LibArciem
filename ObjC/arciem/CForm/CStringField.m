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

#import "CStringField.h"
#import "StringUtils.h"
#import "ErrorUtils.h"

NSString* const CStringFieldErrorDomain = @"CStringFieldErrorDomain";

@interface CStringField ()

@property (strong, nonatomic) NSCharacterSet* invalidCharacterSet;

@end

@implementation CStringField

@synthesize minLength = minLength_;
@synthesize maxLength = maxLength_;
@synthesize validCharacterSet = validCharacterSet_;
@synthesize invalidCharacterSet = invalidCharacterSet_;
@dynamic stringValue;
@dynamic currentLength;
@dynamic remainingLength;

+ (NSSet*)keyPathsForValuesAffectingStringValue
{
	return [NSSet setWithObject:@"value"];
}

+ (NSSet*)keyPathsForValuesAffectingCurrentLength
{
	return [NSSet setWithObject:@"stringValue"];
}

+ (NSSet*)keyPathsForValuesAffectingRemainingLength
{
	return [NSSet setWithObjects:@"currentLength", @"maxLength", nil];
}

- (NSString*)stringValue
{
	return DenullString(self.value);
}

- (BOOL)isEmpty
{
	return IsEmptyString(self.stringValue);
}

- (NSUInteger)currentLength
{
	return self.stringValue.length;
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

- (void)validateSuccess:(void (^)(CFieldState state))success failure:(void (^)(NSError* error))failure
{
	[super validateSuccess:^(CFieldState state) {
		if(self.currentLength < self.minLength) {
			failure([NSError errorWithDomain:CStringFieldErrorDomain code:CStringFieldErrorTooShort localizedFormat:@"%@ must be at least %d characters long.", self.title, self.minLength]);
		} else if(self.remainingLength < 0) {
			failure([NSError errorWithDomain:CStringFieldErrorDomain code:CStringFieldErrorTooLong localizedFormat:@"%@ must be no more than %d characters long.", self.title, self.maxLength]);
		} else {
			success(state);
		}
	} failure:^(NSError* error) {
		failure(error);
	}];
}

@end
