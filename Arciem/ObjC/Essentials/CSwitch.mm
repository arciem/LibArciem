/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CSwitch.h"

@interface CSwitch ()

@property (strong, nonatomic) NSMutableDictionary* dict;

@end

@implementation CSwitch

@synthesize dict = dict_;

- (id)initWithFirstKey:(id)firstKey args:(va_list)args
{
	if(self = [super init]) {
		self.dict = [NSMutableDictionary dictionary];
		for (id key = firstKey; key != nil; key = va_arg(args, id)) {
			id block = [va_arg(args, id) copy];
			(self.dict)[key] = block;
		}
	}
	
	return self;
}

- (id)initWithKeysAndBlocks:(id)firstKey, ...
{
	va_list args;
	va_start(args, firstKey);
	self = [self initWithFirstKey:firstKey args:args];
	va_end(args);
	
	return self;
}

+ (CSwitch*)switchWithKeysAndBlocks:(id)firstKey, ...
{
	CSwitch* result = nil;
	
	va_list args;
	va_start(args, firstKey);
	result = [[self alloc] initWithFirstKey:firstKey args:args];
	va_end(args);
	
	return result;
}

- (id)switchOnKey:(id)key withArg:(id)arg
{
	id result = nil;
	
	id (^bl)(id) = (self.dict)[key];
	if(bl == NULL) {
		bl = (self.dict)[[NSNull null]];
	}
	if(bl != NULL) {
		result = bl(arg);
	}
	
	return result;
}

- (id)switchOnKey:(id)key
{
	return [self switchOnKey:key withArg:nil];
}

@end
