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

typedef id (^serializer_block_t)(void);

@interface CSerializer : NSObject

+ (instancetype)newSerializerWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;
- (void)perform:(dispatch_block_t)f;
- (id)performWithResult:(serializer_block_t)f;
- (void)performOnMainThread:(dispatch_block_t)f;
- (id)performOnMainThreadWithResult:(serializer_block_t)f;

@end
