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
#import "CSlowCall.h"
#import "ObjectUtils.h"

@interface CButtonTableViewCell ()

@property (nonatomic) CObserver* modelDisabledObserver;
@property (readwrite, nonatomic) UIButton* button;
@property (readonly, nonatomic) CSlowCall* syncStateSlowCall;
@property (nonatomic) CView *redView;

@end

@implementation CButtonTableViewCell

@synthesize button = button_;
@synthesize modelDisabledObserver = modelDisabledObserver_;
@synthesize syncStateSlowCall = syncStateSlowCall_;


- (UILabel *)textLabel {
    return nil;
}

- (void)setup
{
	[super setup];

//    self.contentView.backgroundColor = [UIColor blueColor];

    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
	self.button.backgroundColor = [UIColor redColor];
	[self.button addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:self.button];

#if 0
    self.redView = [[CView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.redView.translatesAutoresizingMaskIntoConstraints = NO;
    self.redView.debugName = @"redView";
    self.redView.backgroundColor = [UIColor redColor];
    [self.redView addConstraint:[self.redView constrainWidthEqualTo:20]];
    [self.redView addConstraint:[self.redView constrainHeightEqualTo:20]];
    [self.contentView addSubview:self.redView];
#endif

    [self.contentView addConstraint:[self.button constrainCenterXEqualToCenterXOfItem:self.contentView]];
    [self.contentView addConstraint:[self.button constrainCenterYEqualToCenterYOfItem:self.contentView]];
}

- (CSlowCall*)syncStateSlowCall
{
	if(syncStateSlowCall_ == nil) {
		BSELF;
		syncStateSlowCall_ = [CSlowCall slowCallWithDelay:0.2 block:^(id object) {
			[bself syncToState];
		}];
	}
	
	return syncStateSlowCall_;
}

//- (CGSize)sizeThatFits:(CGSize)size
//{
//	size.height = roundf(size.height * 1.2);
//	return size;
//}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (BOOL)isButtonEnabled
{
	return !self.rowItem.model.isDisabled;
}

- (void)syncToState
{
	[self.syncStateSlowCall disarm];
	self.button.enabled = self.isButtonEnabled;
}

- (void)setNeedsSyncToState
{
	[self.syncStateSlowCall arm];
}

- (void)syncToRowItem
{
	[super syncToRowItem];
	
	if(self.rowItem == nil) {
		self.modelDisabledObserver = nil;
	} else {
		[self.button setTitle:self.rowItem.model.title forState:UIControlStateNormal];
		
		BSELF;
		CObserverBlock action = ^(id object, NSNumber* newValue, NSNumber* oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
			[bself setNeedsSyncToState];
		};
		
		self.modelDisabledObserver = [CObserver observerWithKeyPath:@"isDisabled" ofObject:self.rowItem.model action:action initial:action];
	}
}

//- (void)layoutSubviews
//{
//	[super layoutSubviews];
//	
//	UIFont* font = self.button.titleLabel.font;
//	CGSize titleSize = [self.rowItem.model.title sizeWithFont:font];
//	CFrame* buttonFrame = self.button.cframe;
//	buttonFrame.width = roundf(titleSize.width / 2.0) * 2.0 + 20;
//	buttonFrame.height = 28;
//	buttonFrame.center = self.boundsCenter;
//}

- (IBAction)tapped
{
	CSubmitItem* item = (CSubmitItem*)self.rowItem.model;
	void (^action)(void) = item.action;
	if(action != NULL) {
		action();
	}
}

@end
