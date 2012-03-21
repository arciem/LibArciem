/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
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

#import "RestKit.h"

enum {
	RKBlocksTimeoutError = 999
};

@interface RKClient (Blocks)

- (RKRequest*)getPath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (RKRequest*)getPath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure;

- (RKRequest*)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (RKRequest*)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure;

- (RKRequest*)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (RKRequest*)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure;

- (RKRequest*)deletePath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (RKRequest*)deletePath:(NSString*)resourcePath indicator:(BOOL)indicator timeoutInterval:(NSTimeInterval)timeoutInterval success:(void (^)(RKResponse*))success failure:(void (^)(NSError*))failure;

@end
