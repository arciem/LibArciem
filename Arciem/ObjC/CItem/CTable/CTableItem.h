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
#import "CTableSectionItem.h"
#import "CTableSpacerItem.h"

@protocol CTableItemDelegate;

@interface CTableItem : CItem

@property (copy, nonatomic) NSMutableDictionary* textLabelAttributes;
@property (weak, nonatomic) id<CTableItemDelegate> delegate;

+ (CTableItem*)item;

- (void)tableSectionItem:(CTableSectionItem*)tableSectionItem rowsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes;
- (void)tableRowItem:(CTableRowItem*)rowItem didChangeHiddenFrom:(BOOL)fromHidden to:(BOOL)toHidden;

@end

@protocol CTableItemDelegate <NSObject>

@required
- (void)tableItem:(CTableItem*)tableItem sectionsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes;
- (void)tableSectionItem:(CTableSectionItem*)tableSectionItem rowsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes;
- (void)tableRowItem:(CTableRowItem*)rowItem didChangeHiddenFrom:(BOOL)fromHidden to:(BOOL)toHidden;

@end