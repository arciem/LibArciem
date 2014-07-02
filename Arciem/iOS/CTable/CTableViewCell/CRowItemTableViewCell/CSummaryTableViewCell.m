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

#import "CSummaryTableViewCell.h"
#import "UIViewUtils.h"
#import "CSummaryTableRowItem.h"
#import "CObserver.h"

@interface CSummaryTableViewCell ()

@property (nonatomic) CObserver* modelValueObserver;

@end

@implementation CSummaryTableViewCell

@synthesize modelValueObserver = modelValueObserver_;

- (void)setup
{
	[super setup];
	
//	self.titleLabel.font = self.font;

    BSELF;
	self.modelValueObserver = [CObserver newObserverWithKeyPath:@"value" action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself syncToModelValue:newValue];
	} initial:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself syncToModelValue:newValue];
	}];
}

- (void)syncToRowItem
{
	[super syncToRowItem];
	
	CSummaryTableRowItem* rowItem = (CSummaryTableRowItem*)self.rowItem;
	if(rowItem.requiresDrillDown) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	
	CItem* model = rowItem.model;
	self.modelValueObserver.objects = @[model];
}

- (void)syncToModelValue:(id)value
{
//	CLogDebug(nil, @"%@ syncToModelValue:%@", self, value);
}

@end
