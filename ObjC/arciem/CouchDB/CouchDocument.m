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

@implementation CouchDocument

@synthesize dict = dict_;
@dynamic _id;
@dynamic _rev;

- (id)initWithMutableDictionary:(NSMutableDictionary*)dict
{
	if((self = [super init])) {
		self.dict = dict;
	}
	
	return self;
}

+ (CouchDocument*)documentWithMutableDictionary:(NSMutableDictionary*)dict
{
	return [[[self alloc] initWithMutableDictionary:dict] autorelease];
}

- (void)dealloc
{
	[self setPropertiesToNil];
	[super dealloc];
}

- (NSMutableString*)_id
{
	return [self.dict objectForKey:@"_id"];
}

- (void)set_id:(NSString*)_id
{
	[self.dict setObject:[[_id mutableCopy] autorelease] forKey:@"_id"];
}

- (NSMutableString*)_rev
{
	return [self.dict objectForKey:@"_rev"];
}

- (void)set_rev:(NSString*)_rev
{
	[self.dict setObject:[[_rev mutableCopy] autorelease] forKey:@"_rev"];
}

- (id)valueForUndefinedKey:(NSString*)key
{
	id value = [self.dict objectForKey:key];
	if(value == nil) {
		[super valueForUndefinedKey:key];
	}
	return value;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	[self.dict setObject:value forKey:key];
}

@end
