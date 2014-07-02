//
//  CPaymentMethodSummaryTableRowItem.m
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CPaymentMethodSummaryTableRowItem.h"

@implementation CPaymentMethodSummaryTableRowItem

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title model:(CItem *)model {
    if(self = [super initWithKey:key title:title model:model]) {
        self.requiresDrillDown = NO;
    }
    return self;
}

+ (CPaymentMethodSummaryTableRowItem*)newItemWithKey:(NSString*)key title:(NSString*)title paymentMethodSummaryItem:(CPaymentMethodSummaryItem*)paymentMethodSummaryItem
{
	return [[self alloc] initWithKey:key title:title model:paymentMethodSummaryItem];
}

- (NSString*)defaultCellType
{
	return @"CPaymentMethodSummaryItemTableViewCell";
}

- (BOOL)isRowSelectable
{
	return NO;
}

@end
