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
#import "ObjectUtils.h"

#ifdef __cplusplus
using namespace std;
#endif

NSRange ClampRangeWithinString(NSRange range, NSString *s) {
    NSRange resultRange = range;
    
    if(s.length == 0) {
        resultRange = NSMakeRange(0, 0);
    } else if(range.location >= s.length) {
        resultRange = NSMakeRange(s.length, 0);
    } else if(range.location + range.length > s.length) {
        resultRange = NSMakeRange(range.location, s.length - range.location);
    }

    return resultRange;
}

NSString* EnsureRealString(NSString* s) {
	return Denull(s) == nil ? @"" : s;
}

NSString* AllowStringToBeNil(NSString* s) {
	return IsEmptyString(s) ? nil : s;
}

BOOL IsEmptyString(NSString* s) {
	return EnsureRealString(s).length == 0;
}

NSString* TrimCharacterSetFromStart(NSCharacterSet* set, NSString* str) {
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    [scanner scanCharactersFromSet:set intoString:nil];
    return [str substringFromIndex:[scanner scanLocation]];
}

NSString* TrimCharacterSetFromEnd(NSCharacterSet* set, NSString* str) {
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

NSString* StripCharactersInSet(NSString* str, NSCharacterSet* set) {
    NSMutableString* m = [NSMutableString stringWithString:str];
    for(int i = (int)[m length] - 1; i >= 0; --i) {
        if([set characterIsMember:[m characterAtIndex:i]]) {
            [m deleteCharactersInRange:NSMakeRange(i, 1)];
        }
    }
    
    return [NSString stringWithString:m];
}

NSString* StripControlCharacters(NSString* str) {
	return StripCharactersInSet(str, [NSCharacterSet controlCharacterSet]);
}

NSString* TrimCharacterSetFromStartAndEnd(NSCharacterSet* set, NSString* str) {
    return TrimCharacterSetFromStart(set, TrimCharacterSetFromEnd(set, str));
}

NSString* TrimWhitespaceFromStart(NSString* str) {
    return TrimCharacterSetFromStart([NSCharacterSet whitespaceCharacterSet], str);
}

NSString* TrimWhitespaceFromEnd(NSString* str) {
    return TrimCharacterSetFromEnd([NSCharacterSet whitespaceCharacterSet], str);
}

NSString* TrimWhitespaceFromStartAndEnd(NSString* str) {
    return TrimWhitespaceFromStart(TrimWhitespaceFromEnd(str));
}

NSString* TrimWhitespaceAndNewlineFromStart(NSString* str) {
    return TrimCharacterSetFromStart([NSCharacterSet whitespaceAndNewlineCharacterSet], str);
}

NSString* TrimWhitespaceAndNewlineFromEnd(NSString* str) {
    return TrimCharacterSetFromEnd([NSCharacterSet whitespaceAndNewlineCharacterSet], str);
}

NSString* TrimWhitespaceAndNewlineFromStartAndEnd(NSString* str) {
    return TrimWhitespaceAndNewlineFromStart(TrimWhitespaceAndNewlineFromEnd(str));
}

BOOL ScanCharacters(NSScanner* scanner, int n, NSString** str) {
    NSUInteger loc = [scanner scanLocation];
    if(loc + n > [[scanner string] length]) {
        *str = nil;
        return NO;
    }
    *str = [[scanner string] substringWithRange:NSMakeRange(loc, n)];
    [scanner setScanLocation:loc + n];
    return YES;
}

BOOL StringContainsWhitespaceOrNewline(NSString* str, BOOL allowSpaces) {
    NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	static NSMutableCharacterSet* mset = nil;
	if(allowSpaces) {
		if(mset == nil) {
			mset = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
			[mset removeCharactersInString:@" "];
		}
		set = mset;
	}
    NSRange range = [str rangeOfCharacterFromSet:set];
    return range.length > 0;
}

BOOL StringContainsOnlyDigits(NSString* str) {
    NSCharacterSet* set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange range = [str rangeOfCharacterFromSet:set];
    return range.length == 0;
}

BOOL IsVisibleString(NSString* str) {
    NSUInteger strLen = [str length];
    if(strLen == 0) {
        return NO;
    } else {
        NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSRange range = [str rangeOfCharacterFromSet:set];
        return range.length != strLen;
    }
}

NSString* FormatInt(int i, int places, BOOL leadingZero) {
    if(leadingZero) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
        return [NSString stringWithFormat:[@"%0" stringByAppendingString:[NSString stringWithFormat:@"%dd", places]], i];
#pragma clang diagnostic pop
    } else {
        return [NSString stringWithFormat:@"%d", i];
    }
}

BOOL StringContainsString(NSString* str1, NSString* str2) {
    return [str1 rangeOfString:str2].location != NSNotFound;
}

BOOL StringBeginsWithString(NSString* str1, NSString* str2) {
	return [str1 rangeOfString:str2].location == 0;
}

BOOL CompleteString(NSString* partial, NSArray* completions, NSString** completed) {
    BOOL found = NO;
    
    for(NSUInteger i = 0; i < [completions count]; ++i) {
        NSString* completion = completions[i];
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

BOOL SearchAndReplace(NSString** destString, NSString* searchString, NSString* replaceString) {
    NSRange range = [*destString rangeOfString:searchString];
    if(range.length > 0) {
        *destString = [NSMutableString stringWithString:*destString];
        [(NSMutableString*)*destString replaceCharactersInRange:range withString:replaceString];
        return YES;
    } else {
        return NO;
    }
}

NSString* StringByDeletingRange(NSString* str, NSRange range) {
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
NSString* StringFromOSType(OSType osType) {
	return NSFileTypeForHFSTypeCode(osType);
}

OSType OSTypeFromString(NSString* osTypeString) {
	return NSHFSTypeCodeFromFileType(osTypeString);
}
#endif

NSString* StringByTruncatingString(NSString* string, NSUInteger maxCharacters) {
	NSString* resultString;
	if([string length] <= maxCharacters) {
		resultString = [string copy];
	} else {
		resultString = [string substringToIndex:maxCharacters];
	}
	return resultString;
}

NSString* StringByDuplicatingCharacter(unichar character, NSUInteger length) {
	unichar* buffer = (unichar*)malloc(length * sizeof(unichar));
	for(NSUInteger i = 0; i < length; ++i) {
		buffer[i] = character;
	}
	NSString* string = [NSString stringWithCharacters:buffer length:length];
	free(buffer);
	return string;
}

NSString* BulletStringForString(NSString* string) {
	return StringByDuplicatingCharacter(0x2022 /* unicode bullet */, [string length]);
}

#ifdef __cplusplus

NSString* ToCocoa(string const& s) {
	return @(s.c_str());
}

NSString* ToCocoa(string const* s, NSString* default_s) {
	if(s != NULL) {
		return ToCocoa(*s);
	} else {
		return default_s;
	}
}

string ToStd(NSString* s) {
	if(s == nil) {
		return string();
	} else {
		return string([s UTF8String]);
	}
}
#endif

@implementation NSString (CStringAdditions)

// From OmniFoundation
+ (NSString *)stringWithCharacter:(unichar)aCharacter {
    return [[NSString alloc] initWithCharacters:&aCharacter length:1];
}

// From OmniFoundation
+ (NSString *)horizontalEllipsisString {
    static NSString *string = nil;

    if (!string)
        string = [self stringWithCharacter:0x2026];

//    OBPOSTCONDITION(string);

    return string;
}

+ (NSString*)stringWithUUID {
	NSString* string = nil;
	
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	string = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	
	return string;
}

+ (NSString*)stringWithBase64UUIDURLSafe:(BOOL)URLSafe {
	NSString* result = nil;

	CFUUIDRef uuidObj = CFUUIDCreate(nil);

	CFUUIDBytes uuidBytes = CFUUIDGetUUIDBytes(uuidObj);
	NSData* data = [NSData dataWithBytes:&uuidBytes length:sizeof(CFUUIDBytes)];
	result = [NSString stringByBase64EncodingData:data URLSafe:URLSafe];
	result = [result substringToIndex:22]; // remove the "==" padding at the end

	CFRelease(uuidObj);

	return result;
}

+ (NSString*)stringWithASCIIData:(NSData*)data {
	return [self stringWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding {
	return [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:encoding];
}

+ (NSString*)stringWithCRLF {
	return @"\r\n";
}

+ (NSString*)stringWithComponents:(NSArray*)components separator:(NSString*)separator {
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

- (NSData*)dataUsingASCIIEncoding {
	return [self dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData*)dataUsingUTF8Encoding {
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray*)tokenize {
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

- (BOOL)matchesAllTokens:(NSArray*)tokens caseInsensitive:(BOOL)caseInsensitive {
	BOOL result = YES;

	NSUInteger tokenCount = [tokens count];
	NSUInteger searchOptions = caseInsensitive ? NSCaseInsensitiveSearch : 0;
	for(NSUInteger i = 0; i < tokenCount; ++i) {
		NSString* token = tokens[i];
		if([self rangeOfString:token options:searchOptions].location == NSNotFound) {
			result = NO;
			break;
		}
	}

	return result;
}

- (BOOL)matchesAnyTokens:(NSArray*)tokens caseInsensitive:(BOOL)caseInsensitive {
	BOOL result = NO;

	NSUInteger tokenCount = [tokens count];
	NSUInteger searchOptions = caseInsensitive ? NSCaseInsensitiveSearch : 0;
	for(NSUInteger i = 0; i < tokenCount; ++i) {
		NSString* token = tokens[i];
		if([self rangeOfString:token options:searchOptions].location != NSNotFound) {
			result = YES;
			break;
		}
	}

	return result;
}

- (NSString*)lastCharacters:(NSInteger)count {
	return [self substringFromIndex:self.length - count];
}

- (NSString*)lastCharacter {
	return [self lastCharacters:1];
}

- (NSString*)pathByRemovingLeadingSlash {
	NSString* result = self;
	
	if(self.length > 0) {
		if([[self substringToIndex:1] isEqualToString:@"/"]) {
			result = [self substringFromIndex:1];
		}
	}
	
	return result;
}

- (NSString*)stringByAddingPercentEscapes {
	NSString* s = nil;
	
	// KLUDGE: We pass a literal CFSTR for legalURLCharactersToBeEscaped to work around an Apple bug.
	s = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, CFSTR("!$&'()*+,-./:;=?@_~"), kCFStringEncodingUTF8);
	
	return s;
}

- (NSString*)stringByReplacingPercentEscapes {
	NSString* s = nil;
	
	s = (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL);
	
	return s;
}

- (NSString*)stringByReplacingTemplatesWithReplacements:(NSDictionary*)replacementsDict {
    NSMutableString* mutableStr = [self mutableCopy];
    
    NSError* error = nil;
    static NSRegularExpression *regex;
    if(regex == nil) {
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\{(.*?)\\}" options:0 error:&error];
    }
    NSInteger offset = 0;
    for(NSTextCheckingResult* result in [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)]) {
        NSRange resultRange = result.range;
        resultRange.location += offset;
        NSString* match = [regex replacementStringForResult:result inString:mutableStr offset:offset template:@"$1"];
        NSString* replacement = replacementsDict[match];
        [mutableStr replaceCharactersInRange:resultRange withString:replacement];
        offset = offset + replacement.length - resultRange.length;
    }
    
    return [NSString stringWithString:mutableStr];
}

- (NSArray*)capturesFromMatchesOfRegularExpression:(NSRegularExpression*)regex stopAfterFirstMatch:(BOOL)stopAfterFirstMatch stopAfterFirstCapture:(BOOL)stopAfterFirstCapture {
    __block NSMutableArray* capturesArray = nil;
    
    NSAssert1(regex.numberOfCaptureGroups > 0, @"Regular expression %@ must contain at least one capture group.", regex.pattern);
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        if(capturesArray == nil) capturesArray = [NSMutableArray new];
        
        for(NSUInteger captureIndex = 0; captureIndex < regex.numberOfCaptureGroups; captureIndex++) {
            NSRange captureRange = [result rangeAtIndex:(captureIndex + 1)];
            NSString* captureStr = @"";
            if(captureRange.location != NSNotFound) {
                captureStr = [self substringWithRange:captureRange];
            }
            [capturesArray addObject:captureStr];
            if(stopAfterFirstCapture) break;
        }
        
        if(stopAfterFirstMatch) *stop = YES;
    }];
    
    return [capturesArray copy];
}

- (NSArray*)allCapturesFromAllMatchesOfRegularExpression:(NSRegularExpression*)regex {
    return [self capturesFromMatchesOfRegularExpression:regex stopAfterFirstMatch:NO stopAfterFirstCapture:NO];
}

- (NSArray*)allCapturesFromFirstMatchOfRegularExpression:(NSRegularExpression*)regex {
    return [self capturesFromMatchesOfRegularExpression:regex stopAfterFirstMatch:YES stopAfterFirstCapture:NO];
}

- (NSString*)firstCaptureFromFirstMatchOfRegularExpression:(NSRegularExpression*)regex {
    NSArray* captures = [self capturesFromMatchesOfRegularExpression:regex stopAfterFirstMatch:YES stopAfterFirstCapture:YES];
    return captures.count > 0 ? captures[0] : nil;
}

- (BOOL)matchesRegularExpression:(NSRegularExpression *)regex {
    NSRange r = [regex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return r.location != NSNotFound;
}


- (NSArray*)allCharacters {
	NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:self.length];
	for (NSUInteger i=0; i < self.length; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [self characterAtIndex:i]];
		[characters addObject:ichar];
	}
	
	return [characters copy];
}

+ (NSString*)stringByBase64EncodingData:(NSData*)data URLSafe:(BOOL)URLSafe {
	static unsigned char *alphabetStandard = (unsigned char *)"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	static unsigned char *alphabetURLSafe = (unsigned char *)"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
	
	unsigned char* alphabet = URLSafe ? alphabetURLSafe : alphabetStandard;
	
	int encodedLength = (int)((4 * ((data.length / 3) + (1 - (3 - (data.length % 3)) / 3))) + 1);
	unsigned char *outputBuffer = (unsigned char *)malloc(encodedLength);
	unsigned char *inputBuffer = (unsigned char *)data.bytes;
	
	NSUInteger i;
	NSInteger j = 0;
	int remain;
	
	for(i = 0; i < data.length; i += 3) {  
		remain = (int)(data.length - i);
		
		outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];  
		outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |   
									 ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];  
		
		if(remain > 1)  
			outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)  
										 | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];  
		else   
			outputBuffer[j++] = '=';  
		
		if(remain > 2)  
			outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];  
		else  
			outputBuffer[j++] = '=';              
	}  
	
	outputBuffer[j] = 0;  
	
	NSString* result = @((const char*)outputBuffer);
	free(outputBuffer);
	
	return result;
}

- (NSString*)stringUsingBase64EncodingURLSafe:(BOOL)URLSafe {
	NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSString* result = [NSString stringByBase64EncodingData:data URLSafe:URLSafe];
    return result;  
}

- (NSString*)stringUsingBase64Encoding {
	return [self stringUsingBase64EncodingURLSafe:NO];
}

@end

@implementation NSAttributedString (CStringAdditions)

- (NSAttributedString *)stringByReplacingTemplatesWithReplacements:(NSDictionary*)replacementsDict attributes:(NSDictionary *)attributesDict {
    NSMutableAttributedString* mutableStr = [self mutableCopy];
    
    NSError* error = nil;
    static NSRegularExpression *regex;
    if(regex == nil) {
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\{(.*?)\\}" options:0 error:&error];
    }
    NSInteger offset = 0;
    for(NSTextCheckingResult* result in [regex matchesInString:self.string options:0 range:NSMakeRange(0, self.length)]) {
        NSRange resultRange = result.range;
        resultRange.location += offset;
        NSString* match = [regex replacementStringForResult:result inString:mutableStr.string offset:offset template:@"$1"];
        NSString* replacement = replacementsDict[match];
        NSDictionary *attributes = attributesDict[match];
        NSAttributedString *attributedReplacement = [[NSAttributedString alloc] initWithString:replacement attributes:attributes];
        [mutableStr replaceCharactersInRange:resultRange withAttributedString:attributedReplacement];
        offset = offset + replacement.length - resultRange.length;
    }
    
    return [mutableStr copy];
}

@end

@implementation NSRegularExpression (CRegularExpressionAdditions)

+ (NSRegularExpression*)newRegularExpressionWithPattern:(NSString *)pattern {
    return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
}

@end

NSString* StringFromBool(BOOL b, BOOL cStyle) {
	if(cStyle) {
		return b ? @"true" : @"false";
	} else {
		return b ? @"YES" : @"NO";
	}
}

NSString* StringFromObjectConvertingBool(id obj, BOOL cStyle) {
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

@property (nonatomic) NSMutableString* resultString;

@end


@implementation CEntitiesConverter

@synthesize resultString;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
        [self.resultString appendString:s];
}

- (NSString*)unescapeEntitiesInString:(NSString*)s {
	self.resultString = [NSMutableString string];
	
    NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
    NSData* data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[NSXMLParser alloc] initWithData:data];
    [xmlParse setDelegate:self];
    [xmlParse parse];
    return [NSString stringWithString:self.resultString];
}

- (void)dealloc {
    self.resultString = nil;
}

@end

NSString* StringByNormalizingToSearchableCharacters(NSString *s) {
    static NSCharacterSet *unacceptableCharacters;
    if(unacceptableCharacters == nil) {
        NSMutableCharacterSet *acceptedCharacters = [NSMutableCharacterSet new];
        [acceptedCharacters formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
        [acceptedCharacters formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        [acceptedCharacters addCharactersInString:@" -_!?."];
        unacceptableCharacters = [[acceptedCharacters invertedSet] copy];
    }

    // Turn accented letters into normal letters
    NSData *sanitizedData = [s dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    // Corrected back-conversion from NSData to NSString
    NSString *sanitizedText = [[NSString alloc] initWithData:sanitizedData encoding:NSASCIIStringEncoding];
    
    // Remove unaccepted characters
    NSString *acceptedCharacters = [[sanitizedText componentsSeparatedByCharactersInSet:unacceptableCharacters] componentsJoinedByString:@""];

    NSString *result = [acceptedCharacters lowercaseString];
    
    return result;
}

NSRegularExpression* RegularExpressionForMatchingAllTokens(NSString *s) {
    NSString *normalizedString = StringByNormalizingToSearchableCharacters(s);
    NSArray *unfilteredTokens = [normalizedString componentsSeparatedByString:@" "];
    NSMutableString *regexString = [NSMutableString new];
    [unfilteredTokens enumerateObjectsUsingBlock:^(NSString *unescapedToken, NSUInteger idx, BOOL *stop) {
        if(!IsEmptyString(unescapedToken)) {
            NSString *token = [NSRegularExpression escapedPatternForString:unescapedToken];
            [regexString appendString:[NSString stringWithFormat:@"(?=.*\\b%@)", token]];
        }
    }];
    NSRegularExpression *regex = [NSRegularExpression newRegularExpressionWithPattern:regexString];
    return regex;
}

NSString* StringByUnescapingEntitiesInString(NSString* s) {
	CEntitiesConverter* converter = [CEntitiesConverter new];
	
	return [converter unescapeEntitiesInString:s];
}

// This function only unescapes "&lt;", "&gt;" and "&amp;" and does not gag on a naked "&",
// unlike StringByUnescapingEntitiesInString.

NSString* StringByUnescapingMinimalEntitiesInUncleanString(NSString* s) {
	if ([s rangeOfString:@"&"].location == NSNotFound) return s;

	s = [s stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	s = [s stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	return [s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}

NSString* StringByJoiningNonemptyStringsWithString(NSArray* strings, NSString* separator) {
	NSMutableArray* a = [NSMutableArray arrayWithCapacity:strings.count];
	for(NSString* s in strings) {
		if(!IsEmptyString(s)) {
			[a addObject:s];
		}
	}
	return [a componentsJoinedByString:separator];
}

NSString* StringByJoiningNonemptyDescriptionsWithString(NSArray* items, NSString* separator) {
	NSMutableArray* a = [NSMutableArray arrayWithCapacity:items.count];
	for(NSString* s in items) {
		NSString* d = [s description];
		if(!IsEmptyString(d)) {
			[a addObject:d];
		}
	}
	return [a componentsJoinedByString:separator];
}

NSString* StringByCapitalizingFirstCharacter(NSString* s) {
	if(s == nil) return nil;
	else if(s.length == 0) return s;
	else if(s.length == 1) return [s uppercaseString];
	else {
		return [NSString stringWithFormat:@"%@%@", [[s substringToIndex:1] uppercaseString], [s substringFromIndex:1]];
	}
}

#if 0
void StringByTrimmingWhitespaceFromEndTest() {
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

NSString* StringByTrimmingWhitespaceFromEnd(NSString* s) {
	NSString* result = s;
	
	NSRange r = [s rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] options:NSBackwardsSearch];
	if(r.location != NSNotFound) {
		result = [s substringToIndex:r.location + 1];
	}

	return result;
}

NSString* LastWordOfString(NSString* s) {
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

NSString* StringByRemovingLastWordOfString(NSString* s) {
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

NSString* StringByEscapingQuotesAndBackslashes(NSString* s) {
	NSScanner* source = [NSScanner scannerWithString:s];
	[source setCharactersToBeSkipped:nil];

	NSMutableString* sink = [NSMutableString string];

	NSCharacterSet* charactersToEscape = [NSCharacterSet characterSetWithCharactersInString:@"\"\\"];
	BOOL scanningForCharactersToEscape = NO;
	while(![source isAtEnd]) {
		NSString* scannedCharacters;

		if(scanningForCharactersToEscape) {
			if([source scanCharactersFromSet:charactersToEscape intoString:&scannedCharacters]) {
				for(NSUInteger i = 0; i < scannedCharacters.length; i++) {
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

NSString* StringBySurroundingStringWithQuotes(NSString* s, BOOL onlyIfNecessary) {
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

NSString* StringByLimitingLengthOfString(NSString* s, NSUInteger maxLength, BOOL addEllipsis) {
	if(maxLength != NSUIntegerMax) {
		NSInteger mLength = maxLength;
		if(addEllipsis) {
			mLength -= 3;
			if(mLength < 0) mLength = 0;
		}
		if(s.length > (NSUInteger)mLength) {
			s = [s substringToIndex:mLength];
			if(addEllipsis) {
				s = [s stringByAppendingString:@"..."];
			}
		}
	}
	return s;
}

NSString* StringByRemovingWhitespaceAndNewLines(NSString* string) {
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
}

NSString* StringWithURLEscapedParamaters(NSDictionary* params) {
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

NSDictionary* DictionaryFromStringWithKeyValuePairs(NSString* string, NSString* recordSeparator, NSString* keyValueSeparator) {
	NSArray* records = [string componentsSeparatedByString:recordSeparator];
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:records.count];
	for(NSString* record in records) {
		NSArray* components = [record componentsSeparatedByString:keyValueSeparator];
		NSString* key = components[0];
		NSString* value = components[1];
		dict[key] = value;
	}
	return [dict copy];
}
