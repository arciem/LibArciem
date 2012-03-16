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

BOOL IsNull(id a);
id Denull(id a);
id Ennull(id a);
BOOL Same(id a, id b);
BOOL Different(id a, id b);
BOOL IsEmpty(id a);

// This procedure implements a switch-type statement on an NSDictionary with comparable keys and values that are void-void blocks. If no matching key is found, an attempt is made to find and execute a "default" block whose key is [NSNull null].
void Switch(id key, NSDictionary* dict);

id<NSObject> ClassAlloc(NSString* className);

@interface NSObject (ObjectUtils)

- (NSString*)formatValueForKey:(NSString*)key compact:(BOOL)compact;
- (NSString*)formatKey:(NSString*)key value:(id)value compact:(BOOL)compact;
- (NSString*)formatBoolValueForKey:(NSString*)key compact:(BOOL)compact;
- (NSString*)formatBoolValueForKey:(NSString*)key compact:(BOOL)compact hidingIf:(BOOL)hideValue;
- (NSString*)formatObjectWithValues:(NSArray*)values;

- (void)setPropertiesToNil;

#if 0
- (void)setAssociatedObject:(id)obj forKey:(NSString*)key;
- (id)associatedObjectForKey:(NSString*)key;
#endif

@end

@interface NSDictionary (ObjectUtils)

// Creates and initializes a dictionary with key value pairs, with the keys specified first instead of the objects.
+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (NSUInteger)unsignedIntegerValueForKey:(id)key defaultValue:(NSUInteger)defaultValue;

@end

@interface NSMutableDictionary (ObjectUtils)

- (void)overrideWithValuesFromDictionary:(NSDictionary*)dict;

@end