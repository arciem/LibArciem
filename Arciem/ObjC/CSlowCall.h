/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

@interface CSlowCall : NSObject

@property (nonatomic) NSTimeInterval delay;
@property (readonly, nonatomic) id object;
@property (readonly, nonatomic) BOOL isArmed;

@property (weak, readonly, nonatomic) id target;
@property (readonly, nonatomic) SEL selector;

@property (copy, readonly, nonatomic) void (^block)(id object);

- (instancetype)initWithDelay:(NSTimeInterval)delay target:(id)target selector:(SEL)selector;
- (instancetype)initWithDelay:(NSTimeInterval)delay block:(void (^)(id object))block;

+ (CSlowCall*)newSlowCallWithDelay:(NSTimeInterval)delay target:(id)target selector:(SEL)selector;
+ (CSlowCall*)newSlowCallWithDelay:(NSTimeInterval)delay block:(void (^)(id object))block;

- (void)disarm;
- (void)armWithObject:(id)object;
- (void)arm;

@end
