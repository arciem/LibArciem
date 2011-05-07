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

#import "CouchError.h"

NSString* const CouchErrorDomain = @"CouchErrorDomain";
NSString* const CouchErrorName = @"CouchErrorName";
NSString* const CouchErrorReason = @"CouchErrorReason";

@implementation NSError (CouchError)

- (BOOL)isCouchError
{
	return [self.domain isEqualToString:CouchErrorDomain];
}

- (NSString*)errorName
{
	return [self.userInfo objectForKey:CouchErrorName];
}

- (NSString*)errorReason
{
	return [self.userInfo objectForKey:CouchErrorReason];
}

- (BOOL)serverGone
{
	return [self.domain isEqualToString:NSURLErrorDomain] && self.code == -1004;
}

- (BOOL)notFound
{
	return self.isCouchError && self.code == 404;
}

- (BOOL)missing
{
	return self.notFound && [self.errorReason isEqualToString:@"missing"];
}

- (BOOL)deleted
{
	return self.notFound && [self.errorReason isEqualToString:@"deleted"];
}

- (BOOL)noDBFile
{
	return self.notFound && [self.errorReason isEqualToString:@"no_db_file"];
}

- (BOOL)conflict
{
	return self.isCouchError && self.code == 409;
}

@end
