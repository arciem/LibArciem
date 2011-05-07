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

#import "CouchServer.h"
#import "CouchDocument.h"

@interface CouchDatabase : NSObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) CouchServer* server;

- (id)initWithName:(NSString*)name server:(CouchServer*)server;
+ (CouchDatabase*)databaseWithName:(NSString*)name server:(CouchServer*)server;

- (void)infoWithSuccess:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure;
- (void)infoWithSuccess:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure;
- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)deleteWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure;
- (void)deleteWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)documentWithID:(NSString*)docID success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure;
- (void)documentWithID:(NSString*)docID success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)saveDocument:(CouchDocument*)doc success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure;
- (void)saveDocument:(CouchDocument*)doc success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)deleteDocument:(CouchDocument*)doc success:(void(^)(void))success failure:(void (^)(NSError*))failure;
- (void)deleteDocument:(CouchDocument*)doc success:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

@end