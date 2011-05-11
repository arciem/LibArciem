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

#import "ThreadUtils.h"

@implementation NSThread (BlocksAdditions)

- (void)performBlock:(void (^)())block
{
	if ([[NSThread currentThread] isEqual:self]) {
		block();
	} else {
		[self performBlock:block waitUntilDone:NO];
	}
}

- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait
{
    [NSThread performSelector:@selector(ng_runBlock:)
                     onThread:self
                   withObject:[[block copy] autorelease]
                waitUntilDone:wait];
}

+ (void)ng_runBlock:(void (^)())block
{
	block();
}

+ (void)performBlockInBackground:(void (^)())block
{
	[self performSelectorInBackground:@selector(ng_runBlock:)
	                           withObject:[[block copy] autorelease]];
}

+ (void)performBlockOnMainThread:(void (^)())block
{
	if([[self currentThread] isEqual:[self mainThread]]) {
		block();
	} else {
		[[NSOperationQueue mainQueue] addOperationWithBlock:block];
	}
}

+ (void)chainBlock:(void(^)(NSCondition*))block1 toBlock:(void(^)(void))block2
{
	NSCondition* condition = [[NSCondition alloc] init];
	
	[self performBlockOnMainThread:^{
		block1(condition);
	}];
	
	[self performBlockInBackground:^{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		[condition lock];
		[condition wait];
		[condition unlock];
		
		[self performBlockOnMainThread:^{
			block2();
		}];
		
		[pool release];
		[condition release];
	}];
}

@end
