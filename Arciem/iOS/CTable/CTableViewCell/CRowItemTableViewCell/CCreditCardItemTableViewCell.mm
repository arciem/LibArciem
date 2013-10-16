/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 *******************************************************************************/

#import "CCreditCardItemTableViewCell.h"
#import "CObserver.h"
#import "CCreditCardItem.h"
#import "UIViewUtils.h"
#import "Geom.h"
#import "ObjectUtils.h"
#import "UIImageUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface CCreditCardItemTableViewCell ()

@property (nonatomic) CObserver* cardTypeObserver;
@property (nonatomic) NSMutableArray* cardTypeViews;
@property (nonatomic) NSMutableDictionary* cardTypeViewsByType;
@property (readonly, nonatomic) CCreditCardItem* creditCardItem;
@property (nonatomic) CSpacerView *spacer1;
@property (nonatomic) CSpacerView *spacer2;

@end

@implementation CCreditCardItemTableViewCell

- (void)setup {
    [super setup];

    self.cardTypeViews = [NSMutableArray array];
    self.cardTypeViewsByType = [NSMutableDictionary dictionary];
    
    self.spacer1 = [CSpacerView addSpacerViewToSuperview:self.contentView];
    self.spacer2 = [CSpacerView addSpacerViewToSuperview:self.contentView];
    
//    self.spacer1.debugColor = [UIColor redColor];
//    self.spacer2.debugColor = [UIColor redColor];
    
//	self.contentView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
}

- (void)syncToRowItem
{
	[super syncToRowItem];

	if(self.rowItem == nil) {
		for(UIView* view in self.cardTypeViews) {
			[view removeFromSuperview];
		}
		[self.cardTypeViews removeAllObjects];
		[self.cardTypeViewsByType removeAllObjects];
		self.cardTypeObserver = nil;
	} else {
		BSELF;
        self.cardTypeObserver = [CObserver observerWithKeyPath:@"cardType" ofObject:self.rowItem.model action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
            [bself syncCardTypeAnimated:YES];
        }];
	}
}

- (UIImageView *)viewForCardType:(NSString *)cardType {
    UIImageView *view = (self.cardTypeViewsByType)[cardType];
    if(view == nil) {
        NSString* imageName = [NSString stringWithFormat:@"CC_%@", cardType];
        UIImage* highlightedImage = [UIImage imageNamed:imageName];
        NSAssert1(highlightedImage != nil, @"no image found for name:%@", imageName);
        UIImage* image = [highlightedImage imageByDesaturating:0.0];
        view = [[UIImageView alloc] initWithImage:image highlightedImage:highlightedImage];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        view.contentMode = UIViewContentModeTopLeft;
        [self.contentView addSubview:view];
        [self.cardTypeViews addObject:view];
        (self.cardTypeViewsByType)[cardType] = view;
    }
    return view;
}

- (void)syncCardTypeAnimated:(BOOL)animated
{
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
	NSTimeInterval duration = animated ? 0.4 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}
			
- (CCreditCardItem*)creditCardItem
{
	return (CCreditCardItem*)self.rowItem.model;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    UIView *cardView = [self viewForCardType:self.creditCardItem.validCardTypes[0]];
	size.height = 8 + cardView.intrinsicContentSize.height + 8 + self.textField.intrinsicContentSize.height + 8;
	return size;
}

- (void)updateConstraints {
    [super updateConstraints];

    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CCreditCardItemTableViewCell_contentView" owner:self.contentView];

    __block UIView *lastLeftCardView;
    __block UIView *firstLeftCardView;
    __block UIView *lastRightCardView;
    BSELF;
    [self.creditCardItem.validCardTypes enumerateObjectsUsingBlock:^(NSString* cardType, NSUInteger idx, BOOL *stop) {
        UIView* thisCardView = [bself viewForCardType:cardType];
        [group addConstraint:[thisCardView constrainTopEqualToTopOfItem:bself.contentView offset:8]];

        BOOL highlight = YES;
        if(self.creditCardItem.cardType != nil) {
            if(![cardType isEqualToString:self.creditCardItem.cardType]) {
                highlight = NO;
            }
        }

        if(highlight) {
            if(lastLeftCardView != nil) {
                [group addConstraint:[thisCardView constrainLeadingEqualToTrailingOfItem:lastLeftCardView offset:8]];
            }
            lastLeftCardView = thisCardView;
            
            if(firstLeftCardView == nil) {
                firstLeftCardView = thisCardView;
            }
        } else {
            if(lastRightCardView != nil) {
                [group addConstraint:[thisCardView constrainLeadingEqualToTrailingOfItem:lastRightCardView offset:8]];
            }
            lastRightCardView = thisCardView;
        }
    }];
    
    if(firstLeftCardView != nil) {
        [group addConstraint:[firstLeftCardView constrainLeadingEqualToTrailingOfItem:bself.spacer1]];
    }
    
    if(lastRightCardView != nil) {
        [group addConstraint:[bself.spacer2 constrainLeadingEqualToTrailingOfItem:lastRightCardView]];
    } else {
        [group addConstraint:[bself.spacer2 constrainLeadingEqualToTrailingOfItem:lastLeftCardView]];
    }
    
    UIView *cardView = [self viewForCardType:self.creditCardItem.validCardTypes[0]];
    [group addConstraint:[self.textField constrainTopEqualToBottomOfItem:cardView offset:8]];

    [group addConstraint:[self.spacer1 constrainCenterYEqualToCenterYOfItem:cardView]];
    [group addConstraint:[self.spacer1 constrainLeadingEqualToLeadingOfItem:self.contentView]];
    
    [group addConstraint:[self.spacer2 constrainCenterYEqualToCenterYOfItem:cardView]];
    [group addConstraint:[self.spacer2 constrainTrailingEqualToTrailingOfItem:self.contentView]];
    
    [group addConstraint:[self.spacer1 constrainWidthEqualToItem:self.spacer2]];
    
    if(self.creditCardItem.cardType != nil) {
        [group addConstraint:[self.textField constrainLeadingEqualToTrailingOfItem:self.spacer1]];
        [group addConstraint:[self.spacer2 constrainLeadingEqualToTrailingOfItem:self.textField]];
    }

#if 0
#warning DEBUG ONLY
    [self printConstraintsHierarchy];
#endif
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for(NSString* cardType in self.creditCardItem.validCardTypes) {
        UIImageView* view = (self.cardTypeViewsByType)[cardType];
        if(self.creditCardItem.cardType == nil) {
            view.alpha = 1.0;
            view.highlighted = YES;
        } else {
            if([cardType isEqualToString:self.creditCardItem.cardType]) {
                [view bringToFront];
                view.alpha = 1.0;
                view.highlighted = YES;
            } else {
                view.alpha = 0.5;
                view.highlighted = NO;
            }
        }
    }
}

@end
