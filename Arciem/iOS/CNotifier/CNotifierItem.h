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

#import <UIKit/UIKit.h>

@interface CNotifierItem : NSObject

- (id)initWithMessage:(NSString*)message priority:(NSInteger)priority tapHandler:(void (^)(void))tapHandler;
+ (CNotifierItem*)itemWithMessage:(NSString*)message priority:(NSInteger)priority tapHandler:(void (^)(void))tapHandler;

@property (copy, readonly, nonatomic) NSString* message;
@property (readonly, nonatomic) NSInteger priority;
@property (readonly, nonatomic) NSDate* date;
@property (nonatomic) UIColor* tintColor;
@property (nonatomic) BOOL whiteText;
@property (nonatomic) UIFont* font;
@property (nonatomic) NSTimeInterval duration;
@property (copy, nonatomic) void (^tapHandler)(void);
@property (readonly, nonatomic) BOOL visible; // KVC-compliant

- (void)incrementVisible;
- (void)decrementVisible;

@end
