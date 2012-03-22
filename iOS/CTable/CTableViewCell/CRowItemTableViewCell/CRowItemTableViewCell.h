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

#import "CTableViewCell.h"
#import "CTableRowItem.h"
#import "CFieldValidationView.h"

@protocol CRowItemTableViewCellDelegate;

@interface CRowItemTableViewCell : CTableViewCell

@property (strong, nonatomic) CTableRowItem* rowItem;
@property (readonly, nonatomic) CFieldValidationView* validationView;
@property (readonly, nonatomic) NSArray* validationViews;
@property (readonly, nonatomic) NSUInteger validationViewsNeeded;
@property (weak, nonatomic) CItem* activeItem;
@property (weak, nonatomic) id<CRowItemTableViewCellDelegate> delegate;

- (void)setNumberOfValidationViewsTo:(NSUInteger)count;

// May be overridden by subclasses
- (void)syncToRowItem;
- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue;
- (NSUInteger)validationViewsNeeded;
- (void)syncValidationViews;

@end

@protocol CRowItemTableViewCellDelegate <NSObject>

@required

- (void)rowItemTableViewCellDidGainFocus:(CRowItemTableViewCell*)cell;

@end
