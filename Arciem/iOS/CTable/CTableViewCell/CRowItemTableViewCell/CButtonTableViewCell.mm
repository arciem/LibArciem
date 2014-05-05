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
#import "DeviceUtils.h"
#import "StringUtils.h"

NSString *const CDidTapButtonNotification = @"CDidTapButtonNotification";

@interface CButtonTableViewCell ()

@property (nonatomic) CObserver* modelEnabledObserver;
@property (readwrite, nonatomic) UIButton* button;
@property (readonly, nonatomic) CSlowCall* syncStateSlowCall;
@property (nonatomic) CView *redView;

@end

@implementation CButtonTableViewCell

@synthesize syncStateSlowCall = _syncStateSlowCall;


- (UILabel *)textLabel {
    return nil;
}

- (void)setup
{
	[super setup];

    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
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
	if(_syncStateSlowCall == nil) {
		BSELF;
		_syncStateSlowCall = [CSlowCall newSlowCallWithDelay:0.2 block:^(id object) {
			[bself syncToState];
		}];
	}
	
	return _syncStateSlowCall;
}

- (NSUInteger)validationViewsNeeded
{
	return 0;
}

- (BOOL)isButtonEnabled
{
    BOOL enabled = self.rowItem.model.enabled;
    CLogTrace(@"BUTTON", @"%@ isButtonEnabled model:%@ enabled:%@", [self shortDescription], [self.rowItem.model shortDescription], @(enabled));
	return enabled;
}

- (void)syncToState
{
	[self.syncStateSlowCall disarm];

    BOOL enabled = self.buttonEnabled;
    CLogTrace(@"BUTTON", @"%@ syncToState enabled:%@", [self shortDescription], @(enabled));
	self.button.enabled = enabled;

    if([self.rowItem.model isKindOfClass:[CSubmitItem class]]) {
        if(IsOSVersionAtLeast7()) {
            if(self.buttonEnabled) {
                self.button.backgroundColor = self.tintColor;
                self.button.alpha = 1.0;
            } else {
                self.button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
                self.button.alpha = 0.3;
            }
        }
    }
}

- (void)setNeedsSyncToState
{
    CLogTrace(@"BUTTON", @"%@ setNeedsSyncToState", [self shortDescription]);
	[self.syncStateSlowCall arm];
}

- (void)syncToRowItem
{
    CLogTrace(@"BUTTON", @"%@ syncToRowItem", [self shortDescription]);
	[super syncToRowItem];
	
	if(self.rowItem == nil) {
		self.modelEnabledObserver = nil;
	} else {
		[self.button setTitle:self.rowItem.model.title forState:UIControlStateNormal];
		
        if([self.rowItem.model isKindOfClass:[CSubmitItem class]]) {
            self.button.titleLabel.font = [UIFont boldSystemFontOfSize:self.button.titleLabel.font.pointSize];
            
            if(IsOSVersionAtLeast7()) {
                [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
                self.button.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
            }
        }
        
		BSELF;
		CObserverBlock action = ^(id object, NSNumber* newEnabled, NSNumber* oldEnabled, NSKeyValueChange kind, NSIndexSet *indexes) {
            CLogTrace(@"BUTTON", @"%@ modelEnabledObserver calling setNeedsSyncToState with enabled:%@ model:%@", [bself shortDescription], newEnabled, [object shortDescription]);
			[bself setNeedsSyncToState];
		};
		
		self.modelEnabledObserver = [CObserver newObserverWithKeyPath:@"enabled" ofObject:self.rowItem.model action:action initial:action];
	}
}

- (IBAction)tapped
{
	CSubmitItem* item = (CSubmitItem*)self.rowItem.model;
	void (^action)(void) = item.action;
	if(action != NULL) {
		action();
	}
    NSDictionary *userInfo = @{@"button": self,
                               @"analyticsName": Ennull(item.analyticsName)};
    [[NSNotificationCenter defaultCenter] postNotificationName:CDidTapButtonNotification object:self userInfo:userInfo];
}

@end
