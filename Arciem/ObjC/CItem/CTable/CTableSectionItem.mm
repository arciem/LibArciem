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

@interface CTableSectionItem ()

@property (strong, nonatomic) CObserver* subitemsObserver;

@end

@implementation CTableSectionItem

@synthesize subitemsObserver = subitemsObserver_;
@synthesize isReordering = isReordering_;

- (void)setup
{
	CObserverBlock action = ^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		if(!self.isReordering) {
			[(CTableItem*)self.superitem tableSectionItem:self rowsDidChangeWithNew:newValue old:oldValue kind:kind indexes:indexes];
		}
	};
	
	self.subitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self action:action initial:action];
}

+ (CTableSectionItem*)item
{
	return [[self alloc] init];
}

- (void)tableRowItem:(CTableRowItem*)rowItem didChangeHiddenFrom:(BOOL)fromHidden to:(BOOL)toHidden
{
	[(CTableItem*)self.superitem tableRowItem:rowItem didChangeHiddenFrom:fromHidden to:toHidden];
}

@end
