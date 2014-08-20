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

#import "CTableSectionItem.h"
#import "CObserver.h"
#import "CTableItem.h"
#import "StringUtils.h"

@interface CTableSectionItem ()

@property (nonatomic) CObserver* subitemsObserver;

@end

@implementation CTableSectionItem

@synthesize subitemsObserver = subitemsObserver_;
@synthesize isReordering = isReordering_;

- (void)setup
{
    BSELF;
	CObserverBlock action = ^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		if(!bself.isReordering) {
			[(CTableItem*)bself.superitem tableSectionItem:bself rowsDidChangeWithNew:newValue old:oldValue kind:kind indexes:indexes];
		}
	};
	
	self.subitemsObserver = [CObserver newObserverWithKeyPath:@"subitems" ofObject:self action:action initial:action];
}

+ (CTableSectionItem*)newTableSectionItem
{
	return [self new];
}

+ (CTableSectionItem *)newTableSectionItemWithTitle:(NSString*)title key:(NSString*)key {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if(!IsEmptyString(title)) {
        dict[@"title"] = title;
    }
    if(!IsEmptyString(key)) {
        dict[@"key"] = key;
    }
    dict[@"type"] = @"section";
	return [[self alloc] initWithDictionary:dict];
}

- (void)tableRowItem:(CTableRowItem*)rowItem didChangeHiddenFrom:(BOOL)fromHidden to:(BOOL)toHidden
{
	[(CTableItem*)self.superitem tableRowItem:rowItem didChangeHiddenFrom:fromHidden to:toHidden];
}

@end