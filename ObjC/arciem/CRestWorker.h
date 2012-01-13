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

extern NSString* const CRestErrorDomain;

extern NSString* const CRestErrorWorkerErrorKey;
extern NSString* const CRestErrorFailingURLErrorKey;

@interface CRestWorker : NSObject<NSURLConnectionDelegate>

// designated initializer, sets sequenceNumber to next increment
- (id)init;
- (id)initWithRequest:(NSURLRequest*)request identifier:(NSString*)identifier;

+ (CRestWorker*)worker;
+ (CRestWorker*)workerWithRequest:(NSURLRequest*)request identifier:(NSString*)identifier;

- (void)cancel;

// Inputs - may change between retries
@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) NSString* identifier; // for debug display

@property (nonatomic) NSUInteger tryLimit; // 0 -> no limit, default == 3
@property (nonatomic) NSTimeInterval retryDelayInterval; // default 1 second
@property (nonatomic) BOOL showsNetworkActivityIndicator; // default == YES

@property (nonatomic) NSOperationQueuePriority queuePriority; // default NSOperationQueuePriorityNormal
@property (weak, nonatomic) NSThread* callbackThread; // zeroing weak reference, we don't own our caller

// This worker will not execute until all workers it is dependent on have finished.
// Dependencies should not be added or removed once the worker has been added to the CRestManager.
@property (readonly, nonatomic) NSArray* dependencies;
- (void)addDependency:(CRestWorker *)worker;
- (void)removeDependency:(CRestWorker *)worker;

@property (copy, nonatomic) NSIndexSet* successStatusCodes; // set of HTTP status codes that count as "success", default: {200}

// Status
@property (readonly, nonatomic) BOOL isCancelled;
@property (readonly, nonatomic) BOOL isExecuting;
@property (readonly, nonatomic) BOOL isFinished;
@property (readonly, nonatomic) BOOL isReady;

// Outputs
@property (readonly, strong, nonatomic) NSURLResponse* response;
@property (readonly, nonatomic) NSHTTPURLResponse* httpResponse;
@property (readonly, nonatomic) NSData* data;
@property (readonly, nonatomic) NSString* dataAsString; // UTF-8
@property (readonly, nonatomic) id dataAsJSON; // nil if parse error

@property (readonly, nonatomic) NSUInteger sequenceNumber; // for debug display
@property (readonly, nonatomic) NSUInteger tryCount; // initially 0, incremented for each call to -createOperation

@end

@interface CRestWorker(Private)

- (NSOperation*)createOperationForTry;
@property (copy, nonatomic) void (^success)(CRestWorker*);
@property (copy, nonatomic) void (^failure)(NSError*);
@property (copy, nonatomic) void (^finally)(void);
@property (readwrite, nonatomic) BOOL isExecuting;
@property (readwrite, nonatomic) BOOL isFinished;
@property (readonly, nonatomic) BOOL canRetry;

@end