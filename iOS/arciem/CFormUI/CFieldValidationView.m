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

#import "CFieldValidationView.h"
#import "UIImageUtils.h"
#import "ThreadUtils.h"
#import "UIColorUtils.h"

static UIImage* sValidImage = nil;
static UIImage* sInvalidImage = nil;

@interface CFieldValidationView ()

@property (strong, readonly, nonatomic) UIView* validView;
@property (strong, readonly, nonatomic) UIView* invalidView;
@property (strong, readonly, nonatomic) UIView* needsValidationView;
@property (strong, readonly, nonatomic) UIView* validatingView;
@property (strong, nonatomic) UIView* contentView;
@property (strong, nonatomic) UIView* lastContentView;

- (void)syncToState;

@end

@implementation CFieldValidationView

@synthesize item = item_;
@synthesize validView = validView_;
@synthesize invalidView	= invalidView_;
@synthesize needsValidationView = needsValidationView_;
@synthesize validatingView = validatingView_;
@synthesize contentView = contentView_;
@synthesize lastContentView = lastContentView_;
@synthesize validMarkTintColor = validMarkTintColor_;
@synthesize invalidMarkTintColor = invalidMarkTintColor_;

- (void)setup
{
	[super setup];
	[self syncToState];
	self.userInteractionEnabled = NO;
	self.validMarkTintColor = [[UIColor greenColor] colorByDarkeningFraction:0.2];
	self.invalidMarkTintColor = [[UIColor redColor] colorByDarkeningFraction:0.1];
}

- (void)dealloc
{
	self.item = nil;
}

- (UIImage*)imageNamed:(NSString*)imageName tintColor:(UIColor*)tintColor
{
	UIImage* image = [UIImage imageNamed:imageName];
	if(image != nil) {
		image = [UIImage imageWithShapeImage:image tintColor:tintColor shadowColor:[UIColor colorWithWhite:0.0 alpha:0.8] shadowOffset:CGSizeMake(0.0, -1.0) shadowBlur:0];
	}
	return image;
}

- (UIView*)viewWithImage:(UIImage*)image tintColor:(UIColor*)tintColor
{
	UIView* view = nil;
	
	if(image != nil) {
		view = [[UIImageView alloc] initWithImage:image];
		view.contentMode = UIViewContentModeCenter;
	} else {
		CView* cView = [[CView alloc] initWithFrame:self.bounds];
		cView.debugColor = tintColor;
		view = cView;
	}

	return view;
}

- (UIView*)validView
{
	if(validView_ == nil) {
		if(sValidImage == nil) {
			sValidImage = [self imageNamed:@"FieldValidMark" tintColor:self.validMarkTintColor];
		}
		validView_ = [self viewWithImage:sValidImage tintColor:self.validMarkTintColor];
	}
	return validView_;
}

- (UIView*)invalidView
{
	if(invalidView_ == nil) {
		if(sInvalidImage == nil) {
			sInvalidImage = [self imageNamed:@"FieldInvalidMark" tintColor:self.invalidMarkTintColor];
		}
		invalidView_ = [self viewWithImage:sInvalidImage tintColor:self.invalidMarkTintColor];
	}
	return invalidView_;
}

- (UIView*)needsValidationView
{
	return needsValidationView_;
}

- (UIView*)validatingView
{
	if(validatingView_ == nil) {
		validatingView_ = [self viewWithImage:nil tintColor:[UIColor blueColor]];
	}
	return validatingView_;
}

- (CItem*)item
{
	return item_;
}

- (void)setItem:(CItem *)item
{
	if(item_ != item) {
		if(item_ != nil) {
			[item_ removeObserver:self forKeyPath:@"state"];
		}
		item_ = item;
		if(item_ != nil) {
			[item_ addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:NULL];
		}
	}
}

- (UIView*)contentView
{
	return contentView_;
}

- (void)setContentView:(UIView *)contentView
{
	if(contentView_ != contentView) {
		[self.lastContentView removeFromSuperview];
		self.lastContentView = contentView_;
		contentView_ = contentView;
		
		if(contentView_ != nil) {
			contentView_.frame = self.bounds;
			contentView_.alpha = 0.0;
			[self addSubview:contentView_];
			[UIView animateWithDuration:0.3 animations:^{
				contentView_.alpha = 1.0;
				self.lastContentView.alpha = 0.0;
			}];
		}
	}
}

- (void)syncToState
{
	switch(self.item.state) {
		case CItemStateNeedsValidation:
			self.contentView = self.needsValidationView;
			break;
		case CItemStateValidating:
			self.contentView = self.validatingView;
			break;
		case CItemStateValid:
			self.contentView = self.validView;
			break;
		case CItemStateInvalid:
			self.contentView = self.invalidView;
			break;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

	if(object == self.item) {
		if([keyPath isEqualToString:@"state"]) {
			[NSThread performBlockOnMainThread:^{
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncToState) object:nil];
				[self performSelector:@selector(syncToState) withObject:nil afterDelay:0.2];
			}];
		}
	}
}

@end
