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

#import <UIKit/UIKit.h>
#import "CTableItem.h"
#import "CTableRowItem.h"
#import "CTableSectionItem.h"

@protocol CTableManagerDelegate;

@interface CTableManager : NSObject<UITableViewDelegate, UITableViewDataSource, CTableItemDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) CTableItem* model;
@property (weak, nonatomic) IBOutlet id<CTableManagerDelegate> delegate;
@property (nonatomic) BOOL cachesAllCells;

- (void)clearSelectionAnimated:(BOOL)animated;
- (void)setRowForKeyPath:(NSString*)keyPath disabled:(BOOL)disabled withRowAnimation:(UITableViewRowAnimation)animation;
- (void)replaceSectionAtIndex:(NSUInteger)leavingSectionIndex withSectionWithKey:(NSString*)newSectionKey;
- (NSIndexPath*)indexPathForModel:(CItem*)model;

@end

@protocol CTableManagerDelegate <NSObject>

@required
- (void)tableManager:(CTableManager*)tableManager didSelectRow:(CTableRowItem*)rowItem atIndexPath:(NSIndexPath *)indexPath;

@end
