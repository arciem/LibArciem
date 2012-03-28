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

#import "CTableRowItem.h"
#import "ObjectUtils.h"
#import "CObserver.h"
#import "CTableSectionItem.h"

@interface CTableRowItem ()

@property (strong, nonatomic) NSMutableArray* nonretainedModels;
@property (strong, nonatomic) CObserver* isHiddenObserver;

@end

@implementation CTableRowItem

@synthesize nonretainedModels = nonretainedModels_;
@synthesize isDeletable = isDeletable_;
@synthesize isReorderable = isReorderable_;
@synthesize isHiddenObserver = isHiddenObserver_;
@dynamic model;

+ (void)initialize
{
//	CLogSetTagActive(@"C_TABLE_ROW_ITEM", YES);
}

- (id)initWithKey:(NSString*)key title:(NSString*)title models:(NSArray*)models
{
	if(self = [super init]) {
		self.nonretainedModels = [NSMutableArray arrayWithCapacity:models.count];
		[models enumerateObjectsUsingBlock:^(CItem* model, NSUInteger idx, BOOL *stop) {
			[self.nonretainedModels addObject:[NSValue valueWithNonretainedObject:model]];
		}];
		self.key = key;
		self.title = title;
		CLogTrace(@"C_TABLE_ROW_ITEM", @"%@ init", self);
	}
	return self;
}

- (id)initWithKey:(NSString*)key title:(NSString*)title model:(CItem*)model
{
	NSArray* models = nil;
	if(model != nil) {
		models = [NSArray arrayWithObject:model];
	}
	if(self = [self initWithKey:key title:title models:models]) {
	}
	
	return self;
}

- (void)dealloc
{
	CLogTrace(@"C_TABLE_ROW_ITEM", @"%@ dealloc", [self formatObjectWithValues:nil]);
}


- (void)activate
{
	[super activate];
//	CLogDebug(nil, @"%@ activate", self);
	self.isHiddenObserver = [CObserver observerWithKeyPath:@"isHidden" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[(CTableSectionItem*)self.superitem tableRowItem:self didChangeHiddenFrom:[oldValue boolValue] to:[newValue boolValue]];
	}];
}

- (void)deactivate
{
//	CLogDebug(nil, @"%@ deactivate", self);
	self.isHiddenObserver = nil;
	[super deactivate];
}

- (NSString*)cellType
{
	NSString* result = [self.dict objectForKey:@"cellType"];
	
	if(result == nil) {
		return self.defaultCellType;
	}

	return result;
}

- (void)setCellType:(NSString *)cellType
{
	[self.dict setObject:cellType forKey:@"cellType"];
}

- (NSArray*)models
{
	NSMutableArray* models = [NSMutableArray arrayWithCapacity:self.nonretainedModels.count];
	[self.nonretainedModels enumerateObjectsUsingBlock:^(NSValue* modelValue, NSUInteger idx, BOOL *stop) {
		[models addObject:[modelValue nonretainedObjectValue]];
	}];
	return [models copy];
}

- (CItem*)model
{
	CItem* result = nil;
	
	if(self.nonretainedModels.count > 0) {
		result = [[self.nonretainedModels objectAtIndex:0] nonretainedObjectValue];
	}
	
	return result;
}

#pragma mark - @property textLabel

- (NSMutableDictionary*)textLabel
{
	return [self.dict objectForKey:@"textLabel"];
}

- (void)setTextLabel:(NSMutableDictionary *)textLabel
{
	[self.dict setObject:[textLabel mutableCopy] forKey:@"textLabel"];
}

- (NSString*)defaultCellType
{
	return @"CRowItemTableViewCell";
}

- (NSArray*)descriptionStringsCompact:(BOOL)compact
{
	NSArray* strings = [super descriptionStringsCompact:YES];
	strings = [strings arrayByAddingObject:[self formatValueForKey:@"model" compact:compact]];
	strings = [strings arrayByAddingObject:[self formatValueForKey:@"indentationLevel" compact:compact]];
	return strings;
}

#pragma mark - @property isUnselectable

- (BOOL)isUnselectable
{
	return YES;
}

#pragma mark - @property indentationLevel

- (NSInteger)indentationLevel
{
	return [[self.dict objectForKey:@"indentationLevel"] integerValue];
}

- (void)setIndentationLevel:(NSInteger)indentationLevel
{
	[self.dict setObject:[NSNumber numberWithInteger:indentationLevel] forKey:@"indentationLevel"];
}

@end
