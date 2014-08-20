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

@interface CSwitch : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)d;
- (instancetype)initWithKeysAndBlocks:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

+ (CSwitch *)switchWithDictionary:(NSDictionary *)d;
+ (CSwitch *)switchWithKeysAndBlocks:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (id)switchOnKey:(id)key;
- (id)switchOnKey:(id)key withArg:(id)arg;

@end
