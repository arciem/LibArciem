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

#import "DispatchUtils.h"

@interface Canceler ()
@property (readwrite, nonatomic) BOOL canceled;
@end

@implementation Canceler
- (void)cancel {
    self.canceled = YES;
}
@end

DispatchQueue mainQueue() {
    return dispatch_get_main_queue();
}

DispatchQueue backgroundQueue() {
    static DispatchQueue instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = dispatch_queue_create("background", DISPATCH_QUEUE_CONCURRENT);
    });
    return instance;
}


dispatch_time_t dispatchTimeSinceNow(NSTimeInterval offsetInSeconds) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(offsetInSeconds * NSEC_PER_SEC));
}

void dispatchSyncOnQueue(DispatchQueue queue, DispatchBlock f) {
    if(queue != nil) {
        dispatch_sync(queue, f);
    }
}

void dispatchSyncOnMain(DispatchBlock f) {
    dispatchSyncOnQueue(mainQueue(), f);
}

void dispatchOnQueue(DispatchQueue queue, DispatchBlock f) {
    if(queue != nil) {
        dispatch_async(queue, f);
    }
}

void dispatchOnMain(DispatchBlock f) {
    dispatchOnQueue(mainQueue(), f);
}

void dispatchOnBackground(DispatchBlock f) {
    dispatchOnQueue(backgroundQueue(), f);
}

void _dispatchOnQueue(DispatchQueue queue, NSTimeInterval delayInSeconds, Canceler *canceler, CancelableBlock f) {
    dispatch_after(dispatchTimeSinceNow(delayInSeconds), queue, ^{
        f(canceler);
    });
}

Canceler* dispatchOnQueue(DispatchQueue queue, NSTimeInterval delayInSeconds, DispatchBlock f) {
    Canceler* canceler = [Canceler new];
    CancelableBlock b = ^(Canceler *canceler) {
        if(!canceler.canceled) {
            f();
        }
    };
    _dispatchOnQueue(queue, delayInSeconds, canceler, b);
    return canceler;
}


Canceler* dispatchOnMainAfter(NSTimeInterval delayInSeconds, DispatchBlock f) {
    return dispatchOnQueue(mainQueue(), delayInSeconds, f);
}

Canceler* dispatchOnBackgroundAfter(NSTimeInterval delayInSeconds, DispatchBlock f) {
    return dispatchOnQueue(backgroundQueue(), delayInSeconds, f);
}

void _dispatchRepeatedOnQueue(DispatchQueue queue, NSTimeInterval interval, Canceler *canceler, CancelableBlock f) {
    _dispatchOnQueue(queue, interval, canceler, ^(Canceler *canceler) {
        if(!canceler.canceled) {
            f(canceler);
        }
        if(!canceler.canceled) {
            _dispatchRepeatedOnQueue(queue, interval, canceler, f);
        }
    });
}

Canceler* dispatchRepeatedOnQueue(DispatchQueue queue, NSTimeInterval interval, CancelableBlock f) {
    Canceler *canceler = [Canceler new];
    _dispatchRepeatedOnQueue(queue, interval, canceler, f);
    return canceler;
}

Canceler* dispatchRepeatedOnMain(NSTimeInterval interval, CancelableBlock f) {
    return dispatchRepeatedOnQueue(mainQueue(), interval, f);
}

Canceler* dispatchRepeatedOnBackground(NSTimeInterval interval, CancelableBlock f) {
    return dispatchRepeatedOnQueue(backgroundQueue(), interval, f);
}

