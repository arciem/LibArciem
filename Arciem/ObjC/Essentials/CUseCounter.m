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

#import "CUseCounter.h"

@interface CUseCounter ()

@property (copy, nonatomic) dispatch_block_t beginUse;
@property (copy, nonatomic) dispatch_block_t endUse;
@property (readonly, nonatomic) NSMutableSet *tokens;

@end

@implementation CUseCounter

@synthesize beginUse = _beginUse;
@synthesize endUse = _endUse;
@synthesize tokens = _tokens;

- (instancetype)initWithBeginUse:(dispatch_block_t)beginUse endUse:(dispatch_block_t)endUse {
    if(self = [super init]) {
        _beginUse = beginUse;
        _endUse = endUse;
        _tokens = [NSMutableSet new];
    }
    return self;
}

+ (CUseCounter *)newUseCounterWithBeginUse:(dispatch_block_t)beginUse endUse:(dispatch_block_t)endUse {
    return [[self alloc] initWithBeginUse:beginUse endUse:endUse];
}

- (CUseToken *)newToken {
    CUseToken *token = [CUseToken new];
    [self.tokens addObject:token];
    if(self.tokens.count == 1) {
        if(self.beginUse != NULL) {
            self.beginUse();
        }
    }
    return token;
}

- (void)removeToken:(CUseToken *)token {
    NSAssert(token != nil, @"Attempt to remove nil token.");
    NSAssert([self.tokens containsObject:token], @"Attempt to remove non-existent token.");
    [self.tokens removeObject:token];
    if(self.tokens.count == 0) {
        if(self.endUse != NULL) {
            self.endUse();
        }
    }
}

@end

@implementation CUseToken

@end
