/*******************************************************************************
 
 Copyright 2014 Arciem LLC
 
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

@interface Canceler : NSObject
@property (readonly, nonatomic) BOOL canceled;
- (void)cancel;
@end

typedef dispatch_block_t DispatchBlock;
typedef dispatch_queue_t DispatchQueue;

typedef void (^CancelableBlock)(Canceler *);
typedef void (^ErrorBlock)(NSError *);

DispatchQueue mainQueue();
DispatchQueue backgroundQueue();

dispatch_time_t dispatchTimeSinceNow(NSTimeInterval offsetInSeconds);
void dispatchSyncOnQueue(DispatchQueue queue, DispatchBlock f);
void dispatchSyncOnMain(DispatchBlock f);
void dispatchOnQueue(DispatchQueue queue, DispatchBlock f);
void dispatchOnMain(DispatchBlock f);
void dispatchOnBackground(DispatchBlock f);
Canceler* dispatchOnQueueAfter(DispatchQueue queue, NSTimeInterval delayInSeconds, DispatchBlock f);
Canceler* dispatchOnMainAfter(NSTimeInterval delayInSeconds, DispatchBlock f);
Canceler* dispatchOnBackgroundAfter(NSTimeInterval delayInSeconds, DispatchBlock f);
Canceler* dispatchRepeatedOnQueue(DispatchQueue queue, NSTimeInterval interval, CancelableBlock f);
Canceler* dispatchRepeatedOnMain(NSTimeInterval interval, CancelableBlock f);
Canceler* dispatchRepeatedOnBackground(NSTimeInterval interval, CancelableBlock f);