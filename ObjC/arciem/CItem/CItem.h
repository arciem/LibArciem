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

extern NSString* const CItemErrorDomain;

enum {
	CItemErrorRequired = 1000
};

enum {
	CItemStateNeedsValidation,
	CItemStateValidating,
	CItemStateValid,
	CItemStateInvalid
};
typedef NSUInteger CItemState;

@interface CItem : NSObject

@property (strong, nonatomic) NSString* title;			// localized, human-readable
@property (strong, nonatomic) NSString* key;			// NSKeyValueCoding-compatible
@property (readonly, nonatomic) NSString* keyPath;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) id userInfo;
@property (strong, nonatomic) NSError* error;
@property (nonatomic) BOOL required;
@property (readonly, nonatomic) CItemState state;
@property (nonatomic) BOOL validatesAutomatically;

@property (readonly, nonatomic) BOOL needsValidation;
@property (readonly, nonatomic) BOOL isValidating;
@property (readonly, nonatomic) BOOL isEmpty;
@property (readonly, nonatomic) BOOL isValid;

//@property (readonly, nonatomic) NSString* keyPath;

@property (weak, readonly, nonatomic) CItem* superitem;
@property (strong, readonly, nonatomic) NSMutableArray* subitems;

- (id)initWithDictionary:(NSDictionary*)dict;
+ (CItem*)item;
+ (CItem*)itemWithDictionary:(NSDictionary*)dict;
+ (CItem*)itemForResourceName:(NSString*)resourceName withExtension:(NSString*)extension;
+ (CItem*)itemWithTitle:(NSString*)title key:(NSString*)key value:(id)value;

// Override in subclasses.
- (BOOL)isEmpty;
- (NSError*)validate;
- (void)validateWithCompletion:(void (^)(NSError* error))completion;
- (NSArray*)descriptionStringsCompact:(BOOL)compact;

- (NSString*)keyPathRelativeToItem:(CItem*)ancestorItem;
- (void)addSubitem:(CItem*)item;
- (void)removeFromSuperitem;

- (void)printHierarchy;

@end

@interface CItemTest : NSObject

- (void)test;

@end