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

@interface CTableManager () <CRowItemTableViewCellDelegate>

@property (strong, nonatomic) NSArray* visibleSections;
@property (strong, nonatomic) NSMutableDictionary* visibleRowsBySection;

@end

@implementation CTableManager

@synthesize model = model_;
@synthesize tableView = tableView_;
@synthesize delegate = delegate_;
@synthesize visibleSections = visibleSections_;
@synthesize visibleRowsBySection = visibleRowsBySection_;
@synthesize cachesAllCells = cachesAllCells_;

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
}

- (CTableItem*)model
{
	return model_;
}

- (void)setModel:(CTableItem*)model
{
	if(!Same(model_, model)) {
		[self invalidateAllCachedCells];
		model_.delegate = nil;
		model_ = model;
		if(model_ != nil) {
			model_.delegate = self;
			[self.tableView reloadData];
		}
	}
}

- (NSUInteger)indexOfSectionForKey:(NSString*)key
{
	NSUInteger result = NSNotFound;
	
	NSUInteger sectionIndex = 0;
	for(CTableSectionItem* section in self.sections) {
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
	CTableSectionItem* result = nil;
	
	NSUInteger sectionIndex = [self indexOfSectionForKey:key];
	if(sectionIndex != NSNotFound) {
		result = [self.sections objectAtIndex:sectionIndex];
	}
	
	return result;
}

- (NSUInteger)indexOfRowForKey:(NSString*)key inSection:(NSUInteger)sectionIndex
{
	NSUInteger result = NSNotFound;
	
	NSUInteger rowIndex = 0;
	for(CTableRowItem* row in [self rowsForSection:sectionIndex]) {
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
	NSIndexPath* result = nil;
	
	NSArray* comps = [keyPath componentsSeparatedByString:@"."];
	NSString* sectionKey = [comps objectAtIndex:0];
	NSUInteger sectionIndex = [self indexOfSectionForKey:sectionKey];
	if(sectionIndex != NSNotFound) {
		NSString* rowKey = [comps objectAtIndex:1];
		NSUInteger rowIndex = [self indexOfRowForKey:rowKey inSection:sectionIndex];
		if(rowIndex != NSNotFound) {
			result = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
		}
	}
	
	return result;
}

- (CTableRowItem*)rowForKeyPath:(NSString*)keyPath
{
	CTableRowItem* result = nil;
	
	NSIndexPath* indexPath = [self indexPathOfRowForKeyPath:keyPath];
	if(indexPath != nil) {
		result = [self rowAtIndexPath:indexPath];
	}
	
	return result;
}

- (void)setRowForKeyPath:(NSString*)keyPath disabled:(BOOL)disabled withRowAnimation:(UITableViewRowAnimation)animation
{
	NSIndexPath* indexPath = [self indexPathOfRowForKeyPath:keyPath];
	if(indexPath != nil) {
		CTableRowItem* row = [self rowAtIndexPath:indexPath];
		if(row.isDisabled != disabled) {
			row.isDisabled = disabled;
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
		}
	}
}

- (void)replaceSectionAtIndex:(NSUInteger)leavingSectionIndex withSectionWithKey:(NSString*)newSectionKey
{
	CTableSectionItem* leavingSection = [self sectionForIndex:leavingSectionIndex];
	leavingSection.isHidden = YES;
	
	CTableSectionItem* enteringSection = [self.model valueForKey:newSectionKey];
	enteringSection.isHidden = NO;

	[self invalidateCache];

	NSUInteger enteringSectionIndex = [self indexOfSectionForKey:newSectionKey];
	
	NSAssert2(enteringSectionIndex == leavingSectionIndex, @"Need adjacent sections in model. entering:%@ leaving:%@", enteringSectionIndex, leavingSectionIndex);
	NSIndexSet* sectionIndexes = [NSIndexSet indexSetWithIndex:enteringSectionIndex];
	[self.tableView reloadSections:sectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)clearSelectionAnimated:(BOOL)animated
{
	for(NSIndexPath* indexPath in [self.tableView indexPathsForSelectedRows]) {
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
	return [self.sections objectAtIndex:sectionIndex];
}

- (NSArray*)rowsForSection:(NSUInteger)sectionIndex
{
	NSNumber* sectionIndexNumber = [NSNumber numberWithUnsignedInteger:sectionIndex];
	NSMutableDictionary* dict = self.visibleRowsBySection;
	if(dict == nil) {
		dict = [NSMutableDictionary dictionary];
		self.visibleRowsBySection = dict;
	}
	NSArray* rows = [dict objectForKey:sectionIndexNumber];
	if(rows == nil) {
		CTableSectionItem* section = [self sectionForIndex:sectionIndex];
		rows = section.visibleSubitems;
		[dict setObject:rows forKey:sectionIndexNumber];
	}
	return rows;
}

- (void)invalidateRowsForSection:(NSUInteger)sectionIndex
{
	NSNumber* sectionIndexNumber = [NSNumber numberWithUnsignedInteger:sectionIndex];
	[self.visibleRowsBySection removeObjectForKey:sectionIndexNumber];
}

- (CTableRowItem*)rowAtIndexPath:(NSIndexPath*)indexPath
{
	NSArray* rows = [self rowsForSection:indexPath.section];
	return [rows objectAtIndex:indexPath.row];
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
	CRowItemTableViewCell* cell = nil;
	cell = (CRowItemTableViewCell*)ClassAlloc(cellType);
	cell = [cell initWithReuseIdentifier:reuseIdentifier];
	cell.delegate = self;
	return cell;
}

- (CRowItemTableViewCell*)cachedCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	CRowItemTableViewCell* cell = nil;
	
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	cell = [rowItem.dict objectForKey:@"cell"];
	
	return cell;
}

- (void)setCachedCell:(CRowItemTableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	[rowItem.dict setObject:cell forKey:@"cell"]; 
}

- (void)invalidateAllCachedCells
{
	for(CTableSectionItem* sectionItem in self.model.subitems) {
		for(CTableRowItem* rowItem in sectionItem.subitems) {
			[rowItem.dict removeObjectForKey:@"cell"];
		}
	}
}

- (BOOL)cachesAllCells
{
	return cachesAllCells_;
}

- (void)setCachesAllCells:(BOOL)cachesAllCells
{
	if(cachesAllCells_ != cachesAllCells) {
		cachesAllCells_ = cachesAllCells;
		if(cachesAllCells_ == NO) {
			[self invalidateAllCachedCells];
		}
	}
}

- (CRowItemTableViewCell *)createCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CRowItemTableViewCell* cell = nil;
	
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	NSString* cellType = rowItem.cellType;
	NSString* reuseIdentifier = cellType;
	cell = [self createCellWithCellType:cellType reuseIdentifier:reuseIdentifier];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CRowItemTableViewCell* cell = nil;
	
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	NSString* cellType = rowItem.cellType;
	NSString* reuseIdentifier = cellType;
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

	CRowItemTableViewCell* cell = [self createCellForRowAtIndexPath:indexPath];
	if(self.cachesAllCells) {
		[self setCachedCell:cell forRowAtIndexPath:indexPath];
	}
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	cell.rowItem = rowItem;
	cell.size = CGSizeMake(tableView.width, result);
	[cell setNeedsLayout];
	[cell layoutIfNeeded];
	[cell sizeToFit];
	result = cell.height;

	return result;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath* result = indexPath;
	
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	if(rowItem.isUnselectable) {
		result = nil;
	}
	
	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTableRowItem* rowItem = [self rowAtIndexPath:indexPath];
	[self.delegate tableManager:self didSelectRow:rowItem atIndexPath:indexPath];
}

#pragma mark - @protocol CTableItemDelegate

- (void)tableItem:(CTableItem*)tableItem sectionsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes
{
	CLogDebug(nil, @"tableItem:%@ sectionsDidChangeWithNew:%@ old:%@ kind:%d indexes:%@", tableItem, newItems, oldItems, kind, indexes);
	NSAssert(false, @"Unimplemented.");
}

- (void)tableSectionItem:(CTableSectionItem*)tableSectionItem rowsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes
{
	CLogDebug(nil, @"tableSectionItem:%@ rowsDidChangeWithNew:%@ old:%@ kind:%d indexes:%@", tableSectionItem, newItems, oldItems, kind, indexes);
	switch (kind) {
		case NSKeyValueChangeInsertion: {
			NSUInteger sectionIndex = [self.sections indexOfObject:tableSectionItem];
			NSAssert(sectionIndex != NSNotFound, @"Couldn't find section.");
			NSMutableArray* indexPaths = [NSMutableArray array];
			[indexes enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL *stop) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
			}];
			[self invalidateRowsForSection:sectionIndex];
			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
		} break;
			
		default:
			NSAssert1(false, @"Unimplemented change kind:%d", kind);
			break;
	}
}

#pragma mark - @protocol CRowItemTableViewCellDelegate

- (void)rowItemTableViewCellDidGainFocus:(CRowItemTableViewCell *)cell
{
	NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
	if(indexPath != nil) {
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

@end
