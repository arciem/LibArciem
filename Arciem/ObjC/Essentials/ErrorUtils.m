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

#import "ErrorUtils.h"
#import "ObjectUtils.h"

@implementation NSError (ErrorUtils)

- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString*)localizedDescription
{
	NSDictionary* userInfo = @{NSLocalizedDescriptionKey: localizedDescription};

	return [self initWithDomain:domain code:code userInfo:userInfo];
}

- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code localizedFormat:(NSString *)localizedFormat arguments:(va_list)argList
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
	NSString* localizedDescription = [[NSString alloc] initWithFormat:localizedFormat locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] arguments:argList];
#pragma clang diagnostic pop
	
	return [self initWithDomain:domain code:code localizedDescription:localizedDescription];
}

- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code localizedFormat:(NSString *)localizedFormat, ...
{
	va_list argList;
	va_start(argList, localizedFormat);
	
	return [self initWithDomain:domain code:code localizedFormat:localizedFormat arguments:argList];
}

+ (NSError*)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString*)localizedDescription
{
	return [[self alloc] initWithDomain:domain code:code localizedDescription:localizedDescription];
}

+ (NSError*)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedFormat:(NSString *)localizedFormat arguments:(va_list)argList
{
	return [[self alloc] initWithDomain:domain code:code localizedFormat:localizedFormat arguments:argList];
}

+ (NSError*)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedFormat:(NSString *)localizedFormat, ...
{
	va_list argList;
	va_start(argList, localizedFormat);
	
	return [[self alloc] initWithDomain:domain code:code localizedFormat:localizedFormat arguments:argList];
}

@end
