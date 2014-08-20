//
//  CPaymentMethodTypeImageView.h
//  Arciem
//
//  Created by Robert McNally on 10/28/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

@import UIKit;

@interface CPaymentMethodTypeImageView : UIImageView

@property (copy, nonatomic) dispatch_block_t tapHandler;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) NSString *cardType;

+ (CPaymentMethodTypeImageView *)newViewForCardType:(NSString *)cardType;

@end
