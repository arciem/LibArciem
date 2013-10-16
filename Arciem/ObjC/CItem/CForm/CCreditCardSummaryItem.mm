//
//  CCreditCardSummaryItem.m
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CCreditCardSummaryItem.h"
#import "CTableCreditCardSummaryItem.h"

@implementation CCreditCardSummaryItem

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	CTableCreditCardSummaryItem* rowItem = [CTableCreditCardSummaryItem itemWithKey:self.key title:self.title creditCardItem:self];
	return @[rowItem];
}

@end
