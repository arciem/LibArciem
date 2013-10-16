//
//  CTableCreditCardSummaryItem.h
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CTableSummaryItem.h"
#import "CCreditCardItem.h"

@interface CTableCreditCardSummaryItem : CTableSummaryItem

+ (CTableCreditCardSummaryItem*)itemWithKey:(NSString*)key title:(NSString*)title creditCardItem:(CCreditCardItem*)item;

@end
