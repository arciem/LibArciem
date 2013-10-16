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
#include <cmath>
#include <algorithm>

@interface CMiniPickerViewCell ()

@property (nonatomic) NSMutableArray* columnLabels;
@property (nonatomic) CObserver* modelObserver;

@end

@implementation CMiniPickerViewCell

@synthesize model = _model;
@synthesize onDarkBackground = _onDarkBackground;

- (UILabel*)createLabel
{
    UILabel* label = [UILabel new];
    label.numberOfLines = 0;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
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
    self.font = [UIFont boldSystemFontOfSize:14.0];

    BSELF;
    self.modelObserver = [CObserver observerWithKeyPath:@"model" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself syncToModel];
	}];
    
    self.columnLabels = [NSMutableArray new];
    
    self.userInteractionEnabled = NO;
//    self.debugColor = [UIColor redColor];
    self.margins = UIEdgeInsetsMake(5, 10, 5, 10);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat totalWidth = self.width - self.margins.left - self.margins.right;

    __block CGFloat columnX = self.margins.left;
    __block CGFloat remainingWidth = totalWidth;
    [self.columnLabels enumerateObjectsUsingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
        CGFloat columnWidth;
        if(idx == self.columnLabels.count - 1) {
            columnWidth = remainingWidth;
        } else {
            columnWidth = [self.delegate miniPickerViewCell:self widthForColumnIndex:idx];
            if(columnWidth == 0.0) {
                CGSize size = [label.text sizeWithFont:label.font forWidth:remainingWidth lineBreakMode:label.lineBreakMode];
                columnWidth = size.width;
            } else if(columnWidth > remainingWidth) {
                columnWidth = remainingWidth;
            }
        }
        CFrame* cframe = label.cframe;
        cframe.left = columnX;
        cframe.top = self.margins.top;
        cframe.width = columnWidth;
        [cframe sizeToFit];
        cframe.width = columnWidth;
        columnX += columnWidth;
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
        NSString* title = self.model.title;
        CMiniPickerViewCellColumn* column = [[CMiniPickerViewCellColumn alloc] initWithText:title lines:0 alignment:NSTextAlignmentLeft];
        columns = @[column];
    }
    for(id<CMiniPickerViewCellColumn> column in columns) {
        UILabel* label = [self createLabel];
        label.font = self.font;
        label.text = column.text;
        label.numberOfLines = column.lines;
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

@property (strong, readwrite, nonatomic) NSString* text;
@property (readwrite, nonatomic) NSUInteger lines;
@property (readwrite, nonatomic) NSTextAlignment alignment;

@end

@implementation CMiniPickerViewCellColumn

- (id)initWithText:(NSString*)text lines:(NSUInteger)lines alignment:(NSTextAlignment)alignment
{
    if(self = [super init]) {
        self.text = text;
        self.lines = lines;
        self.alignment = alignment;
    }
    
    return self;
}

@end