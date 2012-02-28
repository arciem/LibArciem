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

enum {
	CFieldStateIndeterminate,
	CFieldStateOmitted,
	CFieldStateValid,
	CFieldStateProcessing,
	CFieldStateInvalid
};
typedef NSUInteger CFieldState;

extern NSString* const CFieldErrorDomain;

enum {
	CFieldErrorRequired = 1000
};

@interface CField : NSObject

- (id)initWithTitle:(NSString*)title key:(NSString*)key value:(id)value required:(BOOL)required updateAutomatically:(BOOL)updateAutomatically;

// Override in subclasses.
- (void)setup;
- (void)validateSuccess:(void (^)(CFieldState state))success failure:(void (^)(NSError* error))failure;

- (void)update;

@property (strong, readonly, nonatomic) NSString* title;
@property (strong, readonly, nonatomic) NSString* key;
@property (copy, nonatomic) id value;
@property (readonly, nonatomic, getter = isRequired) BOOL required;
@property (readonly, nonatomic) NSUInteger currentRevision;
@property (readonly, nonatomic) NSUInteger lastRevisionValidated;
@property (readonly, nonatomic) BOOL needsValidation;
@property (readonly, nonatomic, getter = isEmpty) BOOL empty;
@property (readonly, nonatomic) BOOL updateAutomatically;
@property (nonatomic) CFieldState state;
@property (strong, readonly, nonatomic) NSError* error;
@property (readonly, nonatomic) BOOL isValid;

@end
