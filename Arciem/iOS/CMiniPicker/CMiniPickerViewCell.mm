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

#import "CMiniPickerViewCell.h"
#import "CObserver.h"
#import "UIViewUtils.h"
#import "CGUtils.h"
#import "DeviceUtils.h"
#import "ObjectUtils.h"
#import "UILabelUtils.h"
#include <cmath>
#include <algorithm>

@interface CMiniPickerViewCell ()

@property (nonatomic) NSMutableArray* columnLabels;
@property (nonatomic) CObserver* modelObserver;

@end

@implementation CMiniPickerViewCell

@synthesize model = _model;
@synthesize onDarkBackground = _onDarkBackground;

- (UILabel*)newLabel
{
    UILabel* label = [UILabel new];
    label.numberOfLines = 0;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
#if 0
#warning DEBUG ONLY
    label.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
#endif
    if(self.onDarkBackground) {
        label.textColor = [UIColor whiteColor];
        if(!IsOSVersionAtLeast7()) {
            label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.6];
            label.shadowOffset = CGSizeMake(0, -1);
        }
    } else {
        label.textColor = [UIColor blackColor];
        if(!IsOSVersionAtLeast7()) {
            label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.6];
            label.shadowOffset = CGSizeMake(0, 1);
        }
    }
    return label;
}

- (void)setup
{
    [super setup];

    self.layoutView = YES;

    BSELF;
    self.modelObserver = [CObserver newObserverWithKeyPath:@"model" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself syncToModel];
	}];
    
    self.columnLabels = [NSMutableArray new];
    
    self.userInteractionEnabled = NO;
#if 0
#warning DEBUG ONLY
    self.debugColor = [UIColor redColor];
#endif
    self.margins = UIEdgeInsetsMake(5, 10, 5, 10);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat usableWidth = self.width - self.margins.left - self.margins.right;
    CGFloat maxHeight = [self.delegate maxHeightForMiniPickerViewCell:self];

    __block CGFloat columnRight = self.width - self.margins.right;
    __block CGFloat remainingWidth = usableWidth;
    BSELF;
    [self.columnLabels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
        CGFloat columnWidth;
        if(idx == 0) {
            columnWidth = remainingWidth;
        } else {
            const CGFloat kGutter = 20;
            columnWidth = [bself.delegate miniPickerViewCell:bself widthForColumnIndex:idx];
            if(columnWidth == 0.0) {
                CGRect rect = [label.attributedText boundingRectWithSize:CGSizeMake(remainingWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                CGSize size = CGSizeMake(std::ceilf(rect.size.width), std::ceilf(rect.size.height));
                columnWidth = size.width + kGutter;
            } else {
                columnWidth += kGutter;
            }
            
            if(columnWidth > remainingWidth) {
                columnWidth = remainingWidth;
            }
        }
        
        {
            CFrame* cframe = label.cframe;
            cframe.right = columnRight;
            cframe.top = bself.margins.top;
            cframe.width = columnWidth;
            cframe.height = 5000;
            [cframe sizeToFit];
            cframe.width = columnWidth;
        }
        if(maxHeight > 0.0 && label.height > maxHeight) {
            label.cframe.height = maxHeight;
            label.font = bself.font;
            [label adjustFontSizeToFit:bself.font.pointSize];
        }
        
        columnRight -= columnWidth;
        remainingWidth -= columnWidth;
    }];
}

- (void)syncToModel
{
    for(UILabel* label in self.columnLabels) {
        [label removeFromSuperview];
    }
    [self.columnLabels removeAllObjects];
    
    NSArray* columns = self.model.dict[@"columns"];
    if(columns == nil) {
        NSAttributedString* title = [[NSAttributedString alloc] initWithString:self.model.title];
        CMiniPickerViewCellColumn* column = [[CMiniPickerViewCellColumn alloc] initWithText:title lines:0 alignment:NSTextAlignmentLeft];
        columns = @[column];
    }
    for(id<CMiniPickerViewCellColumn> column in columns) {
        UILabel* label = [self newLabel];
        NSAttributedString *string = column.text;
        if(self.font != nil) {
            NSMutableAttributedString *mstring = [string mutableCopy];
#if 0
#warning DEBUG ONLY
            [mstring appendAttributedString:mstring];
#endif
            [mstring addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, mstring.length)];
            string = [mstring copy];
        }
        label.attributedText = string;
//        label.numberOfLines = column.lines;
        label.textAlignment = column.alignment;
        [self addSubview:label];
        [self.columnLabels addObject:label];
    }
    [self setNeedsLayout];
}

- (BOOL)onDarkBackground
{
    return _onDarkBackground;
}

- (void)setOnDarkBackground:(BOOL)onDarkBackground
{
    _onDarkBackground = onDarkBackground;
    [self syncToModel];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    __block CGFloat maxLabelHeight = 0.0;
    [self.columnLabels enumerateObjectsUsingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
        CGFloat labelHeight = label.height;
        maxLabelHeight = std::max(maxLabelHeight, labelHeight);
    }];
    CGFloat height = self.margins.top + self.margins.bottom + maxLabelHeight;
    height = RoundUpToEvenValue(height);
    
    return CGSizeMake(size.width, height);
}

@end

@interface CMiniPickerViewCellColumn ()

@property (strong, readwrite, nonatomic) NSAttributedString* text;
@property (readwrite, nonatomic) NSUInteger lines;
@property (readwrite, nonatomic) NSTextAlignment alignment;

@end

@implementation CMiniPickerViewCellColumn

- (instancetype)initWithText:(NSAttributedString*)text lines:(NSUInteger)lines alignment:(NSTextAlignment)alignment
{
    if(self = [super init]) {
        self.text = text;
        self.lines = lines;
        self.alignment = alignment;
    }
    
    return self;
}

@end