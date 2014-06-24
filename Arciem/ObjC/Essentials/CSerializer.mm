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

#import "CSerializer.h"

static NSString *const serializerKey = @"serializerKey";
static NSUInteger nextQueueContext = 1;

@interface CSerializer ()

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSUInteger queueContext;
@property (readonly, nonatomic) BOOL isExecutingOnMyQueue;

@end

@implementation CSerializer

- (instancetype)initWithName:(NSString *)name {
    if(self = [super init]) {
        self.queue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
        self.queueContext = ++nextQueueContext;
        dispatch_queue_set_specific(self.queue, (__bridge const void *)serializerKey, (void *)self.queueContext, NULL);
    }
    return self;
}

- (BOOL)isExecutingOnMyQueue {
    NSUInteger context = (NSUInteger)dispatch_get_specific((__bridge const void *)serializerKey);
    return context == self.queueContext;
}

+ (instancetype)newSerializerWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (void)perform:(dispatch_block_t)f {
    if(self.isExecutingOnMyQueue) {
        f();
    } else {
        dispatch_sync(self.queue, f);
    }
}

- (id)performWithResult:(serializer_block_t)f {
    __block id result;
    
    if(self.isExecutingOnMyQueue) {
        result = f();
    } else {
        dispatch_sync(self.queue, ^{
            result = f();
        });
    }
    
    return result;
}

- (void)performOnMainThread:(dispatch_block_t)f {
    if(self.isExecutingOnMyQueue) {
        if([NSThread isMainThread]) {
            f();
        } else {
            dispatch_sync(dispatch_get_main_queue(), f);
        }
    } else {
        dispatch_sync(self.queue, ^{
            if([NSThread isMainThread]) {
                f();
            } else {
                dispatch_sync(dispatch_get_main_queue(), f);
            }
        });
    }
}

- (id)performOnMainThreadWithResult:(serializer_block_t)f {
    __block id result;
    
    if(self.isExecutingOnMyQueue) {
        if([NSThread isMainThread]) {
            result = f();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                result = f();
            });
        }
    } else {
        dispatch_sync(self.queue, ^{
            if([NSThread isMainThread]) {
                result = f();
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    result = f();
                });
            }
        });
    }
    
    return result;
}

@end
