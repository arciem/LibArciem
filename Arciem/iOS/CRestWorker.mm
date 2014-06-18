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

#import "CRestWorker.h"
#import "ThreadUtils.h"
#import "CNetworkActivity.h"
#import "CLog.h"
#import "ErrorUtils.h"
#import "DeviceUtils.h"
#import "ObjectUtils.h"

NSString *const CRestErrorDomain = @"CRestErrorDomain";

NSString *const CRestErrorFailingURLErrorKey = @"CRestErrorFailingURLErrorKey";
NSString *const CRestErrorWorkerErrorKey = @"CRestErrorWorkerErrorKey";
NSString *const CRestErrorOfflineErrorKey = @"CRestErrorOfflineErrorKey";

NSString *const CRestJSONMIMEType = @"application/json";

@interface CRestWorker () <NSURLSessionTaskDelegate>

@property (readonly, nonatomic) NSURLSession *session;
@property (strong, readwrite, nonatomic) NSURLResponse *response;
@property (nonatomic) NSMutableData *mutableData;
@property (nonatomic) CNetworkActivity *activity;
@property (weak, nonatomic) NSThread *workerThread;
@property (nonatomic) BOOL workerWaitLoopStopped;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation CRestWorker

@synthesize dataAsJSON = _dataAsJSON;
@synthesize dataAsString = _dataAsString;

+ (void)initialize
{
//	CLogSetTagActive(@"C_REST_WORKER", YES);
}

- (instancetype)initWithRequest:(NSURLRequest*)request
{
	if(self = [super init]) {
		self.request = request;
		self.mutableData = [NSMutableData data];
		self.successStatusCodes = [NSIndexSet indexSetWithIndex:200];
		self.showsNetworkActivityIndicator = YES;
	}

	return self;
}

+ (CRestWorker*)workerWithRequest:(NSURLRequest*)request
{
	return [[self alloc] initWithRequest:request];
}

- (NSData*)data
{
	return [NSData dataWithData:self.mutableData];
}

- (NSString*)dataAsString
{
    if(_dataAsString == nil) {
        _dataAsString = [[NSString alloc] initWithData:self.mutableData encoding:NSUTF8StringEncoding];
    }
    return _dataAsString;
}

- (id)dataAsJSONWithError:(NSError**)error
{
    if(_dataAsJSON == nil) {
        NSError *myError;
        _dataAsJSON = [NSJSONSerialization JSONObjectWithData:self.mutableData options:0 error:&myError];
        if(_dataAsJSON == nil) {
            CLogError(nil, @"%@ Parsing JSON:%@ dataAsString:\"%@\"", self, myError, self.dataAsString);
            if(error != nil) {
                *error = myError;
            }
        }
    }
	return _dataAsJSON;
}

- (id)dataAsJSON
{
	return [self dataAsJSONWithError:nil];
}

- (NSHTTPURLResponse*)httpResponse
{
	NSHTTPURLResponse *httpResponse = nil;
	if([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
		httpResponse = (NSHTTPURLResponse*)self.response;
	}
	return httpResponse;
}

- (void)didCancel
{
	[super didCancel];
}

- (void)operationDidBegin
{
	[super operationDidBegin];
	self.activity = [CNetworkActivity activityWithIndicator:self.showsNetworkActivityIndicator];
//    BSELF;
//    void (^expirationHandler)(void) = ^{
//        NSString *message = [NSString stringWithFormat:@"Background task expired: %@", bself.title];
//        NSError *error = [NSError errorWithDomain:CRestErrorDomain code:CRestBackgroundTaskExpiredError localizedDescription:message];
//        [bself operationFailedWithError:error];
//    };
}

- (void)operationWillEnd
{
	[super operationWillEnd];
	self.activity = nil;
}

- (BOOL)isOffline {
	return NO;
}

- (void)performOperationWork {
	if(self.isOffline) {
		CLogTrace(@"C_REST_WORKER", @"%@ failing because offline", self);
        NSError *error = [NSError errorWithDomain:CRestErrorDomain code:CRestOfflineError userInfo:nil];
        [self handleError:error];
	} else {
        [self performOperationWorkWithNSURLSession];
    }
}

- (NSURLSession *)session {
    static NSURLSession *_session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return _session;
}

- (void)performOperationWorkWithNSURLSession {
	CLogTrace(@"C_REST_WORKER", @"%@ starting NSURLSession: %@", self, self.request);
    
    [self.mutableData setLength:0];
    BSELF;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @synchronized(bself) {
            if(!self.cancelled) {
                if(data != nil) {
                    [bself.mutableData appendData:data];
                }
                if(response != nil) {
                    bself.response = response;
                }
                if(error != nil) {
                    [bself handleError:error];
                } else {
                    [bself handleResponse];
                }
            }
        }
    }];
    [task resume];
}

- (void)stopWorkerWaitLoop_
{
    self.workerWaitLoopStopped = YES;
}

- (void)stopWorkerWaitLoop
{
    [self performSelector:@selector(stopWorkerWaitLoop_) onThread:self.workerThread withObject:nil waitUntilDone:NO];
}

- (NSOperation*)newOperationForTry
{
	NSAssert(self.request != nil, @"request must exist");

	return [super newOperationForTry];
}

- (void)updateTitleForError
{
	if(self.error != nil) {
		[self.titleItems addObject:[NSString stringWithFormat:@"=%ld", (long)self.error.code]];
	} else if(self.httpResponse != nil) {
		[self.titleItems addObject:[NSString stringWithFormat:@"=%ld", (long)self.httpResponse.statusCode]];
	} else {
		[self.titleItems addObject:@"=?"];
	}
}

- (void)handleResponse {
    NSHTTPURLResponse *httpResponse = self.httpResponse;
    if(httpResponse != nil) {
        NSInteger statusCode = httpResponse.statusCode;
        if([self.successStatusCodes containsIndex:statusCode]) {
            NSError *parseError = nil;
            if([self.expectedMIMEType isEqualToString:CRestJSONMIMEType]) {
                [self dataAsJSONWithError:&parseError];
            }
            
            if(parseError == nil) {
                [self operationSucceeded];
            } else {
                [self operationFailedWithError:parseError];
            }
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:statusCode],
                                       CRestErrorFailingURLErrorKey: self.request.URL,
                                       CRestErrorWorkerErrorKey: self};
            NSError *error = [NSError errorWithDomain:CRestErrorDomain code:statusCode userInfo:userInfo];
            [self operationFailedWithError:error];
        }
    } else {
        [self operationSucceeded];
    }
}

- (void)handleError:(NSError *)error {
    [self operationFailedWithError:error];
}

- (NSURLRequest *)handleRedirectReponse:(NSHTTPURLResponse *)redirectResponse withProposedRequest:(NSURLRequest *)request {
    NSString *authToken = redirectResponse.allHeaderFields[@"x-redirect-auth"];
    if(authToken != nil) {
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval];
        [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
            if(![name isEqualToString:@"x-redirect-auth"]) {
                [mutableRequest addValue:value forHTTPHeaderField:name];
            }
        }];
        [mutableRequest addValue:authToken forHTTPHeaderField:@"Authorization"];
        
        request = mutableRequest;
    }
    
#if 0
#warning DEBUG ONLY
    CLogDebug(nil, @"old URL:%@", task.originalRequest.URL);
    CLogDebug(nil, @"new URL:%@", request.URL);
    CLogDebug(nil, @"old request headers:%@", task.originalRequest.allHTTPHeaderFields);
    CLogDebug(nil, @"new request headers:%@", request.allHTTPHeaderFields);
#endif

    return request;
}

#pragma mark - NSURLSessionTaskDelegate

// The x-redirect-auth header gives the server the chance to tell the client what credentials to use to authenticate to the redirected URL. This may frequently (but not necessarily) be the same credentials that were used for the first URL.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    request = [self handleRedirectReponse:redirectResponse withProposedRequest:request];
    completionHandler(request);
}

@end
