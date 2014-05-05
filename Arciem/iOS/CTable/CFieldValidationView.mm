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
#import "ObjectUtils.h"
#import "UIViewUtils.h"

static UIImage* sValidImage = nil;
static UIImage* sInvalidImage = nil;

@interface CFieldValidationView ()

@property (readonly, nonatomic) UIView* newView;
@property (readonly, nonatomic) UIView* validView;
@property (readonly, nonatomic) UIView* invalidView;
@property (readonly, nonatomic) UIView* needsValidationView;
@property (readonly, nonatomic) UIView* validatingView;
@property (nonatomic) UIView* contentView;
@property (nonatomic) UIView* lastContentView;
@property (nonatomic) CObserver* itemStateObserver;
@property (nonatomic) CObserver* itemEditingObserver;

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
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
	self.userInteractionEnabled = NO;
	self.validMarkTintColor = [[UIColor greenColor] newColorByDarkeningFraction:0.2];
	self.invalidMarkTintColor = [[UIColor redColor] newColorByDarkeningFraction:0.1];
    
    BSELF;
	self.itemStateObserver = [CObserver newObserverWithKeyPath:@"state" action:^(CItem *item, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself armSyncToStateWithOldState:(CItemState)[oldValue unsignedIntValue] oldEditing:item.editing];
	} initial:^(CItem *item, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself armSyncToStateWithOldState:(CItemState)[oldValue unsignedIntValue] oldEditing:item.editing];
	}];
	
	self.itemEditingObserver = [CObserver newObserverWithKeyPath:@"editing" action:^(CItem *item, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself armSyncToStateWithOldState:item.state oldEditing:[oldValue boolValue]];
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
		image = [UIImage newImageWithShapeImage:image tintColor:tintColor shadowColor:[UIColor clearColor] shadowOffset:CGSizeMake(0.0, 0.0) shadowBlur:0];
//		image = [UIImage newImageWithShapeImage:image tintColor:tintColor shadowColor:[UIColor colorWithWhite:0.0 alpha:0.8] shadowOffset:CGSizeMake(0.0, -1.0) shadowBlur:0];
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

		self.contentView.frame = self.bounds;
		self.contentView.alpha = 0.0;
        BSELF;
		[UIView animateWithDuration:0.3 animations:^{
			bself.contentView.alpha = 1.0;
			bself.lastContentView.alpha = 0.0;
		}];
	}
}

- (UIView *)contentViewForState:(CItemState)state {
    UIView *resultView = nil;
    switch(state) {
        case CItemStateNeedsValidation:
            resultView = self.needsValidationView;
            break;
        case CItemStateValidating:
            resultView = self.validatingView;
            break;
        case CItemStateValid:
            if(self.item.fresh) {
                resultView = self.newView;
            } else {
                if(self.item.editing) {
                    resultView = self.validView;
                } else {
                    resultView = self.newView;
                }
            }
            break;
        case CItemStateInvalid:
            resultView = self.item.fresh ? self.newView : self.invalidView;
            break;
    }
    return resultView;
}

- (void)syncToState
{
    BSELF;
    [NSThread performBlockOnMainThread:^{
        [NSObject cancelPreviousPerformRequestsWithTarget:bself selector:@selector(syncToState) object:nil];
        bself.contentView = [bself contentViewForState:self.item.state];
    }];
}

- (void)armSyncToStateWithOldState:(CItemState)oldState oldEditing:(BOOL)oldEditing
{
    CItemState newState = self.item.state;
    BOOL newEditing = self.item.editing;
    if(oldState != newState || oldEditing != newEditing) {
        if(oldState != CItemStateValid && newState != CItemStateValid) {
            self.contentView = self.newView;
        }
        BSELF;
        [NSThread performBlockOnMainThread:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:bself selector:@selector(syncToState) object:nil];
            NSTimeInterval duration;
            if(newState == CItemStateValid) {
                duration = 0.2;
            } else {
                duration = 2.5;
            }
            //CLogDebug(nil, @"%@ oldState:%d newState:%d duration:%f", bself, oldState, newState, duration);
            [bself performSelector:@selector(syncToState) withObject:nil afterDelay:duration];
        }];
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(20, 20);
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return self.intrinsicContentSize;
}

@end
