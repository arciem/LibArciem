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

#import "CouchDocument.h"
#import "ObjectUtils.h"
#import "JSON.h"

@implementation CouchDocument

@synthesize dict = dict_;

- (id)initWithMutableDictionary:(NSMutableDictionary*)dict
{
	if((self = [super init])) {
		self.dict = dict;
	}
	
	return self;
}

- (id)init
{
	return [self initWithMutableDictionary:[NSMutableDictionary dictionary]];
}

+ (CouchDocument*)documentWithMutableDictionary:(NSMutableDictionary*)dict
{
	return [[[self alloc] initWithMutableDictionary:dict] autorelease];
}

+ (CouchDocument*)document
{
	return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
	[self setPropertiesToNil];
	[super dealloc];
}

- (NSString*)_id
{
	return [self valueForUndefinedKey:@"_id"];
}

- (void)set_id:(NSString*)_id
{
	[self setValue:_id forUndefinedKey:@"_id"];
}

- (NSString*)_rev
{
	return [self valueForUndefinedKey:@"_rev"];
}

- (void)set_rev:(NSString*)_rev
{
	[self setValue:_rev forUndefinedKey:@"_rev"];
}

- (id)valueForUndefinedKey:(NSString*)key
{
	return [self.dict objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	value = Ennull(value);
	[self.dict setObject:value forKey:key];
}

- (void)removeValueForKey:(NSString*)key
{
	[self.dict removeObjectForKey:key];
}

- (NSString*)HTTPHeaderValueForContentType
{
	return @"application/json";
}

- (NSData*)HTTPBody
{
	NSString* str = [self.dict JSONRepresentation];
	NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
	return data;
}

@end
