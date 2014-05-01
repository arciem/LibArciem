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

void dispatch_async_repeated(double intervalInSeconds, dispatch_queue_t queue, void(^work)(BOOL *stop))
{
    __block BOOL shouldStop = NO;
    dispatch_time_t nextPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(intervalInSeconds * NSEC_PER_SEC));
    dispatch_after(nextPopTime, queue, ^{
        work(&shouldStop);
        if(!shouldStop) {
            dispatch_async_repeated(intervalInSeconds, queue, work);
        }
    });
}

@implementation NSThread (BlocksAdditions)

- (void)performBlock:(dispatch_block_t)block
{
	if ([[NSThread currentThread] isEqual:self]) {
		block();
	} else {
		[self performBlock:block waitUntilDone:NO];
	}
}

- (void)performBlock:(dispatch_block_t)block waitUntilDone:(BOOL)wait
{
    [NSThread performSelector:@selector(ng_runBlock:)
                     onThread:self
                   withObject:[block copy]
                waitUntilDone:wait];
}

- (void)performBlock:(void (^)(BOOL* stop))block queue:(dispatch_queue_t)queue repeatInterval:(NSTimeInterval)repeatInterval
{
    dispatch_async_repeated(repeatInterval, queue, block);
}

+ (void)performBlockOnMainThread:(void (^)(BOOL* stop))block repeatInterval:(NSTimeInterval)repeatInterval
{
    dispatch_async_repeated(repeatInterval, dispatch_get_main_queue(), block);
}

+ (void)ng_runBlock:(dispatch_block_t)block
{
	block();
}

+ (void)performBlockInBackground:(dispatch_block_t)block
{
	[self performSelectorInBackground:@selector(ng_runBlock:)
	                           withObject:[block copy]];
}

+ (void)performBlockOnMainThread:(dispatch_block_t)block
{
	if([[self currentThread] isEqual:[self mainThread]]) {
		block();
	} else {
		[[NSOperationQueue mainQueue] addOperationWithBlock:block];
	}
}

+ (void)performBlockOnMainThread:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay
{
	int64_t delta = (int64_t)(1.0e9 * delay);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

+ (void)chainBlock:(void(^)(NSCondition*))block1 toBlock:(void(^)(void))block2
{
	NSCondition* condition = [NSCondition new];
	
	[self performBlockOnMainThread:^{
		block1(condition);
	}];
	
	[self performBlockInBackground:^{
		@autoreleasepool {
			[condition lock];
			[condition wait];
			[condition unlock];
			
			[self performBlockOnMainThread:^{
				block2();
			}];
		}
	}];
}

@end


@implementation NSOperationQueue (BlocksAdditions)

- (void)performSynchronousOperationWithBlock:(dispatch_block_t)block {
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:block];
    [self addOperations:@[op] waitUntilFinished:YES];
}

@end