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

#import <Foundation/Foundation.h>

@interface NSThread (BlocksAdditions)

- (void)performBlock:(void (^)(void))block;
- (void)performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait;
- (void)performBlock:(void (^)(BOOL* stop))block repeatInterval:(NSTimeInterval)repeatInterval;
+ (void)performBlockInBackground:(void (^)(void))block;
+ (void)performBlockOnMainThread:(void (^)(void))block;
+ (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
+ (void)performBlockOnMainThread:(void (^)(BOOL* stop))block repeatInterval:(NSTimeInterval)repeatInterval;
+ (void)chainBlock:(void(^)(NSCondition*))block1 toBlock:(void(^)(void))block2;

@end
