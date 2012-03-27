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

#import "CFormTableView.h"
#import "StringUtils.h"
#import "CTitleTableItem.h"
#import "CBooleanItem.h"
#import "CTableBooleanItem.h"
#import "CRepeatingItem.h"
#import "CTableAddRepeatingItem.h"

@interface CFormTableView ()

@property (strong, nonatomic) CTableManager* tableManager;

@end

@implementation CFormTableView

@synthesize model = model_;
@synthesize tableManager = tableManager_;
@synthesize cellClassSubstitutions = cellClassSubstitutions_;

+ (void)initialize
{
//	CLogSetTagActive(@"FORM_TABLE_VIEW", YES);
}

- (void)setup
{
	NSAssert1(self.tableManager == nil, @"setup should only be called once: %@", self);
	self.tableManager = [[CTableManager alloc] init];
	self.tableManager.cachesAllCells = YES;
	self.tableManager.tableView = self;
	self.tableManager.delegate = self;
	self.dataSource = self.tableManager;
	self.delegate = self.tableManager;
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	if(self = [super initWithFrame:frame style:style]) {
		[self setup];
	}
	
	return self;
}

- (void)dealloc
{
	CLogTrace(@"FORM_TABLE_VIEW", @"%@ dealloc", self);
}

- (CItem*)model
{
	return model_;
}

- (CTableItem*)tableItemForModel:(CItem*)model
{
	CTableItem* tableItem = [CTableItem item];

	CTableSectionItem* sectionItem = [CTableSectionItem item];
	[tableItem addSubitem:sectionItem];
	
	if(!IsEmptyString(model.title)) {
		CTableRowItem* rowItem = [CTitleTableItem itemWithKey:model.key title:model.title item:model];
		[sectionItem addSubitem:rowItem];
	}

	for(CItem* modelItem in model.subitems) {
		NSArray* rowItems = [modelItem tableRowItems];
//		NSArray* rowItems = [self tableRowItemsForModel:modelItem];
		[sectionItem addSubitems:rowItems];
	}

	return tableItem;
}

- (void)addSubstitutions:(CTableItem*)tableItem
{
	if(self.cellClassSubstitutions != nil) {
		for(CTableSectionItem* sectionItem in tableItem.subitems) {
			for(CTableRowItem* rowItem in sectionItem.subitems) {
				NSString* oldCellType = rowItem.cellType;
				NSString* newCellType = [self.cellClassSubstitutions objectForKey:oldCellType];
				if(!IsEmptyString(newCellType)) {
					rowItem.cellType = newCellType;
				}
			}
		}
	}
}

- (void)setModel:(CItem *)model
{
	if(model_ != model) {
		[model_ deactivateAll];
		model_ = model;
//		model_.printHierarchyAfterValidate = YES;
		CTableItem* tableModel = nil;
		if(model != nil) {
			tableModel = [self tableItemForModel:model_];
			[self addSubstitutions:tableModel];
			[tableModel activateAll];
		}
		self.tableManager.model = tableModel;
	}
}

#pragma mark - CTableManagerDelegate

- (void)tableManager:(CTableManager*)tableManager didSelectRow:(CTableRowItem*)row atIndexPath:(NSIndexPath *)indexPath
{
	void (^deselect)(void) = ^{
		[tableManager.tableView deselectRowAtIndexPath:indexPath animated:YES];
	};
	
	if([row isKindOfClass:[CTableBooleanItem class]]) {
		CBooleanItem* item = (CBooleanItem*)row.model;
		BOOL shouldDeselect = [item didSelect];
		if(shouldDeselect) {
			deselect();
		}
	} else if([row isKindOfClass:[CTableAddRepeatingItem class]]) {
		CRepeatingItem* repeatingItem = (CRepeatingItem*)row.model;
		deselect();
		[repeatingItem addSubitemFromTemplate];
	}
}

@end
