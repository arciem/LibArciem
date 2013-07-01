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

#import "CUserTrackingBarButtonItem.h"
#import "UIImageUtils.h"
#import "UIColorUtils.h"

@interface CUserTrackingBarButtonItem ()

@property (strong, readwrite, nonatomic) MKMapView* mapView;
@property (strong, nonatomic) UIImage* noFollowImage;
@property (strong, nonatomic) UIImage* followImage;
@property (strong, nonatomic) UIImage* followWithHeadingImage;
@property (strong, nonatomic) UIButton* button;

- (void)sync;

@end

@implementation CUserTrackingBarButtonItem

- (id)initWithMapView:(MKMapView*)mapView
{
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	if(self = [super initWithCustomView:self.button]) {
		self.mapView = mapView;

//		self.button.showsTouchWhenHighlighted = YES;
		self.button.adjustsImageWhenHighlighted = YES;
		
		[self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];

		UIColor* onColor = [UIColor yellowColor];
		self.noFollowImage = [UIImage imageWithShapeImage:[UIImage imageNamed:@"Tracking~iPad"] tintColor:[UIColor whiteColor] shadowColor:[UIColor colorWithWhite:0 alpha:0.5] shadowOffset:CGSizeMake(0,-1) shadowBlur:0.0];
		self.followImage = [UIImage imageWithShapeImage:[UIImage imageNamed:@"Tracking~iPad"] tintColor:onColor shadowColor:[UIColor colorWithWhite:0 alpha:0.5] shadowOffset:CGSizeMake(0,-1) shadowBlur:0.0];
		self.followWithHeadingImage = [UIImage imageWithShapeImage:[UIImage imageNamed:@"TrackingWithHeading~iPad"] tintColor:onColor shadowColor:nil shadowOffset:CGSizeMake(0,-1) shadowBlur:0.0];
		
		CGRect frame = {CGPointZero, self.noFollowImage.size};
		self.button.frame = frame;
		self.width = frame.size.width;
		
		[self sync];
	} else {
		self.button = nil;
	}
	return self;
}

- (void)setImage:(UIImage*)image animated:(BOOL)animated
{
	if(animated) {
		[UIView animateWithDuration:0.3 animations:^{
			self.button.transform = CGAffineTransformMakeScale(0.01, 0.01);
		} completion:^(BOOL finished) {
			[self.button setImage:image forState:UIControlStateNormal];
			[UIView animateWithDuration:0.3 animations:^{
				self.button.transform = CGAffineTransformIdentity;
			} completion:^(BOOL finished) {
			}];
		}];
	} else {
		[self.button setImage:image forState:UIControlStateNormal];
	}
}

- (void)sync
{
	UIImage* oldImage = [self.button imageForState:UIControlStateNormal];
	UIImage* newImage = nil;
	switch(self.mapView.userTrackingMode) {
		case MKUserTrackingModeNone:
		default:
			newImage = self.noFollowImage;
			break;
		case MKUserTrackingModeFollow:
			newImage = self.followImage;
			break;
		case MKUserTrackingModeFollowWithHeading:
			newImage = self.followWithHeadingImage;
			break;
	}
	
	BOOL animated = (newImage != oldImage) && 
	(newImage == self.followWithHeadingImage || 
	 oldImage == self.followWithHeadingImage);
	
	[self setImage:newImage animated:animated];
}

- (void)buttonTapped
{
	switch(self.mapView.userTrackingMode) {
		case MKUserTrackingModeNone:
			[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
			break;
		case MKUserTrackingModeFollow:
			[self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
			break;
		case MKUserTrackingModeFollowWithHeading:
			[self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
			break;
	}
	[self sync];
}

- (void)didChangeUserTrackingMode
{
	[self sync];
}

@end
