//
//  CTableCreditCardSummaryItem.mm
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CTableCreditCardSummaryItem.h"

@implementation CTableCreditCardSummaryItem

+ (CTableCreditCardSummaryItem*)itemWithKey:(NSString*)key title:(NSString*)title creditCardItem:(CCreditCardItem*)item
{
	return [[self alloc] initWithKey:key title:title model:item];
}

- (NSString*)defaultCellType
{
	return @"CCreditCardSummaryItemTableViewCell";
}

- (BOOL)isUnselectable
{
	return YES;
}

@end
