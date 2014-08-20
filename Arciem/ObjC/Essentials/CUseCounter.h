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

@import Foundation;

@interface CUseToken : NSObject
@end

@interface CUseCounter : NSObject

+ (CUseCounter *)newUseCounterWithBeginUse:(dispatch_block_t)beginUse endUse:(dispatch_block_t)endUse;

- (CUseToken *)newToken;
- (void)removeToken:(CUseToken *)token;

@end
