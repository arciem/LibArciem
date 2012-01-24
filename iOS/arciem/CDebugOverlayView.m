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

@end

@implementation CDebugOverlayView

@synthesize contentView = contentView_;
@synthesize orientation = orientation_;
@synthesize lastSyncOrientation = lastSyncOrientation_;
@synthesize contentEdgeInsets = contentEdgeInsets_;
@synthesize justMovedToSuperview = justMovedToSuperview_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_DEBUG_OVERLAY_VIEW", YES);
}

- (void)setup
{
	[super setup];
	
//	self.debugColor = [UIColor blueColor];
	self.userInteractionEnabled = NO;
	self.lastSyncOrientation = [UIApplication sharedApplication].statusBarOrientation;
	self.orientation = self.lastSyncOrientation;
	CView* contentView = [[CView alloc] initWithFrame:CGRectZero];
//	contentView.debugColor = [UIColor redColor];
	contentView.userInteractionEnabled = NO;
	self.contentView = contentView;
//	self.contentEdgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
}

- (void)syncContentViewFrameAnimated:(BOOL)animated
{
	CLogTrace(@"C_DEBUG_OVERLAY_VIEW", @"syncContentViewFrameAnimated:%d", animated);
	CGRect bounds = self.bounds;
	CGRect contentBounds = bounds;
	CGFloat contentCenterX = 0.0;
	CGFloat contentCenterY = 0.0;
	CGFloat hInsets = self.contentEdgeInsets.left + self.contentEdgeInsets.right;
	CGFloat vInsets = self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
	CGFloat hOffset = (self.contentEdgeInsets.left - self.contentEdgeInsets.right) / 2;
	CGFloat vOffset = (self.contentEdgeInsets.top - self.contentEdgeInsets.bottom) / 2;
	if(UIInterfaceOrientationIsPortrait(self.orientation)) {
		contentBounds.size.width = bounds.size.width - hInsets;
		contentBounds.size.height = bounds.size.height - vInsets;
		contentCenterX = self.boundsCenterX + hOffset;
	} else if(UIInterfaceOrientationIsLandscape(self.orientation)) {
		contentBounds.size.width = bounds.size.height - hInsets;
		contentBounds.size.height = bounds.size.width - vInsets;
		contentCenterY = self.boundsCenterY - hOffset;
	}

	CGFloat rotationAngle = 0.0;
	switch(self.orientation) {
		case UIInterfaceOrientationPortrait:
			contentCenterY = self.boundsCenterY + vOffset;
			rotationAngle = 0.0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			contentCenterY = self.boundsCenterY - vOffset;
			rotationAngle = M_PI;
			break;
		case UIInterfaceOrientationLandscapeRight:
			contentCenterX = self.boundsCenterX - vOffset;
			rotationAngle = M_PI/2;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			contentCenterX = self.boundsCenterX + vOffset;
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
	if(UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
		if(orientation_ != orientation) {
			orientation_ = orientation;
			[self syncContentViewFrameAnimated:animated];
		}
	}
}

- (UIInterfaceOrientation)orientation
{
	return orientation_;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
	[self setOrientation:orientation animated:NO];
}

- (UIEdgeInsets)contentEdgeInsets
{
	return contentEdgeInsets_;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
	contentEdgeInsets_ = contentEdgeInsets;
	[self syncContentViewFrameAnimated:NO];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if(self.superview != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		self.frame = self.superview.bounds;
		self.justMovedToSuperview = YES;
	} else {
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
