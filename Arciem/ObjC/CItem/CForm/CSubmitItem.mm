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

#import "CSubmitItem.h"
#import "CObserver.h"
#import "CButtonTableRowItem.h"

@interface CSubmitItem ()

@property (weak, nonatomic) CButtonTableRowItem* tableButtonItem;
@property (nonatomic) CObserver* rootStateObserver;
@property (nonatomic) CObserver* editingObserver;
@property (nonatomic) CObserver* hiddenObserver;

@end

@implementation CSubmitItem

@synthesize rootStateObserver = rootStateObserver_;
@synthesize editingObserver = editingObserver_;
@synthesize action = action_;

- (id)copyWithZone:(NSZone *)zone
{
	CSubmitItem* item = [super copyWithZone:zone];
	
	item.action = self.action;
	
	return item;
}

- (void)activate
{
	[super activate];
	
    BSELF;
	CObserverBlock action = ^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself syncState];
	};
	
	self.rootStateObserver = [CObserver observerWithKeyPath:@"state" ofObject:self.rootItem action:action initial:action];
	self.editingObserver = [CObserver observerWithKeyPath:@"editing" ofObject:self action:action];
	self.hiddenObserver = [CObserver observerWithKeyPath:@"hidden" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		bself.tableButtonItem.hidden = [newValue boolValue];
	}];
}

- (void)deactivate
{
	self.rootStateObserver = nil;
	self.editingObserver = nil;
	self.hiddenObserver = nil;
	[super deactivate];
}

- (void)syncState
{
	BOOL valid = self.rootItem.valid && !self.editing;
	self.disabled = !valid;
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	self.tableButtonItem = [CButtonTableRowItem itemWithKey:self.key title:self.title item:self];
	return @[self.tableButtonItem];
}

#pragma mark - @property editing

- (BOOL)isEditing
{
	return [(self.dict)[@"editing"] boolValue];
}

- (void)setEditing:(BOOL)editing
{
	[self willChangeValueForKey:@"editing"];
	(self.dict)[@"editing"] = @(editing);
	[self didChangeValueForKey:@"editing"];
}

@end
