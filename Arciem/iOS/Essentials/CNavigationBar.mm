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

#import "CNavigationBar.h"
#import "UIViewUtils.h"
#import "CView.h"

@interface CNavigationBar ()

@property(nonatomic) CGPoint lastPointInsidePoint;
@property(nonatomic) NSTimeInterval lastPointInsideTimestamp;
@property (readonly, nonatomic) CView *overlayView;

@end

@implementation CNavigationBar

@synthesize overlayView = _overlayView;
@synthesize leftView = _leftView;
@synthesize centerView = _centerView;
@synthesize rightView = _rightView;

- (void)setup
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	BOOL result = [super pointInside:point withEvent:event];

	// The Navigation Bar has a slop region extending several pixels below it. The OS creates this slop region by generating a hit test with an artificially low Y coordinate and does this immediately after a couple hit tests with a normal Y coordinate. This code causes the artificial hit test to fail, nullifying the slop region.
	if(self.ignoreSlopRegion) {
		NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
		
		if(result == YES) {
			NSTimeInterval elapsed = currentTime - self.lastPointInsideTimestamp;
//			CLogDebug(nil, @"elapsed:%f", elapsed);
			if(elapsed < 0.01) {
				if(point.y < self.lastPointInsidePoint.y) {
					result = NO;
				}
			}
		}
//		CLogDebug(nil, @"%@ pointInside:%@ withEvent:%@ result:%d", self, NSStringFromCGPoint(point), event, result);
		
		self.lastPointInsidePoint = point;
		self.lastPointInsideTimestamp = currentTime;
	}

	return result;
}

- (CView*)overlayView
{
    if(_overlayView == nil) {
        _overlayView = [[CView alloc] initWithFrame:self.bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_overlayView];
    }
    
    return _overlayView;
}

- (UIView*)leftView
{
    return _leftView;
}

- (void)setLeftView:(UIView *)leftView
{
    if(_leftView != leftView) {
        if(_leftView != nil) {
            [_leftView removeFromSuperview];
        }
        _leftView = leftView;
        if(_leftView != nil) {
            [_leftView sizeToFit];
            _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            CView* overlayView = self.overlayView;
            CFrame* frame = _leftView.cframe;
            frame.centerY = overlayView.boundsCenterY;
            frame.left = 6;
            [overlayView addSubview:_leftView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UIView*)centerView
{
    return _centerView;
}

- (void)setCenterView:(UIView *)centerView
{
    if(_centerView != centerView) {
        if(_centerView != nil) {
            [_centerView removeFromSuperview];
        }
        _centerView = centerView;
        if(_centerView != nil) {
            [_centerView sizeToFit];
            _centerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            CView* overlayView = self.overlayView;
            CFrame* frame = _centerView.cframe;
            frame.centerY = overlayView.boundsCenterY;
            frame.centerX = overlayView.boundsCenterX;
            [overlayView addSubview:_centerView];
        }
    }
}

- (UIView*)rightView
{
    return _rightView;
}

- (void)setRightView:(UIView *)rightView
{
    if(_rightView != rightView) {
        if(_rightView != nil) {
            [_rightView removeFromSuperview];
        }
        _rightView = rightView;
        if(_rightView != nil) {
            [_rightView sizeToFit];
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            CView* overlayView = self.overlayView;
            CFrame* frame = _rightView.cframe;
            frame.centerY = overlayView.boundsCenterY;
            frame.right = overlayView.boundsRight - 6;
            [overlayView addSubview:_rightView];
        }
    }
}

@end
