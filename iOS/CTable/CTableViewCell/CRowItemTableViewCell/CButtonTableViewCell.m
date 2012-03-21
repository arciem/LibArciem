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

#import "CButtonTableViewCell.h"
#import "UIViewUtils.h"
#import "CSubmitItem.h"
#import "CObserver.h"

@interface CButtonTableViewCell ()

@property (strong, nonatomic) CObserver* modelDisabledObserver;
@property (strong, readwrite, nonatomic) UIButton* button;

@end

@implementation CButtonTableViewCell

@synthesize button = button_;
@synthesize modelDisabledObserver = modelDisabledObserver_;

- (void)setup
{
	[super setup];
	
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	self.button.backgroundColor = [UIColor redColor];
	[self.button addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.button];

	self.textLabel.hidden = YES;
	
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size.height = roundf(size.height * 1.2);
	return size;
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (void)syncToRowItem
{
	[super syncToRowItem];
	
	if(self.rowItem == nil) {
		self.modelDisabledObserver = nil;
	} else {
		[self.button setTitle:self.rowItem.model.title forState:UIControlStateNormal];
		
		__unsafe_unretained CButtonTableViewCell* self__ = self;
		CObserverBlock action = ^(NSNumber* newValue, NSNumber* oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
//			BOOL oldDisabled = oldValue.boolValue;
			BOOL newDisabled = newValue.boolValue;
			self__.button.enabled = !newDisabled;
		};
		
		self.modelDisabledObserver = [CObserver observerWithKeyPath:@"isDisabled" ofObject:self.rowItem.model action:action initial:action];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	UIFont* font = self.button.titleLabel.font;
	CGSize titleSize = [self.rowItem.model.title sizeWithFont:font];
	self.button.width = roundf(titleSize.width / 2.0) * 2.0 + 20;
	self.button.height = 28;

	self.button.center = self.boundsCenter;
	self.button.frame = CGRectIntegral(self.button.frame);
}

- (IBAction)tapped
{
	CSubmitItem* item = (CSubmitItem*)self.rowItem.model;
	void (^action)(void) = item.action;
	if(action != NULL) {
		action();
	}
}

@end
