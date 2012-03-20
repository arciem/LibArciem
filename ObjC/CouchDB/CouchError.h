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

extern NSString* const CouchErrorDomain;
extern NSString* const CouchErrorName;
extern NSString* const CouchErrorReason;

@interface NSError (CouchError)

@property(nonatomic, readonly) BOOL serverGone;

@property(nonatomic, readonly) BOOL isCouchError;
@property(nonatomic, readonly) NSString* errorName;
@property(nonatomic, readonly) NSString* errorReason;

@property(nonatomic, readonly) BOOL notFound;
@property(nonatomic, readonly) BOOL missing;
@property(nonatomic, readonly) BOOL deleted;
@property(nonatomic, readonly) BOOL noDBFile;

@property(nonatomic, readonly) BOOL conflict;

@end
