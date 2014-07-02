//
//  CPaymentMethodTypeImageView.m
//  Arciem
//
//  Created by Robert McNally on 10/28/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CPaymentMethodTypeImageView.h"
#import "UIImageUtils.h"

@implementation CPaymentMethodTypeImageView

@synthesize tapHandler = _tapHandler;
@synthesize cardType = _cardType;

+ (CPaymentMethodTypeImageView *)newViewForCardType:(NSString *)cardType {
    CPaymentMethodTypeImageView *view = [CPaymentMethodTypeImageView new];
    view.contentMode = UIViewContentModeTopLeft;
    view.cardType = cardType;
    return view;
}

- (dispatch_block_t)tapHandler {
    return _tapHandler;
}

- (void)setTapHandler:(dispatch_block_t)tapHandler {
    _tapHandler = tapHandler;
    if(_tapHandler != nil) {
        self.userInteractionEnabled = YES;
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:self.tapRecognizer];
    } else {
        self.userInteractionEnabled = NO;
        if(self.tapRecognizer != nil) {
            [self removeGestureRecognizer:self.tapRecognizer];
            self.tapRecognizer = nil;
        }
    }
}

- (void)tapped {
    if(self.tapHandler != nil) {
        self.tapHandler();
    }
}

- (NSString *)cardType {
    return _cardType;
}

- (void)setCardType:(NSString *)cardType {
    _cardType = cardType;
    NSString* imageName = [NSString stringWithFormat:@"CC_%@", cardType];
    UIImage* highlightedImage = [UIImage imageNamed:imageName];
    NSAssert1(highlightedImage != nil, @"no image found for name:%@", imageName);
    UIImage* image = [highlightedImage newImageByDesaturating:0.0];
    [self setImage:image];
    [self setHighlightedImage:highlightedImage];
    [self invalidateIntrinsicContentSize];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

@end
