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

typedef NSUInteger CouchDocumentOptions;
enum {
	CouchDocumentIncludeConflicts = 1,
	CouchDocumentIncludeRevisions = 2,
	CouchDocumentIncludeRevisionsDetail = 4
};

typedef NSUInteger CouchReplicationOptions;
enum {
	CouchReplicateCreateTarget = 1,
	CouchReplicateCancel = 2,
	CouchReplicationContinuous = 4
};

typedef NSUInteger CouchViewOptions;
enum {
	CouchViewDescending = 1,
	CouchViewIncludeDocs = 2,
	CouchViewExcludeEndKey = 4,
	CouchViewDisableReduce = 8,
	CouchViewDisableRefresh = 16,
	CouchViewGroup = 32
};

@interface CouchDatabase : NSObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) CouchServer* server;

- (id)initWithName:(NSString*)name server:(CouchServer*)server;
+ (CouchDatabase*)databaseWithName:(NSString*)name server:(CouchServer*)server;

// http://wiki.apache.org/couchdb/HTTP_database_API
- (void)infoWithSuccess:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)deleteWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

// http://wiki.apache.org/couchdb/HTTP_Document_API
- (void)documentWithID:(NSString*)docID options:(CouchDocumentOptions)options revision:(NSString*)revision success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)saveDocument:(CouchDocument*)doc success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;
- (void)deleteDocument:(CouchDocument*)doc success:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

// http://wiki.apache.org/couchdb/Replication
- (void)replicateToDatabase:(CouchDatabase*)target options:(CouchReplicationOptions)options filter:(NSString*)filter docIDs:(NSArray*)docIDs proxy:(NSURL*)proxy success:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

// http://wiki.apache.org/couchdb/HTTP_view_API
- (void)queryAllDocumentsWithOptions:(CouchViewOptions)options key:(id)key startKey:(id)startKey endKey:(id)endKey startDocID:(NSString*)startDocID endDocID:(NSString*)endDocID limit:(NSUInteger)limit skip:(NSUInteger)skip groupLevel:(NSUInteger)groupLevel success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

- (void)queryDesignDocument:(NSString*)designDocName view:(NSString*)viewName options:(CouchViewOptions)options key:(id)key startKey:(id)startKey endKey:(id)endKey startDocID:(NSString*)startDocID endDocID:(NSString*)endDocID limit:(NSUInteger)limit skip:(NSUInteger)skip groupLevel:(NSUInteger)groupLevel success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally;

@end
