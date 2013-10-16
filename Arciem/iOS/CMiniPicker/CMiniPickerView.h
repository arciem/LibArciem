/*******************************************************************************
 
 Copyright 2013 Arciem LLC
 
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

#import "CView.h"
#import "CMultiChoiceItem.h"
#import "CMiniPickerFrameView.h"
#import "CMiniPickerViewCell.h"
#import "CMiniPickerBackgroundView.h"
#import "CMiniPickerOverlayView.h"

@protocol CMiniPickerViewDelegate;

@interface CMiniPickerView : CView

@property (nonatomic) CMultiChoiceItem* model;
@property (nonatomic) UIFont* font;
@property (weak, nonatomic) id<CMiniPickerViewDelegate> delegate;

@end

@protocol CMiniPickerViewDelegate <NSObject>

@required

- (CGFloat)miniPickerView:(CMiniPickerView*)view widthForColumnIndex:(NSUInteger)index;

@end