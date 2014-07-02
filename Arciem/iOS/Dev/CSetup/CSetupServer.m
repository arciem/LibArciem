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

#import "CSetupServer.h"

@implementation CSetupServer

@synthesize name = name_;
@synthesize baseURL = baseURL_;
@dynamic propertyListRepresentation;

- (instancetype)init
{
	if(self = [super init]) {
		
	}
	
	return self;
}

- (instancetype)initWithName:(NSString*)name baseURL:(NSURL*)baseURL
{
	if(self = [self init]) {
		self.name = name;
		self.baseURL = baseURL;
	}
	return self;
}

- (instancetype)initWithName:(NSString *)name baseURLString:(NSString*)baseURLString
{
	if(self = [self initWithName:name baseURL:[NSURL URLWithString:baseURLString]]) {
	}
	return self;
}

- (instancetype)initWithPropertyListRepresentation:(id)propertyList
{
	if(self = [self init]) {
		self.name = propertyList[@"name"];
		self.baseURL = [NSKeyedUnarchiver unarchiveObjectWithData:propertyList[@"baseURLData"]];
	}
	
	return self;
}

+ (CSetupServer*)serverWithName:(NSString*)name baseURLString:(NSString*)baseURLString
{
	return [[self alloc] initWithName:name baseURLString:baseURLString];
}

- (id)copyWithZone:(NSZone *)zone
{
	CSetupServer* c = [[[self class] allocWithZone:zone] init];
	c.name = self.name;
	c.baseURL = self.baseURL;
	return c;
}

- (id)propertyListRepresentation
{
	return @{@"name": self.name,
			@"baseURLData": [NSKeyedArchiver archivedDataWithRootObject:self.baseURL]};
}

@end
