/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
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

#import "CView.h"
#import "DeviceUtils.h"
#import "UIViewUtils.h"
#import "Geom.h"
#import "CTapToDismissKeyboardManager.h"

@interface CView ()

@property (nonatomic) BOOL observingKeyboard;
@property (nonatomic) CTapToDismissKeyboardManager* tapToDismissKeyboardManager;

@end

@implementation CView

@synthesize debugColor = _debugColor;
@synthesize keyboardAdjustmentType = _keyboardAdjustmentType;
@synthesize layoutView = _layoutView;

#pragma mark - Lifecycle

+ (void)initialize
{
//	CLogSetTagActive(@"C_VIEW", YES);
}

- (void)setup
{
    [self syncToLayoutView];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		[self setup];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self setup];
}

- (void)dealloc
{
	self.debugColor = nil;
	self.layoutDelegate = nil;
	self.keyboardAdjustmentType = kViewKeyboardAdjustmentTypeNone;
}

- (void)syncToLayoutView {
    if(self.layoutView) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if([self.layoutDelegate respondsToSelector:@selector(viewLayoutSubviews:)]) {
		[self.layoutDelegate viewLayoutSubviews:self];
	}
}

- (BOOL)layoutView {
    return _layoutView;
}

- (void)setLayoutView:(BOOL)layoutView {
    _layoutView = layoutView;
    [self syncToLayoutView];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
	if(self.debugColor != nil) {
		[self fillRect:self.bounds color:[self.debugColor colorWithAlphaComponent:0.25]];
		[self drawCrossedBox:self.bounds color:self.debugColor lineWidth:1.0];
	}
}

- (void)setDebugColor:(UIColor *)color
{
	if(_debugColor != color) {
		_debugColor = color;
		[self setNeedsDisplay];
	}
}

#pragma mark - Keyboard Adjustment

- (void)startObservingKeyboard
{
	if(!self.observingKeyboard) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillMove:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillMove:) name:UIKeyboardWillHideNotification object:nil];
		self.observingKeyboard = YES;
	}
}

- (void)stopObservingKeyboard
{
	if(self.observingKeyboard) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
		self.observingKeyboard = NO;
	}
}

- (void)setKeyboardAdjustmentType:(CViewKeyboardAdjustmentType)aType
{
	if(_keyboardAdjustmentType != aType) {
		_keyboardAdjustmentType = aType;
		switch(_keyboardAdjustmentType) {
			case kViewKeyboardAdjustmentTypeNone:
				[self stopObservingKeyboard];
				break;
			case kViewKeyboardAdjustmentTypeShrink:
				[self startObservingKeyboard];
				break;
			case kViewKeyboardAdjustmentTypeBottomConstraint:
				[self startObservingKeyboard];
				break;
		}
	}
}

// The returned rectangle is in the receiver's superview's coordinate system to faciliate the adjustment of the receiver's frame within that same system.
- (CGRect)endKeyboardRectangleFromNotification:(NSNotification*)notification
{
	CGRect keyboardScreenFrame = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGRect keyboardSuperviewFrame = [self.superview convertRect:keyboardScreenFrame fromView:nil];		
	return keyboardSuperviewFrame;
}

- (void)keyboardWillMove:(NSNotification*)notification
{
	if(self.keyboardAdjustmentType != kViewKeyboardAdjustmentTypeNone) {
		CGRect endKeyboardRectangle = [self endKeyboardRectangleFromNotification:notification];
		// The keyboard doesn't just move up and down-- when pushing a new UIViewController on a UINavigationController's stack, the keyboard can actually animate sideways out of the frame without moving down at all. So instead of merely following the top of the keyboard, we actually need to see whether it's final position intersects the receiver's superview at all. If not, then the bottom of the receiver should be at the maximum position, regardless of the vertical position of the keyboard.
		CGFloat newMaxY = self.superview.boundsBottom;
		if(CGRectIntersectsRect(endKeyboardRectangle, self.superview.bounds)) {
			newMaxY = CGRectGetMinY(endKeyboardRectangle);
		}
		CLogTrace(@"C_VIEW", @"%@ keyboardWillMove endKeyboardRectangle:%@ newMaxY:%f", self, NSStringFromCGRect(endKeyboardRectangle), newMaxY);

		CGFloat duration = [(notification.userInfo)[UIKeyboardAnimationDurationUserInfoKey] floatValue];
		UIViewAnimationCurve curve = (UIViewAnimationCurve)[(notification.userInfo)[UIKeyboardAnimationCurveUserInfoKey] intValue];
        UIViewAnimationOptions options = curve << 16;
        
        if(self.keyboardAdjustmentType == kViewKeyboardAdjustmentTypeBottomConstraint) {
            NSAssert1(self.bottomConstraint != nil, @"%@ bottomConstraint not set.", self);
//            CLogDebug(nil, @"%@ BEFORE newMaxY: %f boundsBottom:%f", self, newMaxY, self.superview.boundsBottom);
//            self.bottomConstraint.constant = newMaxY - self.superview.boundsBottom;
            self.bottomConstraint.constant = self.superview.boundsBottom - newMaxY;
            [self setNeedsUpdateConstraints];
        }
        
		[UIView animateWithDuration:duration delay:0 options:options animations:^{
            if(self.keyboardAdjustmentType == kViewKeyboardAdjustmentTypeBottomConstraint) {
                [self layoutIfNeeded];
            } else {
                self.cframe.flexibleBottom = newMaxY;
            }
		} completion:^(BOOL finished) {
//            CLogDebug(nil, @"%@ AFTER newMaxY: %f boundsBottom:%f", self, newMaxY, self.superview.boundsBottom);
//            [self printViewHierarchy];
        }];
	}
}

#if 0
- (BOOL)tapResignsFirstResponder
{
	return self.tapToDismissKeyboardManager != nil;
}

- (void)setTapResignsFirstResponder:(BOOL)tapResignsFirstResponder
{
	if(self.tapResignsFirstResponder != tapResignsFirstResponder) {
		if(tapResignsFirstResponder) {
			self.tapToDismissKeyboardManager = [[CTapToDismissKeyboardManager alloc] initWithView:self];
		} else {
			self.tapToDismissKeyboardManager = nil;
		}
	}
}
#endif

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// Empty so subclasses can call super with confidence.
}

@end
