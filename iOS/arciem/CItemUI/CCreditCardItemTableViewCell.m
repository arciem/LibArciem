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

@interface CCreditCardItemTableViewCell ()

@property (strong, nonatomic) CObserver* cardTypeObserver;
@property (strong, nonatomic) NSMutableArray* cardTypeViews;
@property (strong, nonatomic) NSMutableDictionary* cardTypeViewsByType;
@property (readonly, nonatomic) CCreditCardItem* creditCardItem;

@end

@implementation CCreditCardItemTableViewCell

@synthesize cardTypeObserver = cardTypeObserver_;
@synthesize cardTypeViews = cardTypeViews_;
@synthesize cardTypeViewsByType = cardTypeViewsByType_;

- (void)syncToRowItem
{
	[super syncToRowItem];

	if(self.rowItem == nil) {
		for(UIView* view in self.cardTypeViews) {
			[view removeFromSuperview];
		}
		self.cardTypeViews = nil;
		self.cardTypeViewsByType = nil;
		self.cardTypeObserver = nil;
	} else {
		__unsafe_unretained CCreditCardItemTableViewCell* self__ = self;
		CObserverBlock action = ^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
			[self__ syncCardType];
		};
		self.cardTypeObserver = [CObserver observerWithKeyPath:@"cardType" ofObject:self.rowItem.model action:action initial:action];
		
		self.cardTypeViews = [NSMutableArray array];
		self.cardTypeViewsByType = [NSMutableDictionary dictionary];
		for(NSString* cardType in self.creditCardItem.validCardTypes) {
			NSString* imageName = [NSString stringWithFormat:@"CC_%@", cardType];
			UIImage* image = [UIImage imageNamed:imageName];
			NSAssert1(image != nil, @"no image found for name:%@", imageName);
			UIImageView* view = [[UIImageView alloc] initWithImage:image];
			view.contentMode = UIViewContentModeTopLeft;
//			[view sizeToFit];
			[self.contentView addSubview:view];
			[self.cardTypeViews addObject:view];
			[self.cardTypeViewsByType setObject:view forKey:cardType];
		}
	}
	
	self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	self.validationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//	self.contentView.backgroundColor = [UIColor blueColor];
}

- (void)syncCardType
{
	CLogDebug(nil, @"cardType:%@", self.creditCardItem.cardType);
	[self layoutCardViewsAnimated:YES];
}
			
- (CCreditCardItem*)creditCardItem
{
	return (CCreditCardItem*)self.rowItem.model;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size.height = 77;
	return size;
}

- (void)layoutCardViewsAnimated:(BOOL)animated
{
	NSTimeInterval duration = animated ? 0.4 : 0.0;
	[UIView animateWithDuration:duration animations:^{
		const CGFloat kGutter = 10;
		
		CGFloat totalWidth = 0;
		for(UIView* view in self.cardTypeViews) {
			totalWidth += view.width;
		}
		totalWidth += (self.cardTypeViews.count - 1) * kGutter;
		
		CGFloat x = (self.contentView.width - totalWidth) / 2;
		CGFloat bottomY = self.textField.top - 8;
		for(NSString* cardType in self.creditCardItem.validCardTypes) {
			UIView* view = [self.cardTypeViewsByType objectForKey:cardType];
			
			CGRect frame;
			frame.size = view.frame.size;
			frame.origin.y = bottomY - frame.size.height;
			frame.origin.x = x;
			
			if(self.creditCardItem.cardType == nil) {
				view.alpha = 1.0;
			} else {
				if([cardType isEqualToString:self.creditCardItem.cardType]) {
					[view bringToFront];
					view.alpha = 1.0;
					frame = [Geom alignRectMidX:frame toX:self.contentView.boundsCenterX];
				} else {
					view.alpha = 0.0;
				}
			}
			
			frame = CGRectIntegral(frame);
			view.frame = frame;
			
			CLogDebug(nil, @"%@: %@", cardType, view);
			
			x += frame.size.width + kGutter;
		}
	}];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.textField.bottom = self.contentView.boundsHeight - 5;
	self.validationView.centerY = self.textField.centerY;
	[self layoutCardViewsAnimated:NO];
}

@end
