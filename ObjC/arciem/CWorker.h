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

@interface CWorker : NSObject

// designated initializer, sets sequenceNumber to next increment
- (id)init;

- (void)cancel;

// for debug display
@property (readonly, nonatomic) NSUInteger sequenceNumber;
@property (readonly, nonatomic) NSString* formattedSequenceNumber;
@property (readonly, nonatomic) NSString* formattedQueuePriority;
@property (readonly, nonatomic) NSString* formattedDependencies;
@property (readonly, nonatomic) NSString* formattedErrorCode;
@property (copy, nonatomic) NSMutableArray* titleItems;
@property (strong, readonly, nonatomic) NSString* title;

@property (nonatomic) NSUInteger tryLimit; // 0 -> no limit, default == 3
@property (nonatomic) NSTimeInterval retryDelayInterval; // default 1 second
@property (nonatomic) NSOperationQueuePriority queuePriority; // default NSOperationQueuePriorityNormal
@property (weak, nonatomic) NSThread* callbackThread; // zeroing weak reference, we don't own our caller

// This worker will not execute until all workers it is dependent on have finished.
// Dependencies should not be added or removed once the worker has been added to the CRestManager.
@property (readonly, nonatomic) NSSet* dependencies;
- (BOOL)addDependency:(CWorker *)worker;
- (BOOL)removeDependency:(CWorker *)worker;

// Status
@property (nonatomic) BOOL isExecuting;
@property (nonatomic) BOOL isReady;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isCancelled;
@property (strong, readonly, nonatomic) NSError* error;

@property (readonly, nonatomic) NSUInteger tryCount; // initially 0, incremented for each call to -createOperation
@property (readonly, nonatomic) BOOL canRetry;

@property (copy, nonatomic) void (^success)(CWorker*);
@property (copy, nonatomic) void (^failure)(CWorker*, NSError*);
@property (copy, nonatomic) void (^finally)(CWorker*);

// may be augmented with call to super
- (NSOperation*)createOperationForTry;

// default behavior may be entirely overridden without call to super
- (void)performRetryDelay;
- (void)updateTitleForError;

// behavior provided entirely by subclasses
- (void)operationDidBegin;
- (void)operationWillEnd;
- (void)didCancel;
- (void)performOperationWork;

- (void)operationSucceeded;
- (void)operationFailedWithError:(NSError*)error;

@end
