/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CRepeatingItem.h"
#import "CTableRowItem.h"
#import "CTableAddRepeatingItem.h"
#import "CObserver.h"

@interface CRepeatingItem ()

@property (weak, nonatomic) CTableAddRepeatingItem* endRepeatRowItem;
@property (strong, nonatomic) CObserver* subitemsObserver;
@property (strong, nonatomic) CObserver* isHiddenObserver;

@end

@implementation CRepeatingItem

@synthesize endRepeatRowItem = endRepeatRowItem_;
@synthesize subitemsObserver = subitemsObserver_;
@synthesize isHiddenObserver = isHiddenObserver_;
@synthesize isReordering = isReordering_;

- (void)setup
{
	[super setup];
	for(NSInteger i = 0; i < self.startRepeats; i++) {
		[self addSubitemFromTemplate];
	}
}

- (NSDictionary*)templateDict
{
	return [self.dict objectForKey:@"template"];
}

- (void)setTemplateDict:(NSDictionary *)templateDict
{
	[self.dict setObject:templateDict forKey:@"template"];
}

- (CItem*)addSubitemFromTemplate
{
	CItem* item = [CItem itemWithDictionary:self.templateDict];
	[self addSubitem:item];
	return item;
}

- (NSUInteger)minValidRepeats
{
	return [[self.dict objectForKey:@"minValidRepeats"] unsignedIntegerValue];
}

- (void)setMinValidRepeats:(NSUInteger)minValidRepeats
{
	[self.dict setObject:[NSNumber numberWithUnsignedInteger:minValidRepeats] forKey:@"minValidRepeats"];
}

- (NSUInteger)maxValidRepeats
{
	return [[self.dict objectForKey:@"maxValidRepeats"] unsignedIntegerValue];
}

- (void)setMaxValidRepeats:(NSUInteger)maxValidRepeats
{
	[self.dict setObject:[NSNumber numberWithUnsignedInteger:maxValidRepeats] forKey:@"maxValidRepeats"];
}

- (NSUInteger)startRepeats
{
	return [[self.dict objectForKey:@"startRepeats"] unsignedIntegerValue];
}

- (void)setStartRepeats:(NSUInteger)startRepeats
{
	[self.dict setObject:[NSNumber numberWithUnsignedInteger:startRepeats] forKey:@"startRepeats"];
}

- (NSString*)addAnotherPrompt
{
	return [self.dict objectForKey:@"addAnotherPrompt"];
}

- (void)setAddAnotherPrompt:(NSString *)addAnotherPrompt
{
	[self.dict setObject:[addAnotherPrompt copy] forKey:@"addAnotherPrompt"]; 
}

- (void)activate
{
	[super activate];

	CObserverBlock action = ^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		if(!self.isReordering) {
			if(kind == NSKeyValueChangeSetting) {
				[self.endRepeatRowItem.superitem.subitems removeAllObjects];
			}
			if(kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeSetting) {
				NSArray* newModels = (NSArray*)newValue;
				NSUInteger endRepeatRowItemIndex = [self.endRepeatRowItem.superitem.subitems indexOfObject:self.endRepeatRowItem];
				NSAssert(endRepeatRowItemIndex != NSNotFound, @"Couldn't find endRepeatRowItem.");
				NSAssert(newModels.count == 1, @"Only adding one at a time supported.");
				for(CItem* item in newModels) {
					NSArray* newRowItems = [item tableRowItems];
					NSAssert(newRowItems.count == 1, @"Only one item per row supported.");
					CTableRowItem* newRowItem = [newRowItems objectAtIndex:0];
					newRowItem.isDeletable = YES;
					newRowItem.isReorderable = YES;
					
					NSUInteger indexInRepeatingItem = indexes.firstIndex;
					NSUInteger indexInTable = endRepeatRowItemIndex - self.subitems.count + indexInRepeatingItem + 1;
					NSIndexSet* newIndexes = [NSIndexSet indexSetWithIndex:indexInTable];
					[self.endRepeatRowItem.superitem.subitems insertObjects:newRowItems atIndexes:newIndexes];
				}
			} else if(kind == NSKeyValueChangeRemoval) {
				NSArray* oldRowItems = (NSArray*)oldValue;
				NSUInteger endRepeatRowItemIndex = [self.endRepeatRowItem.superitem.subitems indexOfObject:self.endRepeatRowItem];
				NSAssert(endRepeatRowItemIndex != NSNotFound, @"Couldn't find endRepeatRowItem.");
				
				NSUInteger count = self.subitems.count + oldRowItems.count;
				
				NSMutableIndexSet* adjustedIndexes = [NSMutableIndexSet indexSet];
				[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
					NSUInteger index = endRepeatRowItemIndex - count + idx;
					[adjustedIndexes addIndex:index];
				}];
				[self.endRepeatRowItem.superitem.subitems removeObjectsAtIndexes:adjustedIndexes];
			} else {
				NSAssert1(false, @"Unimplemented change kind:%d", kind);
			}
		}
	};
	self.subitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self action:action];
	self.isHiddenObserver = [CObserver observerWithKeyPath:@"isHidden" ofObject:self action:^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		self.endRepeatRowItem.isHidden = [newValue boolValue];
	}];
}

- (void)deactivate
{
	self.subitemsObserver = nil;
	self.isHiddenObserver = nil;
	[super deactivate];
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	NSMutableArray* rowItems = [NSMutableArray array];
	
	for(CItem* initialItem in self.subitems) {
		NSArray* newRowItems = [initialItem tableRowItems];
		for(CTableRowItem* rowItem in newRowItems) {
			rowItem.isDeletable = YES;
			rowItem.isReorderable = YES;
			[rowItems addObject:rowItem];
		}
	}
	self.endRepeatRowItem = [CTableAddRepeatingItem itemWithKey:self.key title:self.title repeatingItem:self];
	[rowItems addObject:self.endRepeatRowItem];
	
	return rowItems;
}

@end
