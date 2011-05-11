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

#import "StringUtils.h"

#ifdef __cplusplus
using namespace std;
#endif

NSString* DenullString(NSString* s)
{
	return (s == nil || s == (void*)[NSNull null]) ? @"" : s;
}

BOOL IsEmptyString(NSString* s)
{
	return DenullString(s).length == 0;
}

NSString* TrimCharacterSetFromStart(NSCharacterSet* set, NSString* str)
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    [scanner scanCharactersFromSet:set intoString:nil];
    return [str substringFromIndex:[scanner scanLocation]];
}

NSString* TrimCharacterSetFromEnd(NSCharacterSet* set, NSString* str)
{
    if([str length] == 0)
        return str;
        
    if(![set characterIsMember:[str characterAtIndex:[str length] - 1]])
        return str;

    NSMutableString* m = [NSMutableString stringWithString:str];
    do {
        [m deleteCharactersInRange:NSMakeRange([m length] - 1, 1)];
    } while([m length] > 0 && [set characterIsMember:[m characterAtIndex:[m length] - 1]]);
    
    return [NSString stringWithString:m];
}

NSString* StripControlCharacters(NSString* str)
{
    NSMutableString* m = [NSMutableString stringWithString:str];
    NSCharacterSet* set = [NSCharacterSet controlCharacterSet];
    for(int i = (int)[m length] - 1; i >= 0; --i) {
        if([set characterIsMember:[m characterAtIndex:i]]) {
            [m deleteCharactersInRange:NSMakeRange(i, 1)];
        }
    }
    
    return [NSString stringWithString:m];
}

NSString* TrimCharacterSetFromStartAndEnd(NSCharacterSet* set, NSString* str)
{
    return TrimCharacterSetFromStart(set, TrimCharacterSetFromEnd(set, str));
}

NSString* TrimWhitespaceFromStart(NSString* str)
{
    return TrimCharacterSetFromStart([NSCharacterSet whitespaceCharacterSet], str);
}

NSString* TrimWhitespaceFromEnd(NSString* str)
{
    return TrimCharacterSetFromEnd([NSCharacterSet whitespaceCharacterSet], str);
}

NSString* TrimWhitespaceFromStartAndEnd(NSString* str)
{
    return TrimWhitespaceFromStart(TrimWhitespaceFromEnd(str));
}

NSString* TrimWhitespaceAndNewlineFromStart(NSString* str)
{
    return TrimCharacterSetFromStart([NSCharacterSet whitespaceAndNewlineCharacterSet], str);
}

NSString* TrimWhitespaceAndNewlineFromEnd(NSString* str)
{
    return TrimCharacterSetFromEnd([NSCharacterSet whitespaceAndNewlineCharacterSet], str);
}

NSString* TrimWhitespaceAndNewlineFromStartAndEnd(NSString* str)
{
    return TrimWhitespaceAndNewlineFromStart(TrimWhitespaceAndNewlineFromEnd(str));
}

BOOL ScanCharacters(NSScanner* scanner, int n, NSString** str)
{
    unsigned loc = [scanner scanLocation];
    if(loc + n > [[scanner string] length]) {
        *str = nil;
        return NO;
    }
    *str = [[scanner string] substringWithRange:NSMakeRange(loc, n)];
    [scanner setScanLocation:loc + n];
    return YES;
}

BOOL StringContainsWhitespaceOrNewline(NSString* str, BOOL allowSpaces)
{
    NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	static NSMutableCharacterSet* mset = nil;
	if(allowSpaces) {
		if(mset == nil) {
			mset = [[NSMutableCharacterSet whitespaceAndNewlineCharacterSet] retain];
			[mset removeCharactersInString:@" "];
		}
		set = mset;
	}
    NSRange range = [str rangeOfCharacterFromSet:set];
    return range.length > 0;
}

BOOL StringContainsOnlyDigits(NSString* str)
{
    NSCharacterSet* set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange range = [str rangeOfCharacterFromSet:set];
    return range.length == 0;
}

BOOL IsVisibleString(NSString* str)
{
    unsigned strLen = [str length];
    if(strLen == 0) {
        return NO;
    } else {
        NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSRange range = [str rangeOfCharacterFromSet:set];
        return range.length != strLen;
    }
}

NSString* FormatInt(int i, int places, BOOL leadingZero)
{
    if(leadingZero) {
        return [NSString stringWithFormat:[@"%0" stringByAppendingString:[NSString stringWithFormat:@"%dd", places]], i];
    } else {
        return [NSString stringWithFormat:@"%d", i];
    }
}

BOOL StringContainsString(NSString* str1, NSString* str2)
{
    return [str1 rangeOfString:str2].location != NSNotFound;
}

BOOL StringBeginsWithString(NSString* str1, NSString* str2)
{
	return [str1 rangeOfString:str2].location == 0;
}

BOOL CompleteString(NSString* partial, NSArray* completions, NSString** completed)
{
    BOOL found = NO;
    
    for(unsigned i = 0; i < [completions count]; ++i) {
        NSString* completion = [completions objectAtIndex:i];
        NSRange existingRange = [completion rangeOfString:partial options:NSCaseInsensitiveSearch
            range:NSMakeRange(0, [completion length])];
        if(existingRange.location == 0 && existingRange.length > 0) {
            *completed = completion;
            found = YES;
            break;
        }
    }
    
    return found;
}

BOOL SearchAndReplace(NSString** destString, NSString* searchString, NSString* replaceString)
{
    NSRange range = [*destString rangeOfString:searchString];
    if(range.length > 0) {
        *destString = [NSMutableString stringWithString:*destString];
        [(NSMutableString*)*destString replaceCharactersInRange:range withString:replaceString];
        return YES;
    } else {
        return NO;
    }
}

NSString* StringByDeletingRange(NSString* str, NSRange range)
{
    if(range.location == NSNotFound)
        return [NSString stringWithString:str];
    else {
        NSString* s = @"";
        s = [s stringByAppendingString:[str substringToIndex:range.location]];
        s = [s stringByAppendingString:[str substringFromIndex:NSMaxRange(range)]];
        return s;
    }
}

// Needs to be moved: Not supported in iPhone OS
#if 0
NSString* StringFromOSType(OSType osType)
{
	return NSFileTypeForHFSTypeCode(osType);
}

OSType OSTypeFromString(NSString* osTypeString)
{
	return NSHFSTypeCodeFromFileType(osTypeString);
}
#endif

NSString* StringByTruncatingString(NSString* string, unsigned maxCharacters)
{
	NSString* resultString;
	if([string length] <= maxCharacters) {
		resultString = [[string copy] autorelease];
	} else {
		resultString = [string substringToIndex:maxCharacters];
	}
	return resultString;
}

NSString* StringByDuplicatingCharacter(unichar character, unsigned length)
{
	unichar* buffer = (unichar*)malloc(length * sizeof(unichar));
	for(unsigned i = 0; i < length; ++i) {
		buffer[i] = character;
	}
	NSString* string = [NSString stringWithCharacters:buffer length:length];
	free(buffer);
	return string;
}

NSString* BulletStringForString(NSString* string)
{
	return StringByDuplicatingCharacter(0x2022 /* unicode bullet */, [string length]);
}

#ifdef __cplusplus

NSString* ToCocoa(string const& s)
{
	return [NSString stringWithUTF8String:s.c_str()];
}

NSString* ToCocoa(string const* s, NSString* default_s)
{
	if(s != NULL) {
		return ToCocoa(*s);
	} else {
		return default_s;
	}
}

string ToStd(NSString* s)
{
	if(s == nil) {
		return string();
	} else {
		return string([s UTF8String]);
	}
}
#endif

@implementation NSString (CUString)

// From OmniFoundation
+ (NSString *)stringWithCharacter:(unichar)aCharacter;
{
    return [[[NSString alloc] initWithCharacters:&aCharacter length:1] autorelease];
}

// From OmniFoundation
+ (NSString *)horizontalEllipsisString;
{
    static NSString *string = nil;

    if (!string)
        string = [[self stringWithCharacter:0x2026] retain];

//    OBPOSTCONDITION(string);

    return string;
}

+ (NSString*)stringWithUUID
{
	NSString* string = nil;
	
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	string = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	
	return [string autorelease];
}

+ (NSString*)stringWithASCIIData:(NSData*)data
{
	return [self stringWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding
{
	return [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:encoding] autorelease];
}

+ (NSString*)stringWithCRLF
{
	return @"\r\n";
}

+ (NSString*)stringWithComponents:(NSArray*)components separator:(NSString*)separator
{
	NSMutableString* str = [NSMutableString string];
	
	BOOL first = YES;
	for(NSString* component in components) {
		if(!first) {
			[str appendString:separator];
		}
		[str appendString:component];
		first = NO;
	}
	
	return [NSString stringWithString:str];
}

- (NSData*)dataUsingASCIIEncoding
{
	return [self dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData*)dataUsingUTF8Encoding
{
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray*)tokenize
{
	NSMutableArray* tokens = [NSMutableArray array];

	NSScanner* scanner = [NSScanner scannerWithString:self];
	NSCharacterSet* validChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	while(![scanner isAtEnd]) {
		NSString* token;
		if([scanner scanUpToCharactersFromSet:validChars intoString:&token]) {
			[tokens addObject:token];
		}
	}
	
	return tokens;
}

- (BOOL)matchesAllTokens:(NSArray*)tokens caseInsensitive:(BOOL)caseInsensitive
{
	BOOL result = YES;

	unsigned tokenCount = [tokens count];
	unsigned searchOptions = caseInsensitive ? NSCaseInsensitiveSearch : 0;
	for(unsigned i = 0; i < tokenCount; ++i) {
		NSString* token = [tokens objectAtIndex:i];
		if([self rangeOfString:token options:searchOptions].location == NSNotFound) {
			result = NO;
			break;
		}
	}

	return result;
}

- (BOOL)matchesAnyTokens:(NSArray*)tokens caseInsensitive:(BOOL)caseInsensitive
{
	BOOL result = NO;

	unsigned tokenCount = [tokens count];
	unsigned searchOptions = caseInsensitive ? NSCaseInsensitiveSearch : 0;
	for(unsigned i = 0; i < tokenCount; ++i) {
		NSString* token = [tokens objectAtIndex:i];
		if([self rangeOfString:token options:searchOptions].location != NSNotFound) {
			result = YES;
			break;
		}
	}

	return result;
}

- (NSString*)lastCharacters:(NSInteger)count
{
	return [self substringFromIndex:[self length] - count];
}

- (NSString*)lastCharacter
{
	return [self lastCharacters:1];
}

- (NSString*)pathByRemovingLeadingSlash
{
	NSString* result = self;
	
	if(self.length > 0) {
		if([[self substringToIndex:1] isEqualToString:@"/"]) {
			result = [self substringFromIndex:1];
		}
	}
	
	return result;
}

- (NSString*)stringByAddingPercentEscapes
{
	NSString* s = nil;
	
	// KLUDGE: We pass a literal CFSTR for legalURLCharactersToBeEscaped to work around an Apple bug.
	s = [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("!$&'()*+,-./:;=?@_~"), kCFStringEncodingUTF8) autorelease];
	
	return s;
}

- (NSString*)stringByReplacingPercentEscapes
{
	NSString* s = nil;
	
	s = [(NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, NULL) autorelease];
	
	return s;
}

@end

NSString* StringFromBool(BOOL b, BOOL cStyle)
{
	if(cStyle) {
		return b ? @"true" : @"false";
	} else {
		return b ? @"YES" : @"NO";
	}
}

NSString* StringFromObjectConvertingBool(id obj, BOOL cStyle)
{
	NSString* str;
	
	if(obj == (id)kCFBooleanTrue)
		str = cStyle ? @"true" : @"YES";
	else if(obj == (id)kCFBooleanFalse)
		str = cStyle ? @"false" : @"NO";
	else 
		str = [obj description];
	
	return str;
}

@interface CEntitiesConverter : NSObject<NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableString* resultString;

@end


@implementation CEntitiesConverter

@synthesize resultString;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s
{
        [self.resultString appendString:s];
}

- (NSString*)unescapeEntitiesInString:(NSString*)s {
	self.resultString = [NSMutableString string];
	
    NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
    NSData* data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[[NSXMLParser alloc] initWithData:data] autorelease];
    [xmlParse setDelegate:self];
    [xmlParse parse];
    return [NSString stringWithString:self.resultString];
}

- (void)dealloc {
    self.resultString = nil;
    [super dealloc];
}

@end

NSString* StringByUnescapingEntitiesInString(NSString* s)
{
	CEntitiesConverter* converter = [[[CEntitiesConverter alloc] init] autorelease];
	
	return [converter unescapeEntitiesInString:s];
}

// This function only unescapes "&lt;", "&gt;" and "&amp;" and does not gag on a naked "&",
// unlike StringByUnescapingEntitiesInString.

NSString* StringByUnescapingMinimalEntitiesInUncleanString(NSString* s)
{
	if ([s rangeOfString:@"&"].location == NSNotFound) return s;

	s = [s stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	s = [s stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	return [s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}

NSString* StringByJoiningNonemptyStringsWithString(NSArray* strings, NSString* separator)
{
	NSMutableArray* a = [NSMutableArray arrayWithCapacity:strings.count];
	for(NSString* s in strings) {
		if(!IsEmptyString(s)) {
			[a addObject:s];
		}
	}
	return [a componentsJoinedByString:separator];
}

NSString* StringByCapitalizingFirstCharacter(NSString* s)
{
	if(s == nil) return nil;
	else if(s.length == 0) return s;
	else if(s.length == 1) return [s uppercaseString];
	else {
		return [NSString stringWithFormat:@"%@%@", [[s substringToIndex:1] uppercaseString], [s substringFromIndex:1]];
	}
}

#if 0
void StringByTrimmingWhitespaceFromEndTest()
{
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"") isEqualToString:@""], @"Case 1");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"A") isEqualToString:@"A"], @"Case 2");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"A ") isEqualToString:@"A"], @"Case 3");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"A  ") isEqualToString:@"A"], @"Case 4");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"Dog ") isEqualToString:@"Dog"], @"Case 5");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"Dog Cat") isEqualToString:@"Dog Cat"], @"Case 6");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"Dog Cat ") isEqualToString:@"Dog Cat"], @"Case 7");
	NSCAssert([StringByTrimmingWhitespaceFromEnd(@"Dog Cat  ") isEqualToString:@"Dog Cat"], @"Case 8");
}
#endif

NSString* StringByTrimmingWhitespaceFromEnd(NSString* s)
{
	NSString* result = s;
	
	NSRange r = [s rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] options:NSBackwardsSearch];
	if(r.location != NSNotFound) {
		result = [s substringToIndex:r.location + 1];
	}

	return result;
}

NSString* LastWordOfString(NSString* s)
{
	NSString* result = nil;
	
	NSRange r = [s rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch];
	if(r.location == NSNotFound) {
		result = s;
	} else if(r.location == s.length - 1) {
		result = @"";
	} else {
		result = [s substringFromIndex:r.location + 1];
	}
	
	return result;
}

NSString* StringByRemovingLastWordOfString(NSString* s)
{
	NSString* result = nil;

//	StringByTrimmingWhitespaceFromEndTest();

	s = StringByTrimmingWhitespaceFromEnd(s);
	
	NSRange r = [s rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch];
	if(r.location == NSNotFound) {
		result = @"";
	} else {
		result = [s substringToIndex:r.location];
	}
	
	return result;
}

NSString* StringByEscapingQuotesAndBackslashes(NSString* s)
{
	NSScanner* source = [NSScanner scannerWithString:s];
	[source setCharactersToBeSkipped:nil];

	NSMutableString* sink = [NSMutableString string];

	NSCharacterSet* charactersToEscape = [NSCharacterSet characterSetWithCharactersInString:@"\"\\"];
	BOOL scanningForCharactersToEscape = NO;
	while(![source isAtEnd]) {
		NSString* scannedCharacters;

		if(scanningForCharactersToEscape) {
			if([source scanCharactersFromSet:charactersToEscape intoString:&scannedCharacters]) {
				for(int i = 0; i < scannedCharacters.length; i++) {
					unichar c = [scannedCharacters characterAtIndex:i];
					[sink appendFormat:@"\\%C", c];
				}
			}
		} else {
			if([source scanUpToCharactersFromSet:charactersToEscape intoString:&scannedCharacters]) {
				[sink appendString:scannedCharacters];
			}
		}
		
		scanningForCharactersToEscape = !scanningForCharactersToEscape;
	}

	return [NSString stringWithString:sink];
}

NSString* StringBySurroundingStringWithQuotes(NSString* s, BOOL onlyIfNecessary)
{
	NSString* result = s;

	BOOL surround = !onlyIfNecessary;
	if(!surround) {
		if(IsEmptyString(s)) {
			surround = YES;
		} else if([s rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
			surround = YES;
		} else if([s rangeOfString:@"\""].location != NSNotFound) {
			surround = YES;
		}
	}

	if(surround) {
		result = StringByEscapingQuotesAndBackslashes(result);
		result = [NSString stringWithFormat:@"\"%@\"", result];
	}
	
	return result;
}

NSString* StringByLimitingLengthOfString(NSString* s, NSUInteger maxLength, BOOL addEllipsis)
{
	if(maxLength != NSUIntegerMax) {
		NSInteger mLength = maxLength;
		if(addEllipsis) {
			mLength -= 3;
			if(mLength < 0) mLength = 0;
		}
		if(s.length > mLength) {
			s = [s substringToIndex:mLength];
			if(addEllipsis) {
				s = [s stringByAppendingString:@"..."];
			}
		}
	}
	return s;
}

NSString* StringByRemovingWhitespaceAndNewLines(NSString* string)
{
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
}

NSString* StringWithURLEscapedParamaters(NSDictionary* params)
{
	NSArray* keyStrings = [params allKeys];
	NSMutableArray* outParams = [NSMutableArray array];
	for(NSString* keyString in keyStrings) {
		id value = [params valueForKey:keyString];
		NSString* valueString = StringFromObjectConvertingBool(value, YES);
		NSString* escapedValueString = [valueString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString* paramString = [NSString stringWithFormat:@"%@=%@", keyString, escapedValueString];
		[outParams addObject:paramString];
	}
	return [NSString stringWithComponents:outParams separator:@"&"];
}
