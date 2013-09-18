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
#import "DeviceUtils.h"

@interface CUserTrackingBarButtonItem ()

@property (strong, readwrite, nonatomic) MKMapView* mapView;
@property (readonly, nonatomic) CGSize shadowOffset;
@property (readonly, nonatomic) UIColor *shadowColor;
@property (strong, readonly, nonatomic) UIImage* noFollowImage;
@property (strong, readonly, nonatomic) UIImage* followImage;
@property (strong, readonly, nonatomic) UIImage* followWithHeadingImage;
@property (strong, nonatomic) UIButton* button;

- (void)syncAnimated:(BOOL)animated;

@end

@implementation CUserTrackingBarButtonItem

@synthesize noFollowImage = _noFollowImage;
@synthesize followImage = _followImage;
@synthesize followWithHeadingImage = _followWithHeadingImage;
@synthesize onColor = _onColor;
@synthesize offColor = _offColor;

- (id)initWithMapView:(MKMapView*)mapView
{
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	if(self = [super initWithCustomView:self.button]) {
		self.mapView = mapView;

//		self.button.showsTouchWhenHighlighted = YES;
		self.button.adjustsImageWhenHighlighted = YES;
		
        _onColor = [UIColor yellowColor];
        _offColor = [UIColor systemNavigationBlue];
        
		[self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
		
		CGRect frame = {CGPointZero, self.noFollowImage.size};
		self.button.frame = frame;
		self.width = frame.size.width;
		
		[self syncAnimated:NO];
	} else {
		self.button = nil;
	}
	return self;
}

- (UIColor *)onColor {
    return _onColor;
}

- (void)setOnColor:(UIColor *)onColor {
    _onColor = onColor;
    _followImage = nil;
    _followWithHeadingImage = nil;
    [self syncAnimated:NO];
}

- (UIColor *)offColor {
    return _offColor;
}

- (void)setOffColor:(UIColor *)offColor {
    _offColor = offColor;
    _noFollowImage = nil;
    [self syncAnimated:NO];
}

- (CGSize)shadowOffset {
    static CGSize offset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(IsOSVersionAtLeast7()) {
            offset = CGSizeZero;
        } else {
            offset = CGSizeMake(0, -1);
        }
    });
    return offset;
}

- (UIColor *)shadowColor {
    static UIColor *color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(IsOSVersionAtLeast7()) {
            color = nil;
        } else {
            color = [UIColor colorWithWhite:0 alpha:0.5];
        }
    });
    return color;
}

- (UIImage *)noFollowImage {
    if(_noFollowImage == nil) {
		_noFollowImage = [UIImage imageWithShapeImage:[UIImage imageNamed:@"Tracking~iPad"] tintColor:self.offColor shadowColor:self.shadowColor shadowOffset:self.shadowOffset shadowBlur:0.0];
    }
    return _noFollowImage;
}

- (UIImage *)followImage {
    if(_followImage == nil) {
		_followImage = [UIImage imageWithShapeImage:[UIImage imageNamed:@"Tracking~iPad"] tintColor:self.onColor shadowColor:self.shadowColor shadowOffset:self.shadowOffset shadowBlur:0.0];
    }
    return _followImage;
}

- (UIImage *)followWithHeadingImage {
    if(_followWithHeadingImage == nil) {
		_followWithHeadingImage = [UIImage imageWithShapeImage:[UIImage imageNamed:@"TrackingWithHeading~iPad"] tintColor:self.onColor shadowColor:nil shadowOffset:self.shadowOffset shadowBlur:0.0];
    }
    return _followWithHeadingImage;
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

- (void)syncAnimated:(BOOL)animated
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
	
	BOOL animate = animated && (newImage != oldImage) &&
	(newImage == self.followWithHeadingImage || 
	 oldImage == self.followWithHeadingImage);
	
	[self setImage:newImage animated:animate];
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
	[self syncAnimated:YES];
}

- (void)didChangeUserTrackingMode
{
	[self syncAnimated:YES];
}

@end
