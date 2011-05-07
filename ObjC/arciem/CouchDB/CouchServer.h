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

#import <Foundation/Foundation.h>
#import "RKRequestSerializable.h"

extern NSString* const CouchErrorDomain;
extern NSString* const CouchErrorName;
extern NSString* const CouchErrorReason;
extern NSInteger const CouchErrorCode;

@interface CouchServer : NSObject

- (id)initWithBaseURL:(NSURL*)baseURL;
+ (CouchServer*)couchServerWithBaseURL:(NSURL*)baseURL;
+ (CouchServer*)couchServerWithBaseURL:(NSURL *)baseURL username:(NSString*)username password:(NSString*)password;

@property(nonatomic, retain) NSURL* baseURL;
@property(nonatomic, retain) NSString* username;
@property(nonatomic, retain) NSString* password;
@property(nonatomic) BOOL showsIndicator;

- (void)versionWithSuccess:(void(^)(NSString*))success failure:(void (^)(NSError*))failure;
- (void)versionWithSuccess:(void(^)(NSString*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)allDatabaseNamesWithSuccess:(void(^)(NSSet*))success failure:(void (^)(NSError*))failure;
- (void)allDatabaseNamesWithSuccess:(void(^)(NSSet*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)getPath:(NSString*)resourcePath success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)putPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)postPath:(NSString*)resourcePath params:(NSObject<RKRequestSerializable>*)params success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)deletePath:(NSString*)resourcePath success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

@end
