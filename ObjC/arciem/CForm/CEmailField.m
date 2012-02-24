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

#import "CEmailField.h"
#import "StringUtils.h"
#import "ErrorUtils.h"

// See http://www.regular-expressions.info/email.html
static NSString* const kEmailRegularExpression = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";

NSString* const CEmailFieldErrorDomain = @"CEmailFieldErrorDomain";

@implementation CEmailField

- (void)setup
{
	[super setup];
}

- (void)validateSuccess:(void (^)(CFieldState))success failure:(void (^)(NSError *))failure
{
	[super validateSuccess:^(CFieldState state) {
		if(state == CFieldStateValid) {
			NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch | NSRegularExpressionSearch;
			NSRange range = [self.stringValue rangeOfString:kEmailRegularExpression options:options];
			if(range.location != NSNotFound) {
				success(state);
			} else {
				failure([NSError errorWithDomain:CEmailFieldErrorDomain code:CEmailFieldErrorInvalidAddress localizedDescription:@"Invalid e-mail address."]);
			}
		}
	} failure:^(NSError* error) {
		failure(error);
	}];
}

@end
