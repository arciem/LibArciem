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

#import <UIKit/UIKit.h>

typedef enum {
	kViewKeyboardAdjustmentTypeNone = 0,
	kViewKeyboardAdjustmentTypeShrink
} CViewKeyboardAdjustmentType;

@protocol CViewLayoutDelegate;

@interface CView : UIView<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIColor* debugColor;
@property (nonatomic) CViewKeyboardAdjustmentType keyboardAdjustmentType;
@property (nonatomic) BOOL tapResignsFirstResponder;
@property (assign, nonatomic) id<CViewLayoutDelegate> layoutDelegate;

- (void)setup;

@end

@protocol CViewLayoutDelegate<NSObject>

@optional
- (void)viewLayoutSubviews:(UIView*)view;

@end
