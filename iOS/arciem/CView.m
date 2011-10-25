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

@interface CView ()

@property(nonatomic) BOOL observingKeyboard;
@property(nonatomic) BOOL isOS_3_2;

@end

@implementation CView

@synthesize debugColor = debugColor_;
@synthesize keyboardAdjustmentType = keyboardAdjustmentType_;
@synthesize observingKeyboard;
@synthesize isOS_3_2;

#pragma mark -
#pragma mark Lifecycle

- (void)setup
{
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	self.isOS_3_2 = IsOSVersionAtLeast(@"3.2");
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
	self.keyboardAdjustmentType = kViewKeyboardAdjustmentTypeNone;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
	if(self.debugColor != nil) {
		[self fillRect:self.bounds color:[self.debugColor colorWithAlphaComponent:0.25]];
		[self drawCrossedBox:self.bounds color:self.debugColor lineWidth:1.0];
	}
}

- (void)setDebugColor:(UIColor *)color
{
	if(debugColor_ != color) {
		debugColor_ = color;
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Keyboard Adjustment

- (void)startObservingKeyboard
{
	if(!self.observingKeyboard) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
	if(keyboardAdjustmentType_ != aType) {
		keyboardAdjustmentType_ = aType;
		switch(keyboardAdjustmentType_) {
			case kViewKeyboardAdjustmentTypeNone:
				[self stopObservingKeyboard];
				break;
			case kViewKeyboardAdjustmentTypeShrink:
				[self startObservingKeyboard];
				break;
		}
	}
}

- (CGRect)endKeyboardRectangleFromNotification:(NSNotification*)notification
{
	// Note: We are using the literal strings for UIKeyboardBoundsUserInfoKey and UIKeyboardCenterEndUserInfoKey because they are deprecated
	// when building against SDK 3.2 or later, but we're still supporting a minimum deployment platform of 3.0. Using the literal strings
	// avoids compile-time deprecation warnings.

	CGRect keyboardScreenFrame;
	CGRect keyboardSuperviewFrame;
	
	if (self.isOS_3_2) {
		keyboardScreenFrame = [[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
		keyboardSuperviewFrame = [self.superview convertRect:keyboardScreenFrame fromView:nil];		
	} else {
		CGPoint center = [[notification.userInfo objectForKey:@"UIKeyboardCenterEndUserInfoKey"] CGPointValue];
		keyboardScreenFrame = [[notification.userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
		keyboardScreenFrame = [Geom alignRectMid:keyboardScreenFrame toPoint:center];
		//CLogDebug(nil, @"endKeyboardRectangle before convertRect: %@", NSStringFromCGRect(keyboardScreenFrame));
		keyboardSuperviewFrame = [self.superview convertRect:keyboardScreenFrame fromView:nil];
	}
	return keyboardSuperviewFrame;
}

- (void)setAnimationKeysFromNotification:(NSNotification*)notification
{
	CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	[UIView setAnimationDuration:duration];
	UIViewAnimationCurve curve = (UIViewAnimationCurve)[[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
	[UIView setAnimationCurve:curve];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
//	CLogDebug(nil, @"keyboardWillShow: %@", notification.userInfo);
	CGRect endKeyboardRectangle = [self endKeyboardRectangleFromNotification:notification];
//	CLogDebug(nil, @"endKeyboardRectangle: %@", NSStringFromCGRect(endKeyboardRectangle));
	
	if(self.keyboardAdjustmentType == kViewKeyboardAdjustmentTypeShrink) {
		[UIView beginAnimations:@"keyboardAdjust" context:nil];
		[self setAnimationKeysFromNotification:notification];
		self.flexibleBottom = CGRectGetMinY(endKeyboardRectangle);
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification*)notification
{
//	CLogDebug(nil, @"keyboardWillHide: %@", notification.userInfo);
	CGRect endKeyboardRectangle = [self endKeyboardRectangleFromNotification:notification];
//	CLogDebug(nil, @"endKeyboardRectangle: %@", NSStringFromCGRect(endKeyboardRectangle));

	if(self.keyboardAdjustmentType == kViewKeyboardAdjustmentTypeShrink) {
		[UIView beginAnimations:@"keyboardAdjust" context:nil];
		[self setAnimationKeysFromNotification:notification];
		self.flexibleBottom = CGRectGetMinY(endKeyboardRectangle);
		[UIView commitAnimations];
	}
}

@end
