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

@import Foundation;

#import "ObjectUtils.h"

typedef void(^CObserverBlock)(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet* indexes);

@interface CObserver : NSObject

- (instancetype)initWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior;
- (instancetype)initWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior;


+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action;
+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial;
+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath ofObject:(id)object action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior;

+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action;
+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial;
+ (CObserver*)newObserverWithKeyPath:(NSString*)keyPath action:(CObserverBlock)action initial:(CObserverBlock)initial prior:(CObserverBlock)prior;

- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)addObjects:(NSArray*)array;
- (void)removeObjects:(NSArray*)array;
- (void)removeAllObjects;

@property (copy, nonatomic) NSArray* objects;

@end
