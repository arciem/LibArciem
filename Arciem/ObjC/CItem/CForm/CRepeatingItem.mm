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
#import "CAddRepeatingTableRowItem.h"
#import "CMultiTextItem.h"
#import "CStringItem.h"
#import "CObserver.h"
#import "ObjectUtils.h"

@interface CRepeatingItem ()

@property (nonatomic) CAddRepeatingTableRowItem *endRepeatRowItem;
@property (nonatomic) CObserver *subitemsObserver;
@property (nonatomic) CObserver *hiddenObserver;

@end

@implementation CRepeatingItem

- (void)setup {
	[super setup];
}

- (NSDictionary*)templateDict {
	return (self.dict)[@"template"];
}

- (void)setTemplateDict:(NSDictionary *)templateDict {
	(self.dict)[@"template"] = templateDict;
}

- (CItem *)newItemFromTemplate {
	return [CItem newItemWithDictionary:self.templateDict];
}

- (CItem*)newSubitemFromTemplate {
	CItem *item = [self newItemFromTemplate];
//    [self insertSubitem:item atIndex:0];
	[self addSubitem:item];
	return item;
}

- (CItem *)newSubitemFromTemplateAtIndex:(NSUInteger)index {
    CItem *item = [self newItemFromTemplate];
    [self insertSubitem:item atIndex:index];
    return item;
}

- (NSUInteger)minValidRepeats {
	return [(self.dict)[@"minValidRepeats"] unsignedIntegerValue];
}

- (void)setMinValidRepeats:(NSUInteger)minValidRepeats {
	(self.dict)[@"minValidRepeats"] = @(minValidRepeats);
}

- (NSUInteger)maxValidRepeats {
	return [(self.dict)[@"maxValidRepeats"] unsignedIntegerValue];
}

- (void)setMaxValidRepeats:(NSUInteger)maxValidRepeats {
	(self.dict)[@"maxValidRepeats"] = @(maxValidRepeats);
}

- (NSUInteger)startRepeats {
	return [(self.dict)[@"startRepeats"] unsignedIntegerValue];
}

- (void)setStartRepeats:(NSUInteger)startRepeats {
	(self.dict)[@"startRepeats"] = @(startRepeats);
}

- (NSUInteger)dummyStartRepeats {
    return [(self.dict)[@"dummyStartRepeats"] unsignedIntegerValue];
}

- (void)setDummyStartRepeats:(NSUInteger)dummyStartRepeats {
	(self.dict)[@"dummyStartRepeats"] = @(dummyStartRepeats);
}

- (BOOL)hasDummyStartRepeats {
    return (self.dict)[@"dummyStartRepeats"] != nil;
}

- (NSString*)addAnotherPrompt {
	return (self.dict)[@"addAnotherPrompt"];
}

- (void)setAddAnotherPrompt:(NSString *)addAnotherPrompt {
	(self.dict)[@"addAnotherPrompt"] = [addAnotherPrompt copy]; 
}

- (NSString*)addFirstPrompt {
	return (self.dict)[@"addFirstPrompt"];
}

- (void)setAddFirstPrompt:(NSString *)addFirstPrompt {
	(self.dict)[@"addFirstPrompt"] = [addFirstPrompt copy];
}

- (BOOL)addRequiresDrillDown {
    return [(self.dict)[@"addRequiresDrillDown"] boolValue];
}

- (void)setAddRequiresDrillDown:(BOOL)addRequiresDrillDown {
    (self.dict)[@"addRequiresDrillDown"] = @(addRequiresDrillDown);
}

- (void)activate {
	[super activate];

    while(self.subitems.count < self.startRepeats) {
		[self newSubitemFromTemplate];
	}

    BSELF;
	CObserverBlock action = ^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		if(!bself.isReordering) {
			if(kind == NSKeyValueChangeSetting) {
				[bself.endRepeatRowItem.superitem.subitems removeAllObjects];
			}
			if(kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeSetting) {
				NSArray *newModels = (NSArray*)newValue;
				NSUInteger endRepeatRowItemIndex = [bself.endRepeatRowItem.superitem.subitems indexOfObject:bself.endRepeatRowItem];
				NSAssert(endRepeatRowItemIndex != NSNotFound, @"Couldn't find endRepeatRowItem.");
				NSAssert(newModels.count == 1, @"Only adding one at a time supported.");
				for(CItem *item in newModels) {
					NSArray *newRowItems = [item tableRowItems];
					NSAssert(newRowItems.count == 1, @"Only one item per row supported.");
					CTableRowItem *newRowItem = newRowItems[0];
					newRowItem.deletable = YES;
					newRowItem.reorderable = YES;
					
					NSUInteger indexInRepeatingItem = indexes.firstIndex;
					NSUInteger indexInTable = endRepeatRowItemIndex - bself.subitems.count + indexInRepeatingItem + 1;
					NSIndexSet *newIndexes = [NSIndexSet indexSetWithIndex:indexInTable];
					[bself.endRepeatRowItem.superitem.subitems insertObjects:newRowItems atIndexes:newIndexes];
				}
			} else if(kind == NSKeyValueChangeRemoval) {
				NSArray *oldRowItems = (NSArray*)oldValue;
				NSUInteger endRepeatRowItemIndex = [bself.endRepeatRowItem.superitem.subitems indexOfObject:bself.endRepeatRowItem];
				NSAssert(endRepeatRowItemIndex != NSNotFound, @"Couldn't find endRepeatRowItem.");
				
				NSUInteger count = bself.subitems.count + oldRowItems.count;
				
				NSMutableIndexSet *adjustedIndexes = [NSMutableIndexSet indexSet];
				[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
					NSUInteger index = endRepeatRowItemIndex - count + idx;
					[adjustedIndexes addIndex:index];
				}];
				[bself.endRepeatRowItem.superitem.subitems removeObjectsAtIndexes:adjustedIndexes];
			} else {
				NSAssert1(false, @"Unimplemented change kind:%lu", (unsigned long)kind);
			}
		}
	};
	self.subitemsObserver = [CObserver newObserverWithKeyPath:@"subitems" ofObject:self action:action];
	self.hiddenObserver = [CObserver newObserverWithKeyPath:@"hidden" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		bself.endRepeatRowItem.hidden = [newValue boolValue];
	}];
}

- (void)deactivate {
	self.subitemsObserver = nil;
	self.hiddenObserver = nil;
	[super deactivate];
}

- (void)setValuesFromDummyValuesHierarchical:(BOOL)hierarchical {
    [super setValuesFromDummyValuesHierarchical:hierarchical];
    if(self.hasDummyStartRepeats) {
        for(NSUInteger i = self.startRepeats; i < self.dummyStartRepeats; i++) {
            [self newSubitemFromTemplate];
        }
        self.startRepeats = self.dummyStartRepeats;
        [self.subitems enumerateObjectsUsingBlock:^(CItem *subitem, NSUInteger idx1, BOOL *stop) {
            if([subitem isKindOfClass:[CMultiTextItem class]]) {
                CMultiTextItem *multiTextItem = (CMultiTextItem *)subitem;
                [multiTextItem.subitems enumerateObjectsUsingBlock:^(CStringItem *stringItem, NSUInteger idx2, BOOL *stop) {
                    stringItem.stringValue = stringItem.dummyValues[idx1];
                }];
            }
        }];
    }
}

#pragma mark - Table Support

- (NSArray*)tableRowItems {
	NSMutableArray *rowItems = [NSMutableArray array];
	
	for(CItem *initialItem in self.subitems) {
		NSArray *newRowItems = [initialItem tableRowItems];
		for(CTableRowItem *rowItem in newRowItems) {
			rowItem.deletable = YES;
			rowItem.reorderable = YES;
			[rowItems addObject:rowItem];
		}
	}
	self.endRepeatRowItem = [CAddRepeatingTableRowItem newItemWithKey:self.key title:self.title repeatingItem:self];
	[rowItems addObject:self.endRepeatRowItem];
	
	return rowItems;
}

@end
