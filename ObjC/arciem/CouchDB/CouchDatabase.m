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

- (void)infoWithSuccess:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure
{
	[self infoWithSuccess:success failure:failure finally:nil];
}

- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CouchCheckDatabaseName(self.name);
	
	[self.server putPath:self.name params:nil success:^(id result) {
		success();
	} failure:failure finally:finally];
}

- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure
{
	[self createWithSuccess:success failure:failure finally:nil];
}

- (void)deleteWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CouchCheckDatabaseName(self.name);
	
	[self.server deletePath:self.name success:^(id result) {
		success();
	} failure:failure finally:finally];
}

- (void)deleteWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure
{
	[self deleteWithSuccess:success failure:failure finally:nil];
}

- (void)documentWithID:(NSString*)docID success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSString* path = [NSString stringWithFormat:@"%@/%@", self.name, docID];
	[self.server getPath:path success:^(id result) {
		success([CouchDocument documentWithMutableDictionary:(NSMutableDictionary*)result]);
	} failure:failure finally:finally];
}

- (void)documentWithID:(NSString*)docID success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure
{
	[self documentWithID:docID success:success failure:failure finally:nil];
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

- (void)saveDocument:(CouchDocument*)doc success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure
{
	[self saveDocument:doc success:success failure:failure finally:nil];
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

- (void)deleteDocument:(CouchDocument*)doc success:(void(^)(void))success failure:(void (^)(NSError*))failure
{
	[self deleteDocument:doc success:success failure:failure finally:nil];
}

- (void)replicateToDatabase:(CouchDatabase*)target options:(CouchReplicationOptions)options filter:(NSString*)filter docIDs:(NSArray*)docIDs proxy:(NSURL*)proxy success:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSURL* sourceURL = [NSURL URLWithString:self.name relativeToURL:self.server.baseURL];
	NSURL* targetURL = [NSURL URLWithString:target.name relativeToURL:target.server.baseURL];

	CouchDocument* paramsDoc = [CouchDocument document];
	[paramsDoc setValue:sourceURL.description forKey:@"source"];
	[paramsDoc setValue:targetURL.description forKey:@"target"];
	
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

- (void)replicateToDatabase:(CouchDatabase*)target options:(CouchReplicationOptions)options filter:(NSString*)filter docIDs:(NSArray*)docIDs proxy:(NSURL*)proxy success:(void(^)(void))success failure:(void (^)(NSError*))failure
{
	[self replicateToDatabase:target options:options filter:filter docIDs:docIDs proxy:proxy success:success failure:failure finally:nil];
}

- (void)query:(NSString*)queryString options:(CouchViewOptions)options success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
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
	
	NSString* paramsString = @"";
	if(paramsDict.count > 0) {
		paramsString = [NSString stringWithFormat:@"?%@", StringWithURLEscapedParamaters(paramsDict)];
	}
	NSString* path = [NSString stringWithFormat:@"%@/%@%@", self.name, queryString, paramsString];
	[self.server getPath:path success:^(id result) {
		success(result);
	} failure:failure finally:finally];
}

- (void)queryAllDocumentsWithOptions:(CouchViewOptions)options success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	[self query:@"_all_docs" options:options success:success failure:failure finally:finally];
}

- (void)queryAllDocumentsWithOptions:(CouchViewOptions)options success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure
{
	[self queryAllDocumentsWithOptions:options success:success failure:failure finally:nil];
}

- (void)queryDesignDocument:(NSString*)designDocName view:(NSString*)viewName options:(CouchViewOptions)options success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	NSString* queryString = [NSString stringWithFormat:@"_design/%@/_view/%@", designDocName, viewName];
	[self query:queryString options:options success:success failure:failure finally:finally];
}

- (void)queryDesignDocument:(NSString*)designDocName view:(NSString*)viewName options:(CouchViewOptions)options success:(void(^)(NSDictionary*))success failure:(void (^)(NSError*))failure
{
	[self queryDesignDocument:designDocName view:viewName options:options success:success failure:failure finally:nil];
}

@end
