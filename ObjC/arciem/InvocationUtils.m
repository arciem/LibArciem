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

#import "InvocationUtils.h"

@implementation NSInvocation (InvocationUtils)

+ (NSInvocation*)invocationForTarget:(id)target selector:(SEL)selector argument1:(id)argument1 argument2:(id)argument2
{
	NSInvocation* invocation = nil;
	
	if(target != nil && selector != nil) {
		NSMethodSignature* signature = [target methodSignatureForSelector:selector];
		invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setTarget:target];
		[invocation setSelector:selector];
		if([signature numberOfArguments] >= 3) {
			[invocation setArgument:&argument1 atIndex:2];
			if([signature numberOfArguments] == 4) {
				[invocation setArgument:&argument2 atIndex:3];
			}
		}
		[invocation retainArguments];
	}
	
	return invocation;
}

+ (NSInvocation*)invocationForTarget:(id)target selector:(SEL)selector
{
	return [NSInvocation invocationForTarget:target selector:selector argument:NULL];
}

+ (NSInvocation*)invocationForTarget:(id)target selector:(SEL)selector argument:(id)argument
{
	return [NSInvocation invocationForTarget:target selector:selector argument1:argument argument2:NULL];
}

@end
