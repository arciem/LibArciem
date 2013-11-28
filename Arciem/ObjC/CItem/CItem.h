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
	CItemErrorRequired = 1000,
	CItemErrorNotEqualToOtherItem
};

enum {
	CItemStateNeedsValidation,
	CItemStateValidating,
	CItemStateValid,
	CItemStateInvalid
};
typedef NSUInteger CItemState;

@interface CItem : NSObject<NSCopying>

@property (copy, readonly, nonatomic) NSMutableDictionary* dict;

@property (nonatomic) NSString* title;			// localized, human-readable
@property (nonatomic) NSString* key;			// NSKeyValueCoding-compatible
@property (readonly, nonatomic) NSString* keyPath;
@property (nonatomic) id value;
@property (nonatomic) id defaultValue;
@property (nonatomic) NSArray *dummyValues;
@property (nonatomic) NSError* error;
@property (nonatomic, getter = isRequired) BOOL required;
@property (readonly, nonatomic) CItemState state;
@property (nonatomic) BOOL validatesAutomatically;
@property (nonatomic) BOOL needsValidation;

@property (readonly, nonatomic, getter = isActive) BOOL active;
@property (readonly, nonatomic, getter = isValidating) BOOL validating;
@property (readonly, nonatomic, getter = isEmpty) BOOL empty;
@property (readonly, nonatomic, getter = isValid) BOOL valid;
@property (nonatomic, getter = isFresh) BOOL fresh;
@property (nonatomic, getter = isEditing) BOOL editing;

@property (nonatomic, getter = isHidden) BOOL hidden;
@property (readonly, nonatomic) NSArray* visibleSubitems;

@property (nonatomic, getter = isDisabled) BOOL disabled;

@property (nonatomic, getter = isSelectable) BOOL selectable;
@property (nonatomic, getter = isSelected) BOOL selected;

@property (weak, readonly, nonatomic) CItem* superitem;
@property (readonly, nonatomic) NSMutableArray* subitems;
@property (copy, nonatomic) NSMutableArray* dependentKeyPaths;
@property (copy, nonatomic) NSString* mustEqualKeyPath;
@property (readonly, nonatomic) CItem* rootItem;
@property (readonly, nonatomic) NSString* jsonRepresentation;

@property (readonly, nonatomic) NSIndexSet *indexesOfSelectedSubitems;
@property (readonly, nonatomic) NSArray *selectedSubitems;

@property (nonatomic) BOOL printHierarchyAfterValidate;

- (id)initWithDictionary:(NSDictionary*)dict;
- (id)initWithJSONRepresentation:(NSString*)json;
+ (CItem*)newItem;
+ (CItem*)newItemWithDictionary:(NSDictionary*)dict;
+ (CItem*)newItemWithJSONRepresentation:(NSString*)json;
+ (CItem*)newItemForResourceName:(NSString*)resourceName withExtension:(NSString*)extension;
+ (CItem*)newItemForResourceName:(NSString*)resourceName;
+ (CItem*)newItemWithTitle:(NSString*)title key:(NSString*)key value:(id)value;

// Override in subclasses.
- (void)setup;
- (BOOL)isEmpty;
- (NSError*)validate;
- (void)validateWithCompletion:(void (^)(NSError* error))completion;
- (NSArray*)descriptionStringsCompact:(BOOL)compact;
- (BOOL)didSelect; // return of YES (the default) indicates immediate deselection
- (void)activate;
- (void)deactivate;

- (NSString*)keyPathRelativeToItem:(CItem*)ancestorItem;
- (void)addSubitem:(CItem*)item;
- (void)addSubitems:(NSArray*)items;
- (void)removeFromSuperitem;
- (CItem*)subitemForKey:(NSString*)key;
- (NSUInteger)indexOfSubitemForKey:(NSString*)key;
- (void)activateAll;
- (void)deactivateAll;

- (void)printHierarchy;

- (NSArray*)tableRowItems;

- (void)setValuesFromDummyValuesHierarchical:(BOOL)hierarchical;

@end

typedef void (^citem_block_t)(CItem *);
