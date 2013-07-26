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

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define CLINKAGE "C"
#include <string>
#endif

NSString* EnsureRealString(NSString* s);
NSString* AllowStringToBeNil(NSString* s);
BOOL IsEmptyString(NSString* s);

NSString* TrimWhitespaceFromStart(NSString* str);
NSString* TrimWhitespaceFromEnd(NSString* str);
NSString* TrimWhitespaceFromStartAndEnd(NSString* str);

NSString* TrimWhitespaceAndNewlineFromStart(NSString* str);
NSString* TrimWhitespaceAndNewlineFromEnd(NSString* str);
NSString* TrimWhitespaceAndNewlineFromStartAndEnd(NSString* str);

NSString* TrimCharacterSetFromStart(NSCharacterSet* set, NSString* str);
NSString* TrimCharacterSetFromEnd(NSCharacterSet* set, NSString* str);
NSString* TrimCharacterSetFromStartAndEnd(NSCharacterSet* set, NSString* str);

BOOL ScanCharacters(NSScanner* scanner, int n, NSString** str);
BOOL StringContainsWhitespaceOrNewline(NSString* str, BOOL allowSpaces /* = NO */);
BOOL StringContainsOnlyDigits(NSString* str);
BOOL StringContainsString(NSString* str1, NSString* str2);
BOOL StringBeginsWithString(NSString* str1, NSString* str2);
NSString* FormatInt(int i, int places, BOOL leadingZero);
NSString* StringByDeletingRange(NSString* str, NSRange range);
NSString* StripCharactersInSet(NSString* str, NSCharacterSet* set);
NSString* StripControlCharacters(NSString* str);

// returns YES if the string has non-zero length and contains at least one non-whitespace character
BOOL IsVisibleString(NSString* str);

BOOL CompleteString(NSString* partial, NSArray* completions, NSString** completed);
BOOL SearchAndReplace(NSString** destString, NSString* searchString, NSString* replaceString);

NSString* StringFromOSType(OSType osType);
OSType OSTypeFromString(NSString* osTypeString);

NSString* StringByTruncatingString(NSString* string, NSUInteger maxCharacters);

NSString* StringByDuplicatingCharacter(unichar character, NSUInteger length);
NSString* BulletStringForString(NSString* string);

NSString* StringFromBool(BOOL b, BOOL cStyle = NO);
NSString* StringFromObjectConvertingBool(id obj, BOOL cStyle = NO);
NSString* StringByUnescapingEntitiesInString(NSString* s);
NSString* StringByUnescapingMinimalEntitiesInUncleanString(NSString* s);
NSString* StringByJoiningNonemptyStringsWithString(NSArray* strings, NSString* separator);
NSString* StringByJoiningNonemptyDescriptionsWithString(NSArray* items, NSString* separator);
NSString* StringByCapitalizingFirstCharacter(NSString* s);
NSString* StringByTrimmingWhitespaceFromEnd(NSString* s);
NSString* LastWordOfString(NSString* s);
NSString* StringByRemovingLastWordOfString(NSString* s);
NSString* StringByEscapingQuotesAndBackslashes(NSString* s);
NSString* StringBySurroundingStringWithQuotes(NSString* s, BOOL onlyIfNecessary);
NSString* StringByLimitingLengthOfString(NSString* s, NSUInteger maxLength, BOOL addEllipsis);
NSString* StringByRemovingWhitespaceAndNewLines(NSString* string);
NSString* StringWithURLEscapedParamaters(NSDictionary* params);
NSDictionary* DictionaryFromStringWithKeyValuePairs(NSString* string, NSString* recordSeparator, NSString* keyValueSeparator);

@interface NSString (CStringAdditions)

+ (NSString*)stringWithCharacter:(unichar)aCharacter;
+ (NSString*)horizontalEllipsisString; // '...'
+ (NSString*)stringWithUUID;
+ (NSString*)stringWithBase64UUIDURLSafe:(BOOL)URLSafe;
+ (NSString*)stringWithASCIIData:(NSData*)data;
+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;
+ (NSString*)stringWithCRLF;
+ (NSString*)stringWithComponents:(NSArray*)components separator:(NSString*)separator;

- (NSData*)dataUsingASCIIEncoding;
- (NSData*)dataUsingUTF8Encoding;

- (NSString*)stringUsingBase64Encoding;
- (NSString*)stringUsingBase64EncodingURLSafe:(BOOL)URLSafe;
+ (NSString*)stringByBase64EncodingData:(NSData*)data URLSafe:(BOOL)URLSafe;

- (NSArray*)tokenize;
- (BOOL)matchesAllTokens:(NSArray*)tokens caseInsensitive:(BOOL)caseInsensitive;
- (BOOL)matchesAnyTokens:(NSArray*)tokens caseInsensitive:(BOOL)caseInsensitive;

- (NSString*)lastCharacters:(NSInteger)count;
- (NSString*)lastCharacter;
- (NSString*)pathByRemovingLeadingSlash;

- (NSString*)stringByAddingPercentEscapes;
- (NSString*)stringByReplacingPercentEscapes;
- (NSString*)stringByReplacingTemplatesWithReplacements:(NSDictionary*)replacementsDict;

- (NSArray *)allCharacters;
- (NSArray *)allCapturesFromAllMatchesOfRegularExpression:(NSRegularExpression *)regex;
- (NSArray *)allCapturesFromFirstMatchOfRegularExpression:(NSRegularExpression *)regex;
- (NSString *)firstCaptureFromFirstMatchOfRegularExpression:(NSRegularExpression *)regex;
- (BOOL)matchesRegularExpression:(NSRegularExpression *)regex;

@end

@interface NSRegularExpression (CRegularExpressionAdditions)

+ (NSRegularExpression*)regularExpressionWithPattern:(NSString *)pattern;

@end

#ifdef __cplusplus
NSString* ToCocoa(std::string const& s);
NSString* ToCocoa(std::string const* s, NSString* default_s);
std::string ToStd(NSString* s);
#endif
