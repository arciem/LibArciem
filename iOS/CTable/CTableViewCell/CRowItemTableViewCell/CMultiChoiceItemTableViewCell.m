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

#import "CMultiChoiceItemTableViewCell.h"
#import "CTableMultiChoiceItem.h"

@implementation CMultiChoiceItemTableViewCell

- (void)syncToModelValue:(id)value
{
	[super syncToModelValue:value];
	
	CTableMultiChoiceItem* rowItem = (CTableMultiChoiceItem*)self.rowItem;
	NSString* title = self.rowItem.title;
	if(rowItem.requiresDrillDown) {
		CMultiChoiceItem* model = (CMultiChoiceItem*)rowItem.model;
		NSIndexSet* selectedIndexes = model.selectedSubitemIndexes;
		if(selectedIndexes.count == 0) {
			title = [NSString stringWithFormat:@"%@...", title];
		} else if(selectedIndexes.count == 1) {
			title = [NSString stringWithFormat:@"%@: %@", title, model.selectedSubitem.title];
		} else {
			title = [NSString stringWithFormat:@"%@: (%d selected)", title, selectedIndexes.count];
		}
	} else {
		title = [NSString stringWithFormat:@"%@...", title];
	}
	self.textLabel.text = title;
}

@end
