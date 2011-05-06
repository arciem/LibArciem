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
#import "ObjectUtils.h"
#import "RKClient+Blocks.h"
#import "CNetworkActivity.h"

NSString* const CouchErrorDomain = @"CouchErrorDomain";
NSString* const CouchErrorName = @"CouchErrorName";
NSString* const CouchErrorReason = @"CouchErrorReason";
NSInteger const CouchErrorCode = 1;

@interface CouchServer ()

@property(nonatomic, retain) RKClient* client;

@end

@implementation CouchServer

@synthesize client = client_;
@synthesize showsIndicator = showsIndicator_;
@dynamic baseURL;
@dynamic username;
@dynamic password;

- (id)initWithBaseURL:(NSURL*)baseURL
{
	if((self = [super init])) {
		self.client = [RKClient clientWithBaseURL:baseURL.description];
	}
	return self;
}

+ (CouchServer*)couchServerWithBaseURL:(NSURL*)baseURL
{
	return [[[self alloc] initWithBaseURL:baseURL] autorelease];
}

+ (CouchServer*)couchServerWithBaseURL:(NSURL *)baseURL username:(NSString*)username password:(NSString*)password
{
	CouchServer* couch = [self couchServerWithBaseURL:baseURL];
	couch.username = username;
	couch.password = password;
	return couch;
}

- (void)dealloc
{
	[self setPropertiesToNil];
	[super dealloc];
}

- (NSURL*)baseURL
{
	return [NSURL URLWithString:self.client.baseURL];
}

- (void)setBaseURL:(NSString *)baseURL
{
	self.client.baseURL = baseURL.description;
}

- (NSString*)username
{
	return self.client.username;
}

- (void)setUsername:(NSString *)username
{
	self.client.username = username;
}

- (NSString*)password
{
	return self.client.password;
}

- (void)setPassword:(NSString *)password
{
	self.client.password = password;
}

- (id)resultFromResponse:(RKResponse*)response withFailure:(void (^)(NSError*))failure
{
	id json = [response bodyAsJSON];
	NSError* error = nil;
	
	if([json isKindOfClass:[NSDictionary class]]) {
		NSDictionary* dict = json;
		NSString* errorType = [dict objectForKey:@"error"];
		if(errorType != nil) {
			NSString* errorName = [dict objectForKey:@"error"];
			if(errorName == nil) errorName = @"unknown";
			NSString* errorReason = [dict objectForKey:@"reason"];
			if(errorReason == nil) errorReason = @"unknown";
			NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  response.URL, NSURLErrorKey,
									  errorName, CouchErrorName,
									  errorReason, CouchErrorReason,
									  nil];
			error = [NSError errorWithDomain:CouchErrorDomain code:CouchErrorCode userInfo:userInfo];
		}
	}
	
	if(error != nil) {
		failure(error);
		json = nil;
	}
	
	return json;
}

- (void)getPath:(NSString*)resourcePath success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CNetworkActivity* activity = [[CNetworkActivity activityWithIndicator:self.showsIndicator] retain];
	
	[self.client getPath:resourcePath success:^(RKResponse* response) {
		id result = [self resultFromResponse:response withFailure:failure];
		if(result != nil) {
			success(result);
		}
	} failure:^(NSError* error) {
		failure(error);
	} finally:^{
		if(finally != nil) finally();
		[activity release];
	}];
}

- (void)putPath:(NSString*)resourcePath success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CNetworkActivity* activity = [[CNetworkActivity activityWithIndicator:self.showsIndicator] retain];
	
	[self.client putPath:resourcePath params:nil success:^(RKResponse* response) {
		id result = [self resultFromResponse:response withFailure:failure];
		if(result != nil) {
			success(result);
		}
	} failure:^(NSError* error) {
		failure(error);
	} finally:^{
		if(finally != nil) finally();
		[activity release];
	}];
}

- (void)deletePath:(NSString*)resourcePath success:(void(^)(id))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	CNetworkActivity* activity = [[CNetworkActivity activityWithIndicator:self.showsIndicator] retain];
	
	[self.client deletePath:resourcePath success:^(RKResponse* response) {
		id result = [self resultFromResponse:response withFailure:failure];
		if(result != nil) {
			success(result);
		}
	} failure:^(NSError* error) {
		failure(error);
	} finally:^{
		if(finally != nil) finally();
		[activity release];
	}];
}

- (void)versionWithSuccess:(void(^)(NSString*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	[self getPath:@"" success:^(id result) {
		success([result objectForKey:@"version"]);
	} failure:^(NSError* error) {
		failure(error);
	} finally:finally];
}

- (void)versionWithSuccess:(void(^)(NSString*))success failure:(void (^)(NSError*))failure
{
	[self versionWithSuccess:success failure:failure finally:nil];
}

- (void)allDatabaseNamesWithSuccess:(void(^)(NSSet*))success failure:(void (^)(NSError*))failure finally:(void (^)(void))finally
{
	[self getPath:@"_all_dbs" success:^(id result) {
		success([NSSet setWithArray:result]);
	} failure:^(NSError* error) {
		failure(error);
	} finally:finally];
}

- (void)allDatabaseNamesWithSuccess:(void(^)(NSSet*))success failure:(void (^)(NSError*))failure
{
	[self allDatabaseNamesWithSuccess:success failure:failure finally:nil];
}

@end
