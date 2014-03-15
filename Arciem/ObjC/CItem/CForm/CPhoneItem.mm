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

#import "CPhoneItem.h"

@implementation CPhoneItem

- (void)setup
{
	[super setup];
	self.validCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	self.keyboardType = @"phonePad";
}

- (NSString*)formatCharacterCount:(NSUInteger)count
{
    NSString* result;
    if(count == 1) {
        result = [NSString stringWithFormat:@"%lu digit", (unsigned long)count];
    } else {
        result = [NSString stringWithFormat:@"%lu digits", (unsigned long)count];
    }
    return result;
}

@end
