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

- (void)createWithSuccess:(void(^)(void))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CouchCheckDatabaseName(self.name);
	
	[self.server putPath:self.name success:^(id result) {
		success();
	} failure:^(NSError* error) {
		failure(error);
	} finally:finally];
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
	} failure:^(NSError* error) {
		failure(error);
	} finally:finally];
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
	} failure:^(NSError* error) {
		failure(error);
	} finally:finally];
}

- (void)documentWithID:(NSString*)docID success:(void(^)(CouchDocument*))success failure:(void (^)(NSError*))failure
{
	[self documentWithID:docID success:success failure:failure finally:nil];
}

@end
