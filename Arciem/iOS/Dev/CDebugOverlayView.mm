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

#import "CDebugOverlayView.h"
#import "UIViewUtils.h"

@interface CDebugOverlayView ()

@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic) UIInterfaceOrientation lastSyncOrientation;
@property (nonatomic) BOOL justMovedToSuperview;
@property (strong, nonatomic) NSTimer* stayOnTopTimer;

@end

@implementation CDebugOverlayView

@synthesize contentView = contentView_;
@synthesize orientation = orientation_;
@synthesize lastSyncOrientation = lastSyncOrientation_;
@synthesize justMovedToSuperview = justMovedToSuperview_;
@synthesize stayOnTopTimer = stayOnTopTimer_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_DEBUG_OVERLAY_VIEW", YES);
}

- (void)setup
{
	[super setup];
	
//	self.debugColor = [UIColor blueColor];
	self.lastSyncOrientation = [UIApplication sharedApplication].statusBarOrientation;
	self.orientation = self.lastSyncOrientation;
	CView* contentView = [[CView alloc] initWithFrame:CGRectZero];
//	contentView.debugColor = [UIColor redColor];
	self.contentView = contentView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* result = nil;
	
	CGPoint p = [self convertPoint:point toView:self.contentView];
	result = [self.contentView hitTest:p withEvent:event];
	if(result == self.contentView) {
		result = nil;
	}
	
	return result;
}

- (void)syncContentViewFrameAnimated:(BOOL)animated
{
	CLogTrace(@"C_DEBUG_OVERLAY_VIEW", @"syncContentViewFrameAnimated:%d", animated);
	CGRect bounds = self.bounds;
	CGRect contentBounds = bounds;
	CGFloat contentCenterX = 0.0;
	CGFloat contentCenterY = 0.0;
	if(UIInterfaceOrientationIsPortrait(self.orientation)) {
		contentBounds.size.width = bounds.size.width;
		contentBounds.size.height = bounds.size.height;
		contentCenterX = self.boundsCenterX;
	} else if(UIInterfaceOrientationIsLandscape(self.orientation)) {
		contentBounds.size.width = bounds.size.height;
		contentBounds.size.height = bounds.size.width;
		contentCenterY = self.boundsCenterY;
	}

	CGFloat rotationAngle = 0.0;
	switch(self.orientation) {
		case UIInterfaceOrientationPortrait:
			contentCenterY = self.boundsCenterY;
			rotationAngle = 0.0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			contentCenterY = self.boundsCenterY;
			rotationAngle = M_PI;
			break;
		case UIInterfaceOrientationLandscapeRight:
			contentCenterX = self.boundsCenterX;
			rotationAngle = M_PI/2;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			contentCenterX = self.boundsCenterX;
			rotationAngle = -M_PI/2;
			break;
		default:
			break;
	}
	
	CGPoint contentCenter = CGPointMake(contentCenterX, contentCenterY);
	CGAffineTransform contentTransform = CGAffineTransformMakeRotation(rotationAngle);

	NSTimeInterval duration = 0.4;
	if(!animated) {
		duration = 0.0;
	} else {
		if(self.orientation != self.lastSyncOrientation) {
			if(UIInterfaceOrientationIsPortrait(self.orientation) == UIInterfaceOrientationIsPortrait(self.lastSyncOrientation)) {
				// Must be doing a 180° rotation, so do it slower.
				duration = 0.8;
			}
		}
	}
	
	self.lastSyncOrientation = self.orientation;
	
	[UIView animateWithDuration:duration animations:^{
		contentView_.bounds = contentBounds;
		contentView_.center = contentCenter;
		contentView_.transform = contentTransform;
	}];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated
{
	CLogTrace(@"C_DEBUG_OVERLAY_VIEW", @"setOrientation:%d lastSyncOrientation:%d animated:%d", orientation, self.lastSyncOrientation, animated);
//	if(UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
		if(orientation_ != orientation) {
			orientation_ = orientation;
			[self syncContentViewFrameAnimated:animated];
		}
//	}
}

- (UIInterfaceOrientation)orientation
{
	return orientation_;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
	[self setOrientation:orientation animated:NO];
}

- (void)stayOnTop
{
//	NSUInteger oldIndex = self.indexInSubviews;
	
	[self bringToFront];
//	NSUInteger newIndex = self.indexInSubviews;
//	CLogDebug(nil, @"stayOnTop superview:%@ runLoopMode:%@ oldIndex:%d newIndex:%d", self.superview, [[NSRunLoop currentRunLoop] currentMode], oldIndex, newIndex);
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if(self.superview != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		self.stayOnTopTimer = [[NSTimer alloc] initWithFireDate:[NSDate distantPast] interval:1.0 target:self selector:@selector(stayOnTop) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:self.stayOnTopTimer forMode:NSRunLoopCommonModes];
		self.frame = self.superview.bounds;
		self.justMovedToSuperview = YES;
	} else {
		[self.stayOnTopTimer invalidate];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	}
}

- (void)orientationDidChange:(NSNotification*)notification
{
//	CLogDebug(nil, @"%@ orientationDidChange:%@", self, notification);
	BOOL animated = !self.justMovedToSuperview;
	[self setOrientation:[UIApplication sharedApplication].statusBarOrientation animated:animated];
	self.justMovedToSuperview = NO;
}

- (UIView*)contentView
{
	return contentView_;
}

- (void)setContentView:(UIView *)contentView
{
	if(contentView_ != contentView) {
		[contentView_ removeFromSuperview];
		contentView_ = contentView;
		if(contentView_ != nil) {
			[self addSubview:contentView_];
			[self syncContentViewFrameAnimated:NO];
		}
	}
}

@end
