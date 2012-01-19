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

@property (nonatomic) UIDeviceOrientation orientation;

@end

@implementation CDebugOverlayView

@synthesize contentView = contentView_;
@synthesize orientation = orientation_;
@synthesize contentEdgeInsets = contentEdgeInsets_;
@synthesize supportedInterfaceOrientations = supportedInterfaceOrientations_;

- (void)setup
{
	[super setup];
	
//	self.debugColor = [UIColor blueColor];
	self.userInteractionEnabled = NO;
	self.orientation = UIDeviceOrientationPortrait;
	self.supportedInterfaceOrientations = [NSSet setWithObjects:
										   [NSNumber numberWithInt:UIInterfaceOrientationPortrait], 
										   [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown], 
										   [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft], 
										   [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], 
										   nil];
	CView* contentView = [[CView alloc] initWithFrame:CGRectZero];
	contentView.debugColor = [UIColor redColor];
	contentView.userInteractionEnabled = NO;
	self.contentView = contentView;
//	self.contentEdgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
}

- (void)syncContentViewFrameAnimated:(BOOL)animated
{
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
		case UIDeviceOrientationPortrait:
			contentCenterY = self.boundsCenterY + vOffset;
			rotationAngle = 0.0;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			contentCenterY = self.boundsCenterY - vOffset;
			rotationAngle = M_PI;
			break;
		case UIDeviceOrientationLandscapeLeft:
			contentCenterX = self.boundsCenterX - vOffset;
			rotationAngle = M_PI/2;
			break;
		case UIDeviceOrientationLandscapeRight:
			contentCenterX = self.boundsCenterX + vOffset;
			rotationAngle = -M_PI/2;
			break;
		default:
			break;
	}
	
	CGPoint contentCenter = CGPointMake(contentCenterX, contentCenterY);
	CGAffineTransform contentTransform = CGAffineTransformMakeRotation(rotationAngle);

	NSTimeInterval duration = animated ? 0.4 : 0.0;
	[UIView animateWithDuration:duration animations:^{
		contentView_.bounds = contentBounds;
		contentView_.center = contentCenter;
		contentView_.transform = contentTransform;
	}];
}

- (void)setOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated
{
	if(UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
		if([self.supportedInterfaceOrientations containsObject:[NSNumber numberWithInt:orientation]]) {
			if(orientation_ != orientation) {
				orientation_ = orientation;
				[self syncContentViewFrameAnimated:animated];
			}
		}
	}
}

- (UIDeviceOrientation)orientation
{
	return orientation_;
}

- (void)setOrientation:(UIDeviceOrientation)orientation
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
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
		self.frame = self.superview.bounds;
		[self syncContentViewFrameAnimated:NO];
	} else {
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	}
}

- (void)deviceOrientationDidChange:(NSNotification*)notification
{
//	CLogDebug(nil, @"%@ deviceOrientationDidChange:%@", self, notification);
	BOOL animated = [(NSNumber*)[notification.userInfo objectForKey:@"UIDeviceOrientationRotateAnimatedUserInfoKey"] boolValue];
	[self setOrientation:[UIDevice currentDevice].orientation animated:animated];
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
