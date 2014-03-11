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

#import "CNotifierItem.h"
#import "ObjectUtils.h"

@interface CNotifierItem ()

@property (copy, readwrite, nonatomic) NSString* message;
@property (readwrite, nonatomic) NSInteger priority;
@property (strong, readwrite, nonatomic) NSDate* date;
@property (nonatomic) NSInteger visibleCount;

@end

@implementation CNotifierItem

+ (void)initialize
{
//	CLogSetTagActive(@"C_NOTIFIER_ITEM", YES);
}

- (id)initWithMessage:(NSString*)message priority:(NSInteger)priority tapHandler:(dispatch_block_t)tapHandler
{
	if(self = [super init]) {
		self.message = message;
		self.priority = priority;
		self.date = [NSDate date];
		self.tintColor = [UIColor whiteColor];
		self.whiteText = NO;
		self.font = [UIFont boldSystemFontOfSize:14.0];
		self.duration = 0.0;
		self.tapHandler = tapHandler;
	}
	
	return self;
}

- (void)dealloc
{
	CLogTrace(@"C_NOTIFIER_ITEM", @"%@ dealloc", self);
}

+ (CNotifierItem*)itemWithMessage:(NSString*)message priority:(NSInteger)priority tapHandler:(dispatch_block_t)tapHandler
{
	return [[self alloc] initWithMessage:message priority:priority tapHandler:tapHandler];
}

- (NSString*)description
{
	return [self formatObjectWithValues:
            @[ [self formatValueForKey:@"message" compact:NO],
            [self formatValueForKey:@"priority" compact:NO],
            [self formatValueForKey:@"date" compact:NO],
            [self formatValueForKey:@"duration" compact:NO],
            [self formatValueForKey:@"tapHandler" compact:NO],
            [self formatBoolValueForKey:@"visible" compact:NO],
            ] ];
}

+ (BOOL)automaticallyNotifiesObserversOfVisible {
    return NO;
}

- (BOOL)visible {
    @synchronized(self) {
        return self.visibleCount > 0;
    }
}

- (void)incrementVisible {
    @synchronized(self) {
        if(self.visibleCount == 0) {
            [self willChangeValueForKey:@"visible"];
        }
        self.visibleCount++;
        if(self.visibleCount == 1) {
            [self didChangeValueForKey:@"visible"];
        }
    }
}

- (void)decrementVisible {
    @synchronized(self) {
        NSAssert1(self.visibleCount > 0, @"Attempt to decrementVisible below zero for %@", self);
        if(self.visibleCount == 1) {
            [self willChangeValueForKey:@"visible"];
        }
        self.visibleCount--;
        if(self.visibleCount == 0) {
            [self didChangeValueForKey:@"visible"];
        }
    }
}

@end
