//
//  CPaymentMethodSummaryItem.mm
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CPaymentMethodSummaryItem.h"
#import "CPaymentMethodSummaryTableRowItem.h"
#import "ObjectUtils.h"

@implementation CPaymentMethodSummaryItem

- (NSString*)description
{
    return [self formatObjectWithValues:@[
                                          [self formatValueForKey:@"cardType" compact:YES],
                                          [self formatValueForKey:@"lastFour" compact:YES],
                                          [self formatValueForKey:@"expirationYear" compact:YES],
                                          [self formatValueForKey:@"expirationMonth" compact:YES],
                                          [self formatValueForKey:@"recordID" compact:YES]
                                          ]];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *result = [super keyPathsForValuesAffectingValueForKey:key];
    if([key isEqualToString:@"value"]) {
        NSMutableSet *set = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
        [set addObjectsFromArray:@[@"cardType", @"lastFour", @"expirationYear", @"expirationMonth", @"recordID"]];
        result = [set copy];
    }
    return result;
}

- (id)value {
    return [NSString stringWithFormat:@"%@ ending in %@ expires %@-%@ (%@)", self.cardType, self.lastFour, self.expirationYear, self.expirationMonth, self.recordID];
}

- (void)setValue:(id)value {
    NSAssert(NO, @"Value for instances of this class may not be set directly.");
}

#pragma mark - Table Support

- (NSArray*)tableRowItems
{
	CPaymentMethodSummaryTableRowItem* rowItem = [CPaymentMethodSummaryTableRowItem newItemWithKey:self.key title:self.title paymentMethodSummaryItem:self];
	return @[rowItem];
}

@end
