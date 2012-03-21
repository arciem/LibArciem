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

@property (strong, nonatomic) CObserver* subitemsObserver;

@end

@implementation CTableItem

@synthesize subitemsObserver = subitemsObserver_;
@synthesize delegate = delegate_;
@dynamic textLabel;

- (void)setup
{
	CObserverBlock action = ^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self.delegate tableItem:self sectionsDidChangeWithNew:newValue old:oldValue kind:kind indexes:indexes];
	};
	
	self.subitemsObserver = [CObserver observerWithKeyPath:@"subitems" ofObject:self action:action initial:action];
}

- (NSMutableDictionary*)textLabel
{
	return [self.dict objectForKey:@"textLabel"];
}
					   
- (void)setTextLabel:(NSMutableDictionary *)textLabel
{
	[self.dict setObject:[textLabel mutableCopy] forKey:@"textLabel"];
}

+ (CTableItem*)item
{
	return [[self alloc] init];
}

- (void)tableSectionItem:(CTableSectionItem*)tableSectionItem rowsDidChangeWithNew:(NSArray*)newItems old:(NSArray*)oldItems kind:(NSKeyValueChange)kind indexes:(NSIndexSet*)indexes
{
	[self.delegate tableSectionItem:tableSectionItem rowsDidChangeWithNew:newItems old:oldItems kind:kind indexes:indexes];
}

@end
