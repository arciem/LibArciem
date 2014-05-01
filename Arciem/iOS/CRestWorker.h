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

//
// Common Errors
//
// NSURLErrorDomain NSURLErrorTimedOut "The request timed out." (DNS not responsive?)
// NSURLErrorDomain NSURLErrorNotConnectedToInternet "The Internet connection appears to be offline." (Airplane mode?)
// NSURLErrorDomain NSURLErrorCannotFindHost "A server with the specified hostname could not be found."
//
// See Also:
//   NSURLError.h
//   Foundation Constants Reference
//   CFNetwork Error Codes Reference
//

#import "CWorker.h"

extern NSString *const CRestErrorDomain;

extern NSString *const CRestErrorWorkerErrorKey;
extern NSString *const CRestErrorFailingURLErrorKey;

extern NSString *const CRestJSONMIMEType;

enum {
	CRestOfflineError = 2121,
    CRestBackgroundTaskExpiredError = 3001
};

@interface CRestWorker : CWorker <NSURLConnectionDelegate>

- (instancetype)initWithRequest:(NSURLRequest*)request;
+ (CRestWorker*)workerWithRequest:(NSURLRequest*)request;

// Inputs - may change between retries
@property (nonatomic) NSURLRequest *request;

@property (nonatomic) BOOL showsNetworkActivityIndicator; // default == YES

@property (copy, nonatomic) NSIndexSet *successStatusCodes; // set of HTTP status codes that count as "success", default: {200}

@property (nonatomic) NSString *expectedMIMEType;

// Outputs
@property (readonly, nonatomic) NSURLResponse *response;
@property (readonly, nonatomic) NSHTTPURLResponse *httpResponse;
@property (readonly, nonatomic) NSData *data;
@property (readonly, nonatomic) NSString *dataAsString; // UTF-8
@property (readonly, nonatomic) id dataAsJSON; // nil if parse error

- (id)dataAsJSONWithError:(NSError**)error;

@end
