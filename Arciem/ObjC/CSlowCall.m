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

#import "CSlowCall.h"

@interface CSlowCall ()

@property (weak, readwrite, nonatomic) id target;
@property (readwrite, nonatomic) SEL selector;
@property (strong, readwrite, nonatomic) id object;
@property (readwrite, nonatomic, setter = setArmed:) BOOL isArmed;
@property (copy, readwrite, nonatomic) void (^block)(id object);

@end

@implementation CSlowCall

@synthesize delay = delay_;
@synthesize target = target_;
@synthesize selector = selector_;
@synthesize object = object_;
@synthesize isArmed = isArmed_;
@synthesize block = block_;

- (instancetype)initWithDelay:(NSTimeInterval)delay target:(id)target selector:(SEL)selector
{
	if(self = [super init]) {
		delay_ = delay;
		target_ = target;
		selector_ = selector;
	}
	
	return self;
}

- (instancetype)initWithDelay:(NSTimeInterval)delay block:(void (^)(id object))block
{
	if(self = [super init]) {
		delay_ = delay;
		block_ = block;
	}
	
	return self;
}

+ (CSlowCall*)newSlowCallWithDelay:(NSTimeInterval)delay target:(id)target selector:(SEL)selector
{
	return [[self alloc] initWithDelay:delay target:target selector:selector];
}

+ (CSlowCall*)newSlowCallWithDelay:(NSTimeInterval)delay block:(void (^)(id object))block
{
	return [[self alloc] initWithDelay:delay block:block];
}

- (void)dealloc
{
	[self disarm];
}

- (void)disarm
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fire) object:nil];
	self.object = nil;
	self.isArmed = NO;
}

- (void)armWithObject:(id)object
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fire) object:nil];
	self.object = object;
	[self performSelector:@selector(fire) withObject:nil afterDelay:self.delay];
	self.isArmed = YES;
}

- (void)arm
{
	[self armWithObject:nil];
}

- (void)fire
{
	if(self.target != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self.target performSelector:self.selector withObject:self.object];
#pragma clang diagnostic pop
	} else if(self.block != nil) {
		self.block(self.object);
	}

	self.object = nil;

	self.isArmed = NO;
}

#pragma mark - @property isArmed

+ (BOOL)automaticallyNotifiesObserversOfIsArmed
{
	return NO;
}

- (BOOL)isArmed
{
	return isArmed_;
}

- (void)setArmed:(BOOL)isArmed
{
	if(isArmed_ != isArmed) {
		[self willChangeValueForKey:@"isArmed"];
		isArmed_ = isArmed;
		[self didChangeValueForKey:@"isArmed"];
	}
}

@end
