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

#import "CTableItem.h"
#import "CTableSectionItem.h"
#import "CTableRowItem.h"
#import "CObserver.h"

@interface CTableItem ()

@property (nonatomic) CObserver* subitemsObserver;

@end

@implementation CTableItem

@synthesize subitemsObserver = subitemsObserver_;
@synthesize delegate = delegate_;

- (void)setup
{
    BSELF;
	CObserverBlock action = ^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself.delegate tableItem:bself sectionsDidChangeWithNew:newValue old:oldValue kind:kind indexes:indexes];
	};
	
	self.subitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self action:action initial:action];
}

- (NSDictionary*)textLabelAttributes
{
    return (self.dict)[@"textLabelAttributes"];
}
					   
- (void)setTextLabelAttributes:(NSDictionary *)textLabelAttributes
{
	(self.dict)[@"textLabelAttributes"] = [textLabelAttributes copy];
}

+ (CTableItem*)tableItem
{
	return [self new];
}

- (void)tableSectionItem:(CTableSectionItem*)tableSectionItem rowsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes
{
	[self.delegate tableSectionItem:tableSectionItem rowsDidChangeWithNew:newItems old:oldItems kind:kind indexes:indexes];
}

- (void)tableRowItem:(CTableRowItem*)rowItem didChangeHiddenFrom:(BOOL)fromHidden to:(BOOL)toHidden
{
	[self.delegate tableRowItem:rowItem didChangeHiddenFrom:fromHidden to:toHidden];
}

@end
