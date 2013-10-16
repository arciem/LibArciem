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
#import "CTableButtonItem.h"

@interface CSubmitItem ()

@property (nonatomic) CObserver* rootStateObserver;
@property (nonatomic) CObserver* isEditingObserver;

@end

@implementation CSubmitItem

@synthesize rootStateObserver = rootStateObserver_;
@synthesize isEditingObserver = isEditingObserver_;
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
	self.isEditingObserver = [CObserver observerWithKeyPath:@"isEditing" ofObject:self action:action];
}

- (void)deactivate
{
	[super deactivate];
	self.rootStateObserver = nil;
	self.isEditingObserver = nil;
}

- (void)syncState
{
	BOOL isValid = self.rootItem.isValid && !self.isEditing;
	self.isDisabled = !isValid;
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	CTableButtonItem* rowItem = [CTableButtonItem itemWithKey:self.key title:self.title item:self];
	return @[rowItem];
}

#pragma mark - @property isEditing

- (BOOL)isEditing
{
	return [(self.dict)[@"isEditing"] boolValue];
}

- (void)setEditing:(BOOL)isEditing
{
	[self willChangeValueForKey:@"isEditing"];
	(self.dict)[@"isEditing"] = @(isEditing);
	[self didChangeValueForKey:@"isEditing"];
}

@end
