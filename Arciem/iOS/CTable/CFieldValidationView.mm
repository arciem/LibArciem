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
#import "CObserver.h"

static UIImage* sValidImage = nil;
static UIImage* sInvalidImage = nil;

@interface CFieldValidationView ()

@property (strong, readonly, nonatomic) UIView* newView;
@property (strong, readonly, nonatomic) UIView* validView;
@property (strong, readonly, nonatomic) UIView* invalidView;
@property (strong, readonly, nonatomic) UIView* needsValidationView;
@property (strong, readonly, nonatomic) UIView* validatingView;
@property (strong, nonatomic) UIView* contentView;
@property (strong, nonatomic) UIView* lastContentView;
@property (strong, nonatomic) CObserver* itemStateObserver;
@property (strong, nonatomic) CObserver* itemEditingObserver;

- (void)syncToState;

@end

@implementation CFieldValidationView

@synthesize validView = _validView;
@synthesize invalidView = _invalidView;
@synthesize validatingView = _validatingView;
@synthesize item = _item;
@synthesize newView = _newView;
@synthesize needsValidationView = _needsValidationView;
@synthesize contentView = _contentView;

- (void)setup
{
	[super setup];
	[self syncToState];
	self.userInteractionEnabled = NO;
	self.validMarkTintColor = [[UIColor greenColor] colorByDarkeningFraction:0.2];
	self.invalidMarkTintColor = [[UIColor redColor] colorByDarkeningFraction:0.1];
	
	self.itemStateObserver = [CObserver observerWithKeyPath:@"state" action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self armSyncToState];
	} initial:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self armSyncToState];
	}];
	
	self.itemEditingObserver = [CObserver observerWithKeyPath:@"isEditing" action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self armSyncToState];
	}];
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
	if(_validView == nil) {
		if(sValidImage == nil) {
			sValidImage = [self imageNamed:@"FieldValidMark" tintColor:self.validMarkTintColor];
		}
		_validView = [self viewWithImage:sValidImage tintColor:self.validMarkTintColor];
	}
	return _validView;
}

- (UIView*)invalidView
{
	if(_invalidView == nil) {
		if(sInvalidImage == nil) {
			sInvalidImage = [self imageNamed:@"FieldInvalidMark" tintColor:self.invalidMarkTintColor];
		}
		_invalidView = [self viewWithImage:sInvalidImage tintColor:self.invalidMarkTintColor];
	}
	return _invalidView;
}

- (UIView*)newView
{
	return _newView;
}

- (UIView*)needsValidationView
{
	return _needsValidationView;
}

- (UIView*)validatingView
{
	if(_validatingView == nil) {
		_validatingView = [self viewWithImage:nil tintColor:[UIColor blueColor]];
	}
	return _validatingView;
}

- (CItem*)item
{
	return _item;
}

- (void)setItem:(CItem *)item
{
	if(_item != item) {
		[self.itemStateObserver removeObject:_item];
		[self.itemEditingObserver removeObject:_item];
		_item = item;
		[self.itemStateObserver addObject:_item];
		[self.itemEditingObserver addObject:_item];
	}
}

- (UIView*)contentView
{
	return _contentView;
}

- (void)setContentView:(UIView *)contentView
{
	if(_contentView != contentView) {
		[self.lastContentView removeFromSuperview];
		self.lastContentView = _contentView;
		_contentView = contentView;
		
		if(_contentView != nil) {
			[self addSubview:_contentView];
		}

		_contentView.frame = self.bounds;
		_contentView.alpha = 0.0;
		[UIView animateWithDuration:0.3 animations:^{
			_contentView.alpha = 1.0;
			self.lastContentView.alpha = 0.0;
		}];
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
			if(self.item.isNew) {
				self.contentView = self.newView;
			} else {
				if(self.item.isEditing) {
					self.contentView = self.validView;
				} else {
					self.contentView = self.newView;
				}
			}
			break;
		case CItemStateInvalid:
			self.contentView = self.item.isNew ? self.newView : self.invalidView;
			break;
	}
}

- (void)armSyncToState
{
	[NSThread performBlockOnMainThread:^{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncToState) object:nil];
		[self performSelector:@selector(syncToState) withObject:nil afterDelay:0.2];
	}];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(20, 20);
}

@end
