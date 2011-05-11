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

#import "CouchDatabase.h"
#import "ObjectUtils.h"
#import "CouchUtils.h"
#import "StringUtils.h"
#import "NSObject+JSON.h"

@implementation CouchDatabase

@synthesize name = name_;
@synthesize server = server_;

- (id)initWithName:(NSString*)name server:(CouchServer*)server
{
	if((self = [super init])) {
		self.name = name;
		self.server = server;
	}
	
	return self;
}

+ (CouchDatabase*)databaseWithName:(NSString*)name server:(CouchServer*)server
{
	return [[[self alloc] initWithName:name server:server] autorelease];
}

- (void)dealloc
{
	[self setPropertiesToNil];
	[super dealloc];
}

- (void)infoWithSuccess:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CouchCheckDatabaseName(self.name);
	
	NSString* path = [NSString stringWithFormat:@"%@/", self.name];
	[self.server getPath:path success:^(id result) {
		success(result);
	} failure:failure finally:finally];
}

- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CouchCheckDatabaseName(self.name);
	
	[self.server putPath:self.name params:nil success:^(id result) {
		success();
	} failure:failure finally:finally];
}

- (void)deleteWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CouchCheckDatabaseName(self.name);
	
	[self.server deletePath:self.name success:^(id result) {
		success();
	} failure:failure finally:finally];
}

- (void)documentWithID:(NSString*)docID options:(CouchDocumentOptions)options revision:(NSString*)revision success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSMutableDictionary* paramsDict = [NSMutableDictionary dictionary];

	if(options & CouchDocumentIncludeConflicts) {
		[paramsDict setObject:[NSNumber numberWithBool:YES] forKey:@"conflicts"];
	}

	if(options & CouchDocumentIncludeRevisions) {
		[paramsDict setObject:[NSNumber numberWithBool:YES] forKey:@"revs"];
	}
	
	if(options & CouchDocumentIncludeRevisionsDetail) {
		[paramsDict setObject:[NSNumber numberWithBool:YES] forKey:@"revs_info"];
	}
	
	if(!IsEmptyString(revision)) {
		[paramsDict setObject:revision forKey:@"rev"];
	}
	
	NSString* paramsString = @"";
	if(paramsDict.count > 0) {
		paramsString = [NSString stringWithFormat:@"?%@", StringWithURLEscapedParamaters(paramsDict)];
	}

	NSString* path = [NSString stringWithFormat:@"%@/%@%@", self.name, docID, paramsString];
	[self.server getPath:path success:^(id result) {
		success([CouchDocument documentWithMutableDictionary:(NSMutableDictionary*)result]);
	} failure:failure finally:finally];
}

- (void)saveDocument:(CouchDocument*)doc success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	if(IsEmptyString(doc._id)) {
		[self.server postPath:self.name params:doc success:^(id result) {
			doc._id = [result valueForKey:@"id"];
			doc._rev = [result valueForKey:@"rev"];
			success(doc);
		} failure:^(NSError* error) {
			failure(error);
		} finally:finally];
	} else {
		NSString* path = [NSString stringWithFormat:@"%@/%@", self.name, doc._id];
		[self.server putPath:path params:doc success:^(id result) {
			doc._rev = [result valueForKey:@"rev"];
			success(doc);
		} failure:failure finally:finally];
	}
}

- (void)deleteDocument:(CouchDocument*)doc success:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	if(!IsEmptyString(doc._id) && !IsEmptyString(doc._rev)) {
		NSDictionary* params = [NSDictionary dictionaryWithObject:doc._rev forKey:@"rev"];
		NSString* paramsString = StringWithURLEscapedParamaters(params);
		NSString* path = [NSString stringWithFormat:@"%@/%@?%@", self.name, doc._id, paramsString];
		[self.server deletePath:path success:^(id result) {
			success();
		} failure:failure finally:finally];
	}
}

- (void)replicateToDatabase:(CouchDatabase*)target options:(CouchReplicationOptions)options filter:(NSString*)filter docIDs:(NSArray*)docIDs proxy:(NSURL*)proxy success:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSString* sourceURLString = [[NSURL URLWithString:self.name relativeToURL:self.server.baseURL] absoluteString];
	NSString* targetURLString = [[NSURL URLWithString:target.name relativeToURL:target.server.baseURL] absoluteString];

	CouchDocument* paramsDoc = [CouchDocument document];
	[paramsDoc setValue:sourceURLString forKey:@"source"];
	[paramsDoc setValue:targetURLString forKey:@"target"];
	
	if(options & CouchReplicateCreateTarget) {
		[paramsDoc setValue:[NSNumber numberWithBool:YES] forKey:@"create_target"];
	}
	
	if(options & CouchReplicateCancel) {
		[paramsDoc setValue:[NSNumber numberWithBool:YES] forKey:@"cancel"];
	}
	
	if(options & CouchReplicationContinuous) {
		[paramsDoc setValue:[NSNumber numberWithBool:YES] forKey:@"continuous"];
	}
	
	if(!IsEmptyString(filter)) {
		[paramsDoc setValue:filter forKey:@"filter"];
	}
	
	if(!IsEmpty(docIDs)) {
		[paramsDoc setValue:docIDs forKey:@"doc_ids"];
	}
	
	if(!IsNull(proxy)) {
		[paramsDoc setValue:proxy.description forKey:@"proxy"];
	}
	
	[self.server postPath:@"_replicate" params:paramsDoc success:^(id result) {
		success();
	} failure:failure finally:finally];
}

- (void)query:(NSString*)queryString options:(CouchViewOptions)options key:(id)key startKey:(id)startKey endKey:(id)endKey startDocID:(NSString*)startDocID endDocID:(NSString*)endDocID limit:(NSUInteger)limit skip:(NSUInteger)skip groupLevel:(NSUInteger)groupLevel success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSMutableDictionary* paramsDict = [NSMutableDictionary dictionary];

	if(options & CouchViewDescending) {
		[paramsDict setObject:[NSNumber numberWithBool:YES] forKey:@"descending"];
	}
	
	if(options & CouchViewIncludeDocs) {
		[paramsDict setObject:[NSNumber numberWithBool:YES] forKey:@"include_docs"];
	}
	
	if(options & CouchViewExcludeEndKey) {
		[paramsDict setObject:[NSNumber numberWithBool:NO] forKey:@"inclusive_end"];
	}
	
	if(options & CouchViewDisableReduce) {
		[paramsDict setObject:[NSNumber numberWithBool:NO] forKey:@"reduce"];
	}
	
	if(options & CouchViewDisableRefresh) {
		[paramsDict setObject:@"ok" forKey:@"stale"];
	}
	
	if(options & CouchViewGroup) {
		[paramsDict setObject:[NSNumber numberWithBool:YES] forKey:@"group"];
	}
	
	if(groupLevel > 0) {
		[paramsDict setObject:[NSNumber numberWithUnsignedInt:groupLevel] forKey:@"group_level"];
	}
	
	if(!IsNull(key)) {
		// Also works if key is NSArray
		[paramsDict setObject:[(NSDictionary*)key JSONRepresentation] forKey:@"key"];
	}
	
	if(!IsNull(startKey)) {
		[paramsDict setObject:[(NSDictionary*)startKey JSONRepresentation] forKey:@"startkey"];
	}
	
	if(!IsNull(endKey)) {
		[paramsDict setObject:[(NSDictionary*)endKey JSONRepresentation] forKey:@"endkey"];
	}
	
	if(!IsEmptyString(startDocID)) {
		[paramsDict setObject:startDocID forKey:@"startkey_docid"];
	}
	
	if(!IsEmptyString(endDocID)) {
		[paramsDict setObject:endDocID forKey:@"endkey_docid"];
	}
	
	if(limit > 0) {
		[paramsDict setObject:[NSNumber numberWithUnsignedInt:limit] forKey:@"limit"];
	}
	
	if(skip > 0) {
		[paramsDict setObject:[NSNumber numberWithUnsignedInt:skip] forKey:@"skip"];
	}
	
	NSString* paramsString = @"";
	if(paramsDict.count > 0) {
		paramsString = [NSString stringWithFormat:@"?%@", StringWithURLEscapedParamaters(paramsDict)];
	}

	NSString* path = [NSString stringWithFormat:@"%@/%@%@", self.name, queryString, paramsString];
	[self.server getPath:path success:^(id result) {
		success(result);
	} failure:failure finally:finally];
}

- (void)queryAllDocumentsWithOptions:(CouchViewOptions)options key:(id)key startKey:(id)startKey endKey:(id)endKey startDocID:(NSString*)startDocID endDocID:(NSString*)endDocID limit:(NSUInteger)limit skip:(NSUInteger)skip groupLevel:(NSUInteger)groupLevel success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	[self query:@"_all_docs" options:options key:key startKey:startKey endKey:endKey startDocID:startDocID endDocID:endDocID limit:limit skip:skip groupLevel:groupLevel success:success failure:failure finally:finally];
}

- (void)queryDesignDocument:(NSString*)designDocName view:(NSString*)viewName options:(CouchViewOptions)options key:(id)key startKey:(id)startKey endKey:(id)endKey startDocID:(NSString*)startDocID endDocID:(NSString*)endDocID limit:(NSUInteger)limit skip:(NSUInteger)skip groupLevel:(NSUInteger)groupLevel success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSString* queryString = [NSString stringWithFormat:@"_design/%@/_view/%@", designDocName, viewName];
	[self query:queryString options:options key:key startKey:startKey endKey:endKey startDocID:startDocID endDocID:endDocID limit:limit skip:skip groupLevel:groupLevel success:success failure:failure finally:finally];
}

@end
