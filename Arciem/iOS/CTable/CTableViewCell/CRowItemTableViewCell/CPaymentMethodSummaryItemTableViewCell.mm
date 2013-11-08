//
//  CPaymentMethodSummaryItemTableViewCell.mm
//  Arciem
//
//  Created by Robert McNally on 10/15/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CPaymentMethodSummaryItemTableViewCell.h"
#import "CPaymentMethodTypeImageView.h"
#import "CPaymentMethodSummaryItem.h"
#import "ObjectUtils.h"
#import "StringUtils.h"

@interface CPaymentMethodSummaryItemTableViewCell ()

@property (nonatomic) CPaymentMethodTypeImageView *paymentMethodTypeImageView;
@property (nonatomic) CPaymentMethodSummaryItem *paymentMethodSummaryItem;

@end

@implementation CPaymentMethodSummaryItemTableViewCell

@synthesize paymentMethodSummaryItem = _paymentMethodSummaryItem;

- (void)setup {
    [super setup];
    
//    CLogDebug(nil, @"%@ model:%@", self, self.rowItem.model);
    self.paymentMethodTypeImageView = [CPaymentMethodTypeImageView new];
    self.paymentMethodTypeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.paymentMethodTypeImageView.highlighted = YES;
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:self.paymentMethodTypeImageView];
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (void)syncTitleLabelToRowItem {
    [super syncTitleLabelToRowItem];
    self.paymentMethodTypeImageView.cardType = self.paymentMethodSummaryItem.cardType;
    CGFloat pointSize = self.titleLabel.font.pointSize;
    UIFont *font = [UIFont systemFontOfSize:pointSize];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:pointSize];
    NSDictionary *attributes = @{
                                     NSFontAttributeName: font
                                     };
    NSDictionary *boldAttributes = @{
                                 NSFontAttributeName: boldFont
                                 };
    NSDictionary *replacements = @{
                                   @"lastFour": self.paymentMethodSummaryItem.lastFour,
                                   @"expiry": [NSString stringWithFormat:@"%@-%@", self.paymentMethodSummaryItem.expirationMonth, self.paymentMethodSummaryItem.expirationYear]
                                   };
    NSDictionary *attributesDict = @{
                                   @"lastFour": boldAttributes,
                                   @"expiry": boldAttributes
                                   };
    NSAttributedString *attributedText = [[[NSAttributedString alloc] initWithString:@"Ending in: {lastFour} Expires: {expiry}" attributes:attributes]stringByReplacingTemplatesWithReplacements:replacements attributes:attributesDict];
    self.titleLabel.attributedText = attributedText;
}

- (void)syncToRowItem {
    [super syncToRowItem];
    [self syncTitleLabelToRowItem];
}

- (void)syncToModelValue:(id)value
{
//	CLogDebug(nil, @"%@ syncToModelValue:%@ rowItem.model:%@", self, value, self.rowItem.model);
    self.paymentMethodSummaryItem = (CPaymentMethodSummaryItem *)self.rowItem.model;
}

- (CPaymentMethodSummaryItem *)paymentMethodSummaryItem {
    return _paymentMethodSummaryItem;
}

- (void)setPaymentMethodSummaryItem:(CPaymentMethodSummaryItem *)paymentMethodSummaryItem {
    _paymentMethodSummaryItem = Denull(paymentMethodSummaryItem);
    
    if(_paymentMethodSummaryItem != nil) {
        self.paymentMethodTypeImageView.cardType = _paymentMethodSummaryItem.cardType;
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    CLayoutConstraintsGroup *constraints = [self resetConstraintsGroupForKey:@"CPaymentMethodSummaryItemTableViewCell_contentView" owner:self.contentView];
    [constraints addConstraint:[self.paymentMethodTypeImageView constrainCenterYEqualToCenterYOfItem:self.contentView]];
    [constraints addConstraint:[self.paymentMethodTypeImageView constrainLeadingEqualToLeadingOfItem:self.contentView offset:15]];
    [constraints addConstraint:[self.titleLabel constrainCenterYEqualToCenterYOfItem:self.paymentMethodTypeImageView]];
    [constraints addConstraint:[self.titleLabel constrainLeadingEqualToTrailingOfItem:self.paymentMethodTypeImageView offset:10]];
}

@end
