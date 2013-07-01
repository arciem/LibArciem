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

#import "CItem.h"

@interface CTableRowItem : CItem

@property (readonly, nonatomic) CItem* model;
@property (readonly, nonatomic) NSArray* models;
@property (strong, nonatomic) NSString* cellType;
@property (copy, nonatomic) NSMutableDictionary* textLabelAttributes;
@property (readonly, nonatomic) NSString* defaultCellType;
@property (readonly, nonatomic) BOOL isUnselectable;
@property (nonatomic) BOOL isDeletable;
@property (nonatomic) BOOL isReorderable;
@property (nonatomic) NSInteger indentationLevel;

- (id)initWithKey:(NSString*)key title:(NSString*)title models:(NSArray*)models;
- (id)initWithKey:(NSString*)key title:(NSString*)title model:(CItem*)model;

@end
