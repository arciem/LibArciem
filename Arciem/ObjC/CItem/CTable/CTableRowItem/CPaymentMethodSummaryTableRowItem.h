//
//  CPaymentMethodSummaryTableRowItem.h
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CSummaryTableRowItem.h"
#import "CPaymentMethodSummaryItem.h"

@interface CPaymentMethodSummaryTableRowItem : CSummaryTableRowItem

+ (CPaymentMethodSummaryTableRowItem*)newItemWithKey:(NSString*)key title:(NSString*)title paymentMethodSummaryItem:(CPaymentMethodSummaryItem*)paymentMethodSummaryItem;

@end
