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

#import "CTableManager.h"
#import "ObjectUtils.h"
#import "JSONUtils.h"
#import "UIColorUtils.h"
#import "StringUtils.h"
#import "CRowItemTableViewCell.h"
#import "UIViewUtils.h"
#import "CSlowCall.h"
#import "CRepeatingItem.h"
#import "DeviceUtils.h"

@interface CTableManager () <CRowItemTableViewCellDelegate, CTableItemDelegate>

@property (nonatomic) NSArray *visibleSections;
@property (nonatomic) NSMutableDictionary *visibleRowsBySection;
@property (readonly, nonatomic) CSlowCall *scrollToRowSlowCall;

@end

@implementation CTableManager

@synthesize model = _model;
@synthesize cachesAllCells = _cachesAllCells;
@synthesize scrollToRowSlowCall = _scrollToRowSlowCall;

+ (void)initialize
{
//	CLogSetTagActive(@"C_TABLE_MANAGER", YES);
}

- (void)setup
{
	CLogDebug(@"C_TABLE_MANAGER", @"%@ setup", self);
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)init
{
	if(self = [super init]) {
		[self setup];
	}
	
	return self;
}

- (void)dealloc
{
	CLogDebug(@"C_TABLE_MANAGER", @"%@ dealloc", self);
	self.model = nil;
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (CTableItem*)model
{
	return _model;
}

- (void)setModel:(CTableItem*)model
{
	if(!Same(_model, model)) {
		[self invalidateAllCachedCells];
		_model.delegate = nil;
		_model = model;
		if(_model != nil) {
			_model.delegate = self;
			[self.tableView reloadData];
		}
	}
}

- (NSUInteger)indexOfSectionForKey:(NSString*)key
{
	NSUInteger result = NSNotFound;
	
	NSUInteger sectionIndex = 0;
	for(CTableSectionItem *section in self.sections) {
		if([key isEqualToString:section.key]) {
			result = sectionIndex;
			break;
		}
		sectionIndex++;
	}
	
	return result;
}

- (CTableSectionItem*)sectionForKey:(NSString*)key
{
	CTableSectionItem *result = nil;
	
	NSUInteger sectionIndex = [self indexOfSectionForKey:key];
	if(sectionIndex != NSNotFound) {
		result = (self.sections)[sectionIndex];
	}
	
	return result;
}

- (NSUInteger)indexOfRowForKey:(NSString*)key inSection:(NSUInteger)sectionIndex
{
	NSUInteger result = NSNotFound;
	
	NSUInteger rowIndex = 0;
	for(CTableRowItem *row in [self rowsForSection:sectionIndex]) {
		if([key isEqualToString:row.key]) {
			result = rowIndex;
			break;
		}
		rowIndex++;
	}
	
	return result;
}

- (NSIndexPath*)indexPathOfRowForKeyPath:(NSString*)keyPath
{
	NSIndexPath *result = nil;
	
	NSArray *comps = [keyPath componentsSeparatedByString:@"."];
	NSString *sectionKey = comps[0];
	NSUInteger sectionIndex = [self indexOfSectionForKey:sectionKey];
	if(sectionIndex != NSNotFound) {
		NSString *rowKey = comps[1];
		NSUInteger rowIndex = [self indexOfRowForKey:rowKey inSection:sectionIndex];
		if(rowIndex != NSNotFound) {
			result = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
		}
	}
	
	return result;
}

- (CTableRowItem*)rowForKeyPath:(NSString*)keyPath
{
	CTableRowItem *result = nil;
	
	NSIndexPath *indexPath = [self indexPathOfRowForKeyPath:keyPath];
	if(indexPath != nil) {
		result = [self rowAtIndexPath:indexPath];
	}
	
	return result;
}

- (void)setRowForKeyPath:(NSString*)keyPath disabled:(BOOL)disabled withRowAnimation:(UITableViewRowAnimation)animation
{
	NSIndexPath *indexPath = [self indexPathOfRowForKeyPath:keyPath];
	if(indexPath != nil) {
		CTableRowItem *row = [self rowAtIndexPath:indexPath];
		if(row.disabled != disabled) {
			row.disabled = disabled;
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
		}
	}
}

- (NSIndexPath*)indexPathForRow:(CTableRowItem*)rowItem
{
	__block NSIndexPath *indexPath = nil;
	[self.visibleSections enumerateObjectsUsingBlock:^(CTableSectionItem *sectionItem, NSUInteger sectionIndex, BOOL *stop) {
		NSArray *rows = [self rowsForSection:sectionIndex];
		[rows enumerateObjectsUsingBlock:^(CTableRowItem *aRowItem, NSUInteger rowIndex, BOOL *stop) {
			if(aRowItem == rowItem) {
				indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
				*stop = YES;
			}
		}];
		
		if(indexPath != nil) {
			*stop = YES;
		}
	}];
	
	return indexPath;
}

- (NSIndexPath*)indexPathForModel:(CItem*)model
{
	__block NSIndexPath *indexPath = nil;
	
	if(model != nil) {
		[self.sections enumerateObjectsUsingBlock:^(CTableSectionItem *sectionItem, NSUInteger sectionIndex, BOOL *stop) {
			NSArray *rows = [self rowsForSection:sectionIndex];
			[rows enumerateObjectsUsingBlock:^(CTableRowItem *rowItem, NSUInteger rowIndex, BOOL *stop) {
				NSArray *models = rowItem.models;
				[models enumerateObjectsUsingBlock:^(CItem *item, NSUInteger idx, BOOL *stop) {
					if(item == model) {
						indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
						*stop = YES;
					}
				}];
				
				if(indexPath != nil) {
					*stop = YES;
				}
			}];
			
			if(indexPath != nil) {
				*stop = YES;
			}
		}];
	}
	
	return indexPath;
}

- (NSIndexPath*)indexPathForShowingHiddenRow:(CTableRowItem*)rowItem
{
	NSIndexPath *indexPath = nil;
	
	CTableSectionItem *sectionItem = (CTableSectionItem*)rowItem.superitem;
	NSUInteger sectionIndex = [self.visibleSections indexOfObject:sectionItem];
	if(sectionIndex != NSNotFound) {
		NSArray *rows = sectionItem.visibleSubitems;
		NSUInteger rowIndex = [rows indexOfObject:rowItem];
		if(rowIndex != NSNotFound) {
			indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
		}
	}
	
	return indexPath;
}

- (void)setRow:(CTableRowItem*)rowItem hidden:(BOOL)hidden withRowAnimation:(UITableViewRowAnimation)animation
{
	if(hidden) {
		NSIndexPath *indexPath = [self indexPathForRow:rowItem];
		if(indexPath != nil) {
			[self invalidateRowAtIndexPath:indexPath];
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
		}
	} else {
		NSIndexPath *indexPath = [self indexPathForShowingHiddenRow:rowItem];
		if(indexPath != nil) {
			[self invalidateRowsForSection:indexPath.section];
			[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
		}
	}
}

- (void)replaceSectionAtIndex:(NSUInteger)leavingSectionIndex withSectionWithKey:(NSString*)newSectionKey
{
	CTableSectionItem *leavingSection = [self sectionForIndex:leavingSectionIndex];
	leavingSection.hidden = YES;
	
	CTableSectionItem *enteringSection = [self.model valueForKey:newSectionKey];
	enteringSection.hidden = NO;

	[self invalidateCache];

	NSUInteger enteringSectionIndex = [self indexOfSectionForKey:newSectionKey];
	
	NSAssert2(enteringSectionIndex == leavingSectionIndex, @"Need adjacent sections in model. entering:%d leaving:%d", enteringSectionIndex, leavingSectionIndex);
	NSIndexSet *sectionIndexes = [NSIndexSet indexSetWithIndex:enteringSectionIndex];
	[self.tableView reloadSections:sectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)clearSelectionAnimated:(BOOL)animated
{
	for(NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
	}
}

- (void)invalidateCache
{
	self.visibleSections = nil;
	self.visibleRowsBySection = nil;
}

- (NSArray*)sections
{
	if(self.visibleSections == nil) {
		self.visibleSections = self.model.visibleSubitems;
	}
	return self.visibleSections;
}

- (CTableSectionItem*)sectionForIndex:(NSUInteger)sectionIndex
{
	return (self.sections)[sectionIndex];
}

- (NSMutableArray*)rowsForSection:(NSUInteger)sectionIndex
{
	NSNumber *sectionIndexNumber = @(sectionIndex);
	NSMutableDictionary *dict = self.visibleRowsBySection;
	if(dict == nil) {
		dict = [NSMutableDictionary dictionary];
		self.visibleRowsBySection = dict;
	}
	NSMutableArray *rows = dict[sectionIndexNumber];
	if(rows == nil) {
		CTableSectionItem *section = [self sectionForIndex:sectionIndex];
		rows = [section.visibleSubitems mutableCopy];
		dict[sectionIndexNumber] = rows;
	}
	return rows;
}

- (void)invalidateRowsForSection:(NSUInteger)sectionIndex
{
	NSNumber *sectionIndexNumber = @(sectionIndex);
	[self.visibleRowsBySection removeObjectForKey:sectionIndexNumber];
}

- (void)invalidateRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSNumber *sectionIndexNumber = @((NSUInteger)indexPath.section);
	NSMutableArray *rows = (self.visibleRowsBySection)[sectionIndexNumber];
	if(rows != nil) {
		[rows removeObjectAtIndex:indexPath.row];
	}
}

- (CTableRowItem*)rowAtIndexPath:(NSIndexPath*)indexPath
{
	NSArray *rows = [self rowsForSection:indexPath.section];
	return rows[indexPath.row];
}

- (CSlowCall*)scrollToRowSlowCall
{
	if(_scrollToRowSlowCall == nil) {
		_scrollToRowSlowCall = [CSlowCall slowCallWithDelay:0.5 target:self selector:@selector(scrollToRowAtIndexPath:)];
	}
	
	return _scrollToRowSlowCall;
}

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath
{
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)reloadTableData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self sectionForIndex:section].title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self rowsForSection:section].count;
}

- (CRowItemTableViewCell*)createCellWithCellType:(NSString*)cellType reuseIdentifier:(NSString*)reuseIdentifier
{
	CRowItemTableViewCell *cell = nil;
	cell = (CRowItemTableViewCell*)ClassAlloc(cellType);
	cell = [cell initWithReuseIdentifier:reuseIdentifier];
	cell.delegate = self;
    if([self.delegate respondsToSelector:@selector(tableManager:prepareCell:)]) {
        [self.delegate tableManager:self prepareCell:cell];
    }
	return cell;
}

- (CRowItemTableViewCell*)cachedCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	CRowItemTableViewCell *cell = nil;
	
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	cell = (rowItem.dict)[@"cell"];
	
	return cell;
}

- (void)setCachedCell:(CRowItemTableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	(rowItem.dict)[@"cell"] = cell; 
}

- (void)invalidateAllCachedCells
{
	for(CTableSectionItem *sectionItem in self.model.subitems) {
		for(CTableRowItem *rowItem in sectionItem.subitems) {
			[rowItem.dict removeObjectForKey:@"cell"];
		}
	}
}

- (BOOL)cachesAllCells
{
	return _cachesAllCells;
}

- (void)setCachesAllCells:(BOOL)cachesAllCells
{
	if(_cachesAllCells != cachesAllCells) {
		_cachesAllCells = cachesAllCells;
		if(_cachesAllCells == NO) {
			[self invalidateAllCachedCells];
		}
	}
}

- (CRowItemTableViewCell *)createCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CRowItemTableViewCell *cell = nil;
	
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	NSString *cellType = rowItem.cellType;
	NSString *reuseIdentifier = cellType;
	cell = [self createCellWithCellType:cellType reuseIdentifier:reuseIdentifier];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CRowItemTableViewCell *cell = nil;
	
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	NSString *cellType = rowItem.cellType;
	NSString *reuseIdentifier = cellType;
	cell = [self cachedCellForRowAtIndexPath:indexPath];
	if(cell == nil) {
		cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
		if(cell == nil) {
			cell = [self createCellForRowAtIndexPath:indexPath];
			if(self.cachesAllCells) {
				[self setCachedCell:cell forRowAtIndexPath:indexPath];
			}
		}
		cell.rowItem = rowItem;
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = tableView.rowHeight;

    CRowItemTableViewCell *cell = [self cachedCellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [self createCellForRowAtIndexPath:indexPath];
        if(self.cachesAllCells) {
            [self setCachedCell:cell forRowAtIndexPath:indexPath];
        }
    }
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	cell.rowItem = rowItem;
	cell.cframe.size = CGSizeMake(tableView.width, result);
	[cell layoutIfNeeded];
	[cell sizeToFit];
	result = cell.height;

	return result;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
//	CLogDebug(nil, @"%@ canMoveRowAtIndexPath:%@ value:%d", self, indexPath, rowItem.reorderable);
	return rowItem.reorderable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
//	CLogDebug(nil, @"moveRowAtIndexPath:%@ toIndexPath:%@", sourceIndexPath, destinationIndexPath);
	NSAssert(sourceIndexPath.section == destinationIndexPath.section, @"Moving between sections unsupported.");

	NSInteger moveOffset = destinationIndexPath.row - sourceIndexPath.row;

	NSMutableArray *sourceRows = [self rowsForSection:sourceIndexPath.section];
	CTableRowItem *rowItem = sourceRows[sourceIndexPath.row];
	CTableSectionItem *sectionItem = (CTableSectionItem*)rowItem.superitem;
	NSUInteger rowIndex = [sectionItem.subitems indexOfObject:rowItem];
	NSUInteger rowDestinationIndex = rowIndex + moveOffset;
	
	sectionItem.isReordering = YES;
	[sectionItem.subitems removeObject:rowItem];
	[sectionItem.subitems insertObject:rowItem atIndex:rowDestinationIndex];
	sectionItem.isReordering = NO;

	CItem *modelItem = rowItem.model;
	CRepeatingItem *repeatingItem = (CRepeatingItem*)modelItem.superitem;
	NSUInteger modelItemIndex = [repeatingItem.subitems indexOfObject:modelItem];
	NSUInteger modelDestinationIndex = modelItemIndex + moveOffset;

	repeatingItem.isReordering = YES;
	[repeatingItem.subitems removeObject:modelItem];
	[repeatingItem.subitems insertObject:modelItem atIndex:modelDestinationIndex];
	repeatingItem.isReordering = NO;
	
	[self invalidateRowsForSection:sourceIndexPath.section];
	
    if([self.delegate respondsToSelector:@selector(tableManager:didMoveRow:toIndexPath:)]) {
        [self.delegate tableManager:self didMoveRow:rowItem toIndexPath:destinationIndexPath];
    }
    
//	[self.model printHierarchy];
//	[repeatingItem printHierarchy];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSAssert1(editingStyle == UITableViewCellEditingStyleDelete, @"Unimplemented editing style:%d", editingStyle);
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	[rowItem.model removeFromSuperitem];
    if([self.delegate respondsToSelector:@selector(tableManager:didDeleteRow:atIndexPath:)]) {
        [self.delegate tableManager:self didDeleteRow:rowItem atIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	NSIndexPath *result = nil;
	
	NSUInteger sourceSectionIndex = sourceIndexPath.section;
	NSUInteger proposedSectionIndex = proposedDestinationIndexPath.section;
	NSMutableIndexSet *allowedIndexes = [NSMutableIndexSet indexSet];
	NSArray *rows = [self rowsForSection:sourceSectionIndex];
	[rows enumerateObjectsUsingBlock:^(CTableRowItem *row, NSUInteger idx, BOOL *stop) {
		if(row.reorderable) {
			[allowedIndexes addIndex:idx];
		}
	}];
	
	NSUInteger proposedRowIndex = proposedDestinationIndexPath.row;
	if(proposedRowIndex < allowedIndexes.firstIndex) {
		proposedRowIndex = allowedIndexes.firstIndex;
	} else if(proposedRowIndex > allowedIndexes.lastIndex) {
		proposedRowIndex = allowedIndexes.lastIndex;
	}
	
	result = [NSIndexPath indexPathForRow:proposedRowIndex inSection:proposedSectionIndex];

	return result;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *result = indexPath;
	
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	if(!rowItem.rowSelectable) {
		result = nil;
	}
	
	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
    if([self.delegate respondsToSelector:@selector(tableManager:didSelectRow:atIndexPath:)]) {
        [self.delegate tableManager:self didSelectRow:rowItem atIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;
	
	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	if(rowItem.isDeletable) {
		result = UITableViewCellEditingStyleDelete;
	}
	
	return result;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL result = NO;

	CTableRowItem *rowItem = [self rowAtIndexPath:indexPath];
	if(rowItem.isDeletable) {
		result = YES;
	}

	return result;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(IsOSVersionAtLeast7()) {
        UIColor *tintColor = self.tableView.tintColor;
        [cell visitAllDescendentViewsWithBlock:^(UIView *view) {
            if(view.inputView != nil) {
                view.inputView.tintColor = tintColor;
            }
            if(view.inputAccessoryView != nil) {
                view.inputAccessoryView.tintColor = tintColor;
            }
        }];
    }
}

#pragma mark - @protocol CTableItemDelegate

- (void)tableItem:(CTableItem*)tableItem sectionsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes
{
//	CLogDebug(nil, @"tableItem:%@ sectionsDidChangeWithNew:%@ old:%@ kind:%d indexes:%@", tableItem, newItems, oldItems, kind, indexes);
	NSAssert(false, @"Unimplemented.");
}

- (void)tableSectionItem:(CTableSectionItem*)tableSectionItem rowsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes
{
//	CLogDebug(nil, @"tableSectionItem:%@ rowsDidChangeWithNew:%@ old:%@ kind:%d indexes:%@", tableSectionItem, newItems, oldItems, kind, indexes);
	switch (kind) {
		case NSKeyValueChangeInsertion: {
			NSUInteger sectionIndex = [self.sections indexOfObject:tableSectionItem];
			NSAssert(sectionIndex != NSNotFound, @"Couldn't find section.");
			NSMutableArray *indexPaths = [NSMutableArray array];
			[indexes enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL *stop) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
			}];
			[self invalidateRowsForSection:sectionIndex];
			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
		} break;
		case NSKeyValueChangeRemoval: {
			NSUInteger sectionIndex = [self.sections indexOfObject:tableSectionItem];
			NSAssert(sectionIndex != NSNotFound, @"Couldn't find section.");
			NSMutableArray *indexPaths = [NSMutableArray array];
			[indexes enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL *stop) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
			}];
			[self invalidateRowsForSection:sectionIndex];
			[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
		} break;
		default:
			NSAssert1(false, @"Unimplemented change kind:%d", kind);
			break;
	}
}

- (void)tableRowItem:(CTableRowItem*)rowItem didChangeHiddenFrom:(BOOL)fromHidden to:(BOOL)toHidden
{
//	CLogDebug(nil, @"%@ tableRowItem:%@ didChangeHiddenFrom:%d to:%d", self, rowItem, fromHidden, toHidden);
	[self setRow:rowItem hidden:rowItem.hidden withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - @protocol CRowItemTableViewCellDelegate

- (void)rowItemTableViewCellDidGainFocus:(CRowItemTableViewCell *)cell
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if(indexPath != nil) {
		[self.scrollToRowSlowCall armWithObject:indexPath];
	}
}

@end
