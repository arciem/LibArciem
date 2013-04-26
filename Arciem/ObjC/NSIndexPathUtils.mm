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

#import "NSIndexPathUtils.h"


@implementation NSIndexPath (NSIndexPathUtils)

@dynamic column;

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row inColumn:(NSUInteger)column
{
	NSUInteger indexes[] = {column, row};
	return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (NSUInteger)row
{
	return [self indexAtPosition:1];
}

- (NSUInteger)column
{
	return [self indexAtPosition:0];
}

@end
