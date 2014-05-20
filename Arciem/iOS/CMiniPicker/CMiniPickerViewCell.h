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
#import "CItem.h"

@protocol CMiniPickerViewCellDelegate;

@interface CMiniPickerViewCell : CView

@property (nonatomic) UIEdgeInsets margins;
@property (nonatomic) UIFont* font;
@property (nonatomic) CItem* model;
@property (nonatomic) BOOL onDarkBackground;
@property (weak, nonatomic) id<CMiniPickerViewCellDelegate> delegate;
@property (nonatomic) UIView *debugView;

@end

@protocol CMiniPickerViewCellDelegate <NSObject>

@required

- (CGFloat)miniPickerViewCell:(CMiniPickerViewCell*)cell widthForColumnIndex:(NSUInteger)index;
- (CGFloat)maxHeightForMiniPickerViewCell:(CMiniPickerViewCell *)cell;

@end

@protocol CMiniPickerViewCellColumn <NSObject>

@required

@property (readonly, nonatomic) NSAttributedString* text;
@property (readonly, nonatomic) NSUInteger lines;
@property (readonly, nonatomic) NSTextAlignment alignment;

@end

@interface CMiniPickerViewCellColumn : NSObject <CMiniPickerViewCellColumn>

- (instancetype)initWithText:(NSAttributedString*)text lines:(NSUInteger)lines alignment:(NSTextAlignment)alignment;

@property (readonly, nonatomic) NSAttributedString* text;
@property (readonly, nonatomic) NSUInteger lines;
@property (readonly, nonatomic) NSTextAlignment alignment;

@end