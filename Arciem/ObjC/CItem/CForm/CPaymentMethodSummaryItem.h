//
//  CPaymentMethodSummaryItem.h
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CItem.h"

@interface CPaymentMethodSummaryItem : CItem

@property (nonatomic) NSString *cardType;
@property (nonatomic) NSString *lastFour;
@property (nonatomic) NSString *expirationYear;
@property (nonatomic) NSString *expirationMonth;
@property (nonatomic) NSString *recordID;

@end
