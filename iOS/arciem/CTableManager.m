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

@interface CTableManager ()

@property (strong, nonatomic) NSDictionary* model;

@end

@implementation CTableManager

@synthesize modelURL = modelURL_;
@synthesize model = model_;
@synthesize tableView = tableView_;
@synthesize delegate = delegate_;

- (void)setup
{
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

- (NSURL*)modelURL
{
	return modelURL_;
}

- (void)setModelURL:(NSURL *)modelURL
{
	if(!Same(modelURL_, modelURL)) {
		modelURL_ = modelURL;
		self.model = [NSJSONSerialization JSONObjectWithURL:modelURL_ options:NSJSONReadingMutableContainers error:nil];

		[self.tableView reloadData];
	}
}

- (NSMutableArray*)orderedSectionKeys
{
	return [self.model objectForKey:@"orderedSectionKeys"];
}

- (NSMutableDictionary*)sectionForKey:(NSString*)sectionKey
{
	return [[self.model objectForKey:@"sections"] objectForKey:sectionKey];
}

- (NSString*)sectionKeyAtIndex:(NSUInteger)sectionIndex
{
	return [[self orderedSectionKeys] objectAtIndex:sectionIndex];
}

- (NSMutableDictionary*)sectionAtIndex:(NSUInteger)sectionIndex
{
	return [self sectionForKey:[self sectionKeyAtIndex:sectionIndex]];
}

- (NSMutableArray*)orderedRowKeysForSection:(NSDictionary*)section
{
	return [section objectForKey:@"orderedRowKeys"];
}

- (NSMutableArray*)orderedRowKeysForSectionAtIndex:(NSUInteger)sectionIndex
{
	return [self orderedRowKeysForSection:[self sectionAtIndex:sectionIndex]];
}

- (NSString*)rowKeyAtIndexPath:(NSIndexPath*)indexPath
{
	return [[self orderedRowKeysForSectionAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSMutableDictionary*)rowForKey:(NSString*)rowKey
{
	return [[self.model objectForKey:@"rows"] objectForKey:rowKey];
}

- (NSMutableDictionary*)rowAtIndexPath:(NSIndexPath*)indexPath
{
	return [self rowForKey:[self rowKeyAtIndexPath:indexPath]];
}

- (NSUInteger)indexOfSectionForKey:(NSString*)sectionKey
{
	return [[self orderedSectionKeys] indexOfObject:sectionKey];
}

- (NSIndexPath*)indexPathOfRowForKey:(NSString*)rowKey
{
	NSIndexPath* result = nil;
	
	NSUInteger sectionIndex = 0;
	for(NSString* sectionKey in [self orderedSectionKeys]) {
		NSDictionary* sectionDict = [self sectionForKey:sectionKey];
		NSArray* orderedRowKeys = [self orderedRowKeysForSection:sectionDict];
		NSUInteger rowIndex = 0;
		for(NSString* aRowKey in orderedRowKeys) {
			if([aRowKey isEqual:rowKey]) {
				result = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
				break;
			}
			rowIndex++;
		}
		if(result != nil) {
			break;
		}
		sectionIndex++;
	}
	
	return result;
}

- (void)deleteRowWithKey:(NSString*)key withRowAnimation:(UITableViewRowAnimation)animation
{
	NSIndexPath* indexPath = [self indexPathOfRowForKey:key];
	if(indexPath != nil) {
		NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
		NSMutableArray* keys = [self orderedRowKeysForSectionAtIndex:indexPath.section];
		[keys removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
	}
}

- (void)replaceSectionAtIndex:(NSUInteger)sectionIndex withSectionWithKey:(NSString*)newSectionKey
{
	NSMutableArray* orderedSectionKeys = [self orderedSectionKeys];
	[orderedSectionKeys replaceObjectAtIndex:sectionIndex withObject:newSectionKey];
	NSIndexSet* sectionIndexes = [NSIndexSet indexSetWithIndex:sectionIndex];
	[self.tableView reloadSections:sectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)replaceSectionWithKey:(NSString*)oldSectionKey withSectionWithKey:(NSString*)newSectionKey
{
	NSUInteger sectionIndex = [self indexOfSectionForKey:oldSectionKey];
	if(sectionIndex != NSNotFound) {
		[self replaceSectionAtIndex:sectionIndex withSectionWithKey:newSectionKey];
	}
}

- (void)clearSelectionAnimated:(BOOL)animated
{
	for(NSIndexPath* indexPath in [self.tableView indexPathsForSelectedRows]) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self orderedSectionKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self sectionAtIndex:section] objectForKey:@"headerTitle"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self orderedRowKeysForSectionAtIndex:section] count];
}

- (void)applyAttributes:(NSDictionary*)attributes toLabel:(UILabel*)label
{
	static NSDictionary* switchDict = nil;
	if(switchDict == nil) {
		switchDict = [NSDictionary dictionaryWithKeysAndObjects:
					  @"adjustsFontSizeToFitWidth",
					  ^(UILabel* lbl, id value) {
						  lbl.adjustsFontSizeToFitWidth = [value boolValue];
					  },
					  @"minimumFontSize",
					  ^(UILabel* lbl, id value) {
						  lbl.minimumFontSize = [value floatValue]; 
					  },
					  @"fontSize",
					  ^(UILabel* lbl, id value) {
						  lbl.font = [UIFont fontWithName:lbl.font.fontName size:[value floatValue]];
					  },
					  @"textColor",
					  ^(UILabel* lbl, id value) {
						  lbl.textColor = [UIColor colorWithString:(NSString*)value];
					  },
					  nil];
	}
	for(NSString* key in attributes) {
		void (^caseBlock)(UILabel*, id) = [switchDict objectForKey:key];
		NSAssert1(caseBlock != NULL, @"No case found for key '%@'", key);
		id value = [attributes objectForKey:key];
		caseBlock(label, value);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* reuseIdentifier = @"identifier";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}

	NSDictionary* row = [self rowAtIndexPath:indexPath];

	static NSDictionary* accessoryTypeSymbols = nil;
	if(accessoryTypeSymbols == nil) {
		accessoryTypeSymbols = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithUnsignedInt:UITableViewCellAccessoryNone], @"none",
								[NSNumber numberWithUnsignedInt:UITableViewCellAccessoryDisclosureIndicator], @"disclosureIndicator",
								[NSNumber numberWithUnsignedInt:UITableViewCellAccessoryDetailDisclosureButton], @"detailDisclosureButton",
								[NSNumber numberWithUnsignedInt:UITableViewCellAccessoryCheckmark], @"checkmark",
								nil];
	}
	NSNumber* accessoryTypeNumber = [accessoryTypeSymbols objectForKey:[row objectForKey:@"accessory"]];
	cell.accessoryType = (UITableViewCellAccessoryType)[accessoryTypeNumber unsignedIntValue];
	
	cell.textLabel.text = [row objectForKey:@"text"];
	
	[self applyAttributes:[self.model objectForKey:@"textLabel"] toLabel:cell.textLabel];
	[self applyAttributes:[row objectForKey:@"textLabel"] toLabel:cell.textLabel];
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary* row = [self rowAtIndexPath:indexPath];
	[self.delegate tableManager:self didSelectRow:row atIndexPath:indexPath];
}

@end
