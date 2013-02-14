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

#import "CDebugAnnotation.h"
#import "StringUtils.h"

@implementation CDebugAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;

- (NSString*)title
{
	NSString* result = title_;
	
	if(IsEmptyString(result)) {
		result = @"➤"; // a nil or empty string results in no callout, so provide a default title
	}
	
	return result;
}

@end
