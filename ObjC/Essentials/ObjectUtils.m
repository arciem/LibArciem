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

#import "ObjectUtils.h"
#import "StringUtils.h"
#import "PropertyUtils.h"
#import <objc/runtime.h>

BOOL IsNull(id a)
{
	return a == nil || a == [NSNull null];
}

id Denull(id a)
{
	return a == [NSNull null] ? nil : a;
}

id Ennull(id a)
{
	return a == nil ? [NSNull null] : a;
}

BOOL Same(id a, id b)
{
	if(a == b) return YES;
	if(a == nil || b == nil) return NO;
	return [a isEqual:b];
}

BOOL Different(id a, id b)
{
	if(a == b) return NO;
	if(a == nil || b == nil) return YES;
	return ![a isEqual:b];
}

// For container classes that implement -count, e.g. NSArray, NSDictionary, NSSet, NSIndexSet.
BOOL IsEmpty(id a)
{
	return [Denull(a) count] == 0;
}

void Switch(id key, NSDictionary* dict)
{
	@autoreleasepool {
		void (^bl)(void) = [dict objectForKey:key];
		if(bl == NULL) {
			bl = [dict objectForKey:[NSNull null]];
		}
//		CLogDebug(nil, @"Switch key:%@ block:%@", key, bl);
		if(bl != NULL) {
			bl();
		}
	}
}

id<NSObject> ClassAlloc(NSString* className)
{
	id instance = nil;
	
	Class cls = NSClassFromString(className);
	NSCAssert1(cls != nil, @"No class named:%@", className);
	instance = [cls alloc];
	
	return instance;
}

@implementation NSObject (ObjectUtils)

- (NSString*)formatKey:(NSString*)key value:(id)value compact:(BOOL)compact
{
	NSString* result = @"";
	NSUInteger kMaxCompactStringLength = 30;
	
	if(value != nil) {
		NSString* valueStr = nil;
		if([value isKindOfClass:[NSString class]]) {
			valueStr = StringByLimitingLengthOfString([value description], compact ? kMaxCompactStringLength : NSUIntegerMax, YES);
			valueStr = StringBySurroundingStringWithQuotes(valueStr, YES);
		} else if(value == (id)kCFBooleanTrue) {
			valueStr = @"YES";
		} else if(value == (id)kCFBooleanFalse) {
			valueStr = @"NO";
		} else if([value isKindOfClass:[NSNumber class]]) {
			valueStr = [value description];
		} else if([value isKindOfClass:[NSArray class]]) {
			if(compact) {
				NSArray* array = (NSArray*)value;
				valueStr = [NSString stringWithFormat:@"<%@: %p, count:%d>", [array class], array, array.count];
			} else {
				valueStr = [value description];
			}
		} else if([value isKindOfClass:[NSDictionary class]]) {
			if(compact) {
				NSMutableString* buf = [NSMutableString stringWithString:@"{ "];
				NSDictionary* dict = (NSDictionary*)value;
				
				for(NSString* key in [dict allKeys]) {
					[buf appendFormat:@"%@ ", [dict formatValueForKey:key compact:YES]];
				}
				
				[buf appendString:@"}"];
				
				valueStr = [NSString stringWithString:buf];
			} else {
				valueStr = [value description];
			}
		} else if([value isKindOfClass:[NSError class]]) {
			if(compact) {
				NSError* error = (NSError*)value;
				NSString* message = error.localizedDescription;
				message = StringByLimitingLengthOfString(message, compact ? kMaxCompactStringLength : NSUIntegerMax, YES);
				message = StringBySurroundingStringWithQuotes(message, YES);
				valueStr = [NSString stringWithFormat:@"<%@: %p, %@ %d %@>", [value class], value, error.domain, error.code, message];
			} else {
				value = [value description];
			}
		} else {
			if(compact) {
				valueStr = [NSString stringWithFormat:@"<%@: %p>", [value class], value];
			} else {
				valueStr = [value description];
			}
		}
		result = [NSString stringWithFormat:@"%@:%@", key, valueStr];
	}
	
	return result;
}

- (NSString*)formatValueForKey:(NSString*)key compact:(BOOL)compact
{
	return [self formatKey:key value:[self valueForKey:key] compact:compact];
}

- (NSString*)formatBoolValueForKey:(NSString*)key compact:(BOOL)compact
{
	id value = (id)([[self valueForKey:key] boolValue] ? kCFBooleanTrue : kCFBooleanFalse);
	return [self formatKey:key value:value compact:compact];
}

- (NSString*)formatBoolValueForKey:(NSString*)key compact:(BOOL)compact hidingIf:(BOOL)hideValue
{
	NSString* result = @"";
	
	BOOL boolValue = [[self valueForKey:key] boolValue];
	
	if(boolValue != hideValue) {
		id value = (id)([[self valueForKey:key] boolValue] ? kCFBooleanTrue : kCFBooleanFalse);
		result = [self formatKey:key value:value compact:compact];
	}
	
	return result;
}

- (NSString*)formatObjectWithValues:(NSArray*)values
{
	NSString* s = nil;
	NSString* o = [NSString stringWithFormat:@"%@:%p", [self class], self];
	NSString* a = nil;
	if(values.count > 0) {
		NSArray* v = [[NSArray arrayWithObject:o] arrayByAddingObjectsFromArray:values];
		a = StringByJoiningNonemptyStringsWithString(v, @"; ");
	} else {
		a = o;
	}
	s = [NSString stringWithFormat:@"<%@>", a];
	return s;
}

- (void)setPropertiesToNil
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(unsigned int i = 0; i < outCount; i++) {
        objc_property_t raw_property = properties[i];
        const char *propName = property_getName(raw_property);
        if(propName && IsPropertyAWritableObject(raw_property)) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
			[self setValue:nil forKey:propertyName];
        }
    }
    free(properties);
}

- (void)setAssociatedObject:(id)obj forKey:(NSString*)key
{
	objc_setAssociatedObject(self, (__bridge void*)key, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObjectForKey:(NSString*)key
{
	return objc_getAssociatedObject(self, (__bridge void*)key);
}

@end

@implementation NSDictionary (ObjectUtils)

+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ... {
	va_list args;
    va_start(args, firstKey);
	NSMutableArray* keys = [NSMutableArray array];
	NSMutableArray* values = [NSMutableArray array];
    for (id key = firstKey; key != nil; key = va_arg(args, id)) {
		id value = va_arg(args, id);
        [keys addObject:key];
		[values addObject:value];		
    }
    va_end(args);
    
    return [self dictionaryWithObjects:values forKeys:keys];
}

- (id)valueForKey:(NSString*)key defaultValue:(id)defaultValue
{
	id result = [self objectForKey:key];
	if(result == nil) {
		result = defaultValue;
	}
	return result;
}

- (NSUInteger)unsignedIntegerValueForKey:(NSString*)key defaultValue:(NSUInteger)defaultValue
{
	return [[self valueForKey:key defaultValue:[NSNumber numberWithUnsignedInt:defaultValue]] unsignedIntegerValue];
}

- (NSString*)stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue
{
	return [self valueForKey:key defaultValue:defaultValue];
}

@end

@implementation NSMutableDictionary (ObjectUtils)

- (void)overrideWithValuesFromDictionary:(NSDictionary*)dict
{
	for(id key in dict) {
		if([self objectForKey:key] == nil) {
			[self setObject:[[dict objectForKey:key] copy] forKey:key];
		}
	}
}

@end
