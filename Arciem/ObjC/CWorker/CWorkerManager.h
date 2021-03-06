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

#import "CWorker.h"

@interface CWorkerManager : NSObject

+ (CWorkerManager*)sharedWorkerManager;

- (void)addWorker:(CWorker*)worker success:(void (^)(CWorker*))success shouldRetry:(BOOL (^)(CWorker*, NSError*))shouldRetry failure:(void (^)(CWorker*, NSError*))failure finally:(void (^)(CWorker*))finally;

@property (strong, readonly, nonatomic) NSOperationQueue* queue;
@property (readonly, nonatomic) NSMutableSet* workers;

- (NSMutableSet*)workers;

@end
