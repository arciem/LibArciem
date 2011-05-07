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

#import "CouchUtils.h"

void CouchCheckDatabaseName(NSString* databaseName)
{
	static NSRegularExpression* regex = nil;
	if(regex == nil) {
		regex = [[NSRegularExpression alloc] initWithPattern:@"^[a-z][a-z0-9()_$+-]*$" options:0 error:nil];
	}
	BOOL valid = [regex numberOfMatchesInString:databaseName options:regex.options range:NSMakeRange(0, databaseName.length)] == 1;
	NSCAssert1(valid, @"Invalid database name: %@", databaseName);
}
