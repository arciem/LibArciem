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
@property (strong, nonatomic) NSMutableArray* observers;

@end

@implementation CFormTableView

@synthesize model = model_;
@synthesize tableManager = tableManager_;
@synthesize cellClassSubstitutions = cellClassSubstitutions_;
@synthesize observers = observers_;

+ (void)initialize
{
//	CLogSetTagActive(@"FORM_TABLE_VIEW", YES);
}

- (void)setup
{
	NSAssert1(self.tableManager == nil, @"setup should only be called once: %@", self);
	self.tableManager = [[CTableManager alloc] init];
	self.tableManager.tableView = self;
	self.tableManager.delegate = self;
	self.dataSource = self.tableManager;
	self.delegate = self.tableManager;
	self.observers = [NSMutableArray array];
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

#if 0
- (NSArray*)tableRowItemsForModel:(CItem*)model
{
	NSMutableArray* rowItems = [NSMutableArray array];

	if([model isKindOfClass:[CCreditCardItem class]]) {
		CCreditCardItem* ccItem = (CCreditCardItem*)model;
		CTableCreditCardItem* rowItem = [CTableCreditCardItem itemWithKey:ccItem.key title:ccItem.title creditCardItem:ccItem];
		[rowItems addObject:rowItem];
	} else if([model isKindOfClass:[CStringItem class]]) {
		CTableTextFieldItem* rowItem = [CTableTextFieldItem itemWithKey:model.key title:model.title stringItem:(CStringItem*)model];
		[rowItems addObject:rowItem];
	} else if([model isKindOfClass:[CMultiChoiceItem class]]) {
		CTableMultiChoiceItem* rowItem = [CTableMultiChoiceItem itemWithKey:model.key title:model.title multiChoiceItem:(CMultiChoiceItem*)model];
		[rowItems addObject:rowItem];
		for(CBooleanItem* item in model.subitems) {
			CTableBooleanItem* rowItem = [CTableBooleanItem itemWithKey:item.key title:item.title booleanItem:item];
			[rowItems addObject:rowItem];
		}
	} else if([model isKindOfClass:[CMultiTextItem class]] && model.subitems.count == 2) {
		CTableTextFieldItem* rowItem = [CTableTextFieldItem itemWithKey:model.key title:model.title stringItems:model.subitems];
		[rowItems addObject:rowItem];
	} else if([model isKindOfClass:[CSubmitItem class]]) {
		CTableButtonItem* rowItem = [CTableButtonItem itemWithKey:model.key title:model.title item:model];
		[rowItems addObject:rowItem];
	} else if([model isKindOfClass:[CRepeatingItem class]]) {
		CRepeatingItem* repeatingItem = (CRepeatingItem*)model;
		for(CItem* initialItem in repeatingItem.subitems) {
			NSArray* newRowItems = [self tableRowItemsForModel:initialItem];
			for(CTableRowItem* rowItem in newRowItems) {
				[rowItems addObject:rowItem];
			}
		}
		CTableAddRepeatingItem* endRepeatRowItem = [CTableAddRepeatingItem itemWithKey:model.key title:model.title repeatingItem:repeatingItem];
		[rowItems addObject:endRepeatRowItem];
		__weak CFormTableView* self__ = self;
		CObserverBlock action = ^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
//			CLogDebug(nil, @"newValue:%@ oldValue:%@ kind:%d indexes:%@", newValue, oldValue, kind, indexes);
			if(kind == NSKeyValueChangeSetting) {
				[endRepeatRowItem.superitem.subitems removeAllObjects];
			}
			if(kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeSetting) {
				NSArray* newModels = (NSArray*)newValue;
				//				[self__.tableManager.model printHierarchy];
				NSUInteger endRepeatRowItemIndex = [endRepeatRowItem.superitem.subitems indexOfObject:endRepeatRowItem];
				NSAssert(endRepeatRowItemIndex != NSNotFound, @"Couldn't find endRepeatRowItem.");
				for(CItem* item in newModels) {
					NSArray* newRowItems = [self__ tableRowItemsForModel:item];
					NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
					NSUInteger currentIndex = endRepeatRowItemIndex;
					for(CItem* item in newRowItems) {
						[indexes addIndex:currentIndex];
						currentIndex++;
					}
					[endRepeatRowItem.superitem.subitems insertObjects:newRowItems atIndexes:indexes];
				}
				//				[self__.tableManager.model printHierarchy];
			} else {
				NSAssert1(false, @"Unimplemented change kind:%d", kind);
			}
		};
		CObserver* observer = [CObserver observerWithKeyPath:@"subitems" ofObject:repeatingItem action:action];
		[self.observers addObject:observer];
	} else if([model isKindOfClass:[CNoteItem class]]) {
		CNoteItem* noteItem = (CNoteItem*)model;
		CTableNoteItem* rowItem = [CTableNoteItem itemWithKey:noteItem.key title:noteItem.title item:noteItem];
		[rowItems addObject:rowItem];
	} else {
		NSAssert1(false, @"No known table row item for model item:%@", model);
	}

	return rowItems;
}
#endif

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
		[self.observers removeAllObjects];
		model_ = model;
		CTableItem* tableModel = nil;
		if(model != nil) {
			tableModel = [self tableItemForModel:model_];
			[self addSubstitutions:tableModel];
//			[tableModel printHierarchy];
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
