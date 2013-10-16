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

#import "CMiniPickerView.h"
#import "CMiniPickerViewCell.h"
#import "CMiniPickerFrameView.h"
#import "CMiniPickerOverlayView.h"
#import "CMiniPickerBackgroundView.h"
#import "CSystemSound.h"
#import "CObserver.h"
#import "UIViewUtils.h"
#import "DateTimeUtils.h"
#import "ObjectUtils.h"
#import "math_utils.hpp"

static __strong CSystemSound* sDetentSound = nil;

@interface CMiniPickerView () <UIScrollViewDelegate, CMiniPickerViewCellDelegate>

@property (nonatomic) CMiniPickerBackgroundView* backgroundView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) CView* scrollContentView;
@property (nonatomic) NSMutableArray *contentViews;
@property (nonatomic) CMiniPickerFrameView *frameView;
@property (nonatomic) CMiniPickerOverlayView *overlayView;
@property (nonatomic) NSUInteger lastSelectedIndex;
@property (nonatomic) CGFloat lastSelectedIndexOffsetFraction;
@property (nonatomic) CObserver* modelObserver;
@property (nonatomic) NSDate* suppressSoundUntilDate;
@property (nonatomic) NSMutableArray* columnWidths;

@end

@implementation CMiniPickerView

+ (void)initialize
{
    NSURL *detentSoundURL = [[NSBundle mainBundle] URLForResource:@"DetentClick" withExtension:@"caf"];
    sDetentSound = [[CSystemSound alloc] initWithFileURL:detentSoundURL];
}

- (void)setup
{
    [super setup];

    self.font = [UIFont boldSystemFontOfSize:14.0];

    self.columnWidths = [NSMutableArray new];

    BSELF;
    self.modelObserver = [CObserver observerWithKeyPath:@"model" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself syncToModel];
	}];

//    self.debugColor = [UIColor blueColor];
//    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
//    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
//  self.scrollView.backgroundColor = [[UIColor orangeColor] colorWithAlpha:0.5];
    
    self.scrollContentView = [CView new];
    self.scrollContentView.opaque = NO;
    self.scrollContentView.backgroundColor = [UIColor clearColor];
//    self.scrollContentView.debugColor = [UIColor redColor];
    [self.scrollView addSubview:self.scrollContentView];
    
    self.contentViews = [NSMutableArray new];

    self.frameView = [[CMiniPickerFrameView alloc] initWithFrame:self.bounds];

    self.backgroundView = [[CMiniPickerBackgroundView alloc] initWithFrame:self.bounds];
    self.backgroundView.margins = self.frameView.margins;

    self.overlayView = [[CMiniPickerOverlayView alloc] initWithFrame:self.bounds];
    self.overlayView.margins = self.frameView.margins;
    
    self.lastSelectedIndex = NSNotFound;
    self.lastSelectedIndexOffsetFraction = 0.0;

    [self addSubview:self.backgroundView];
    [self addSubview:self.scrollView];
    [self addSubview:self.overlayView];
    [self addSubview:self.frameView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.columnWidths = [NSMutableArray new];
    
    CFrame* scrollContentViewFrame = self.scrollContentView.cframe;
    self.scrollView.frame = UIEdgeInsetsInsetRect(self.bounds, self.frameView.margins);
    scrollContentViewFrame.frame = self.scrollView.bounds;
    
    UIView* lastView = nil;
    for(NSUInteger index = 0; index < self.contentViews.count; index++) {
        CMiniPickerViewCell *cellView = self.contentViews[index];
        // have to directly set width before sizeToFit will work
        cellView.cframe.width = scrollContentViewFrame.width;
        
        CFrame* cellFrame = cellView.cframe;
        [cellFrame sizeToFit];
        
        cellFrame.left = 0;
        if(index == 0) {
            cellFrame.centerY = self.scrollView.height / 2;
        } else {
            cellFrame.top = lastView.bottom;
        }
        
        scrollContentViewFrame.height += (cellFrame.height) / 2;
        if(index < self.contentViews.count - 1) {
            scrollContentViewFrame.height += (lastView.height) / 2;
        }
        
        lastView = cellView;
    }
    
    self.scrollView.contentSize = scrollContentViewFrame.size;
    
    [self syncToScroll];
}

- (void)syncToScroll
{
    CGFloat minOffset = 0.0;
    CGFloat maxOffset = self.scrollView.contentSize.height - self.scrollView.height;
    CGFloat offset = self.scrollView.contentOffset.y;
    CGFloat clampedOffset = arciem::clamp(offset, minOffset, maxOffset);
    
    CGFloat viewTopOffset = 0.0, viewBottomOffset = 0.0;
    NSUInteger selectedIndex = NSNotFound;
    CGFloat selectedIndexOffsetFraction = 0.0;
    for(NSUInteger index = 0; index < self.contentViews.count; index++) {
        UIView *view = self.contentViews[index];
        if(index == 0) {
            viewTopOffset = -view.height / 2.0;
        }
        viewBottomOffset = viewTopOffset + view.height;
        if(clampedOffset >= viewTopOffset && clampedOffset < viewBottomOffset) {
            selectedIndex = index;
            selectedIndexOffsetFraction = arciem::map(clampedOffset, viewTopOffset, viewBottomOffset, -0.5f, 0.5f);
            CGFloat overlayHeight = view.height;
            if(selectedIndexOffsetFraction < 0.0 && index > 0) {
                UIView* previousView = self.contentViews[index - 1];
                overlayHeight = arciem::denormalize(-selectedIndexOffsetFraction, overlayHeight, previousView.height);
            } else if(selectedIndexOffsetFraction > 0.0 && index < (self.contentViews.count - 1)) {
                UIView* nextView = self.contentViews[index + 1];
                overlayHeight = arciem::denormalize(selectedIndexOffsetFraction, overlayHeight, nextView.height);
            }
            
            overlayHeight -= 4.0;

            CFrame* cframe = [CFrame new];
            cframe.left = self.scrollView.left;
            cframe.width = self.scrollView.width;
            cframe.height = overlayHeight;
            cframe.centerY = self.scrollView.centerY;
            self.overlayView.overlayRect = cframe.frame;
            self.backgroundView.underlayRect = cframe.frame;
            break;
        }
        
        viewTopOffset = viewBottomOffset;
    }
    
    if(selectedIndex != self.lastSelectedIndex) {
        [self.model selectSubitem:self.model.subitems[selectedIndex]];
    }

    if(self.lastSelectedIndex != NSNotFound) {
        NSInteger indexOffset = (NSInteger)selectedIndex - (NSInteger)self.lastSelectedIndex;
        if(indexOffset == 0) {
            if(selectedIndexOffsetFraction >= 0.0 && self.lastSelectedIndexOffsetFraction < 0.0) {
                [self playDetentSound];
            } else if(selectedIndexOffsetFraction <= 0.0 && self.lastSelectedIndexOffsetFraction > 0.0 ) {
                [self playDetentSound];
            }
        } else if(std::abs((float)indexOffset) >= 2) {
            [self playDetentSound];
        }
    }
    self.lastSelectedIndex = selectedIndex;
    self.lastSelectedIndexOffsetFraction = selectedIndexOffsetFraction;

//    CLogDebug(nil, @"scrollViewDidScroll: %@, maxOffset:%f clampedOffset:%f selectedIndex:%d selectedIndexOffsetFraction:%f", self.scrollView, maxOffset, clampedOffset, selectedIndex, selectedIndexOffsetFraction);
//    CLogDebug(nil, @"scrollViewDidScroll contentOffset:%@", NSStringFromCGPoint(self.scrollView.contentOffset));
}

- (void)playDetentSound
{
    if(self.suppressSoundUntilDate == nil) {
        [sDetentSound play];
    } else {
        NSDate* currentDate = [NSDate date];
        if([currentDate isLaterThanDate:self.suppressSoundUntilDate]) {
            [sDetentSound play];
        }
    }
}

- (void)syncToModel
{
    self.suppressSoundUntilDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    [self.scrollView setContentOffset:CGPointZero];
    for(UIView* view in self.contentViews) {
        [view removeFromSuperview];
    }
    [self.contentViews removeAllObjects];
    
    NSAssert1([self.model isKindOfClass:[CMultiChoiceItem class]], @"Model is not CMultiChoiceItem: %@", self.model);

    BOOL singleChoice = self.model.subitems.count <= 1;

    for(CBooleanItem* choiceItem in self.model.subitems) {
        NSAssert1([choiceItem isKindOfClass:[CBooleanItem class]], @"Subitem is not CBooleanItem: %@", choiceItem);
        CMiniPickerViewCell* cellView = [CMiniPickerViewCell new];
        UIEdgeInsets cellViewMargins = cellView.margins;
        cellViewMargins.left = cellViewMargins.left + self.frameView.margins.left;
        cellViewMargins.right = cellViewMargins.right + self.frameView.margins.right;
        cellView.margins = cellViewMargins;
        cellView.model = choiceItem;
        cellView.font = self.font;
        cellView.onDarkBackground = NO; // singleChoice ? YES : NO;
        cellView.delegate = self;
        [self.contentViews addObject:cellView];
        [self.scrollContentView addSubview:cellView];
    }
    
    if(singleChoice) {
        self.frameView.hidden = YES;
        self.backgroundView.hidden = YES;
        self.overlayView.hidden = YES;
        self.scrollView.scrollEnabled = NO;
    } else {
        self.frameView.hidden = NO;
        self.backgroundView.hidden = NO;
        self.overlayView.hidden = NO;
        self.scrollView.scrollEnabled = YES;
    }

    [self setNeedsLayout];
}

#pragma mark - CMiniPickerViewCellDelegate

- (CGFloat)miniPickerViewCell:(CMiniPickerViewCell*)cell widthForColumnIndex:(NSUInteger)index
{
    CGFloat width;
    while(self.columnWidths.count <= index) {
        [self.columnWidths addObject:[NSNull null]];
    }
    
    id obj = self.columnWidths[index];
    if(!IsNull(obj)) {
        width = [obj floatValue];
    } else {
        width = [self.delegate miniPickerView:self widthForColumnIndex:index];
        self.columnWidths[index] = @(width);
    }
    
    return width;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self syncToScroll];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat minOffset = 0.0;
    CGFloat maxOffset = self.scrollView.contentSize.height - self.scrollView.height;
    CGFloat targetOffset = targetContentOffset->y;
    CGFloat clampedTargetOffset = arciem::clamp(targetOffset, minOffset, maxOffset);
    
    CGFloat viewTopOffset = 0.0, viewBottomOffset = 0.0;
//    NSUInteger selectedIndex = NSNotFound;
    for(NSUInteger index = 0; index < self.contentViews.count; index++) {
        UIView *view = self.contentViews[index];
        if(index == 0) {
            viewTopOffset = -view.height / 2.0;
        }
        viewBottomOffset = viewTopOffset + view.height;
        if(clampedTargetOffset >= viewTopOffset && clampedTargetOffset < viewBottomOffset) {
//            selectedIndex = index;
            targetContentOffset->y = arciem::denormalize(0.5f, viewTopOffset, viewBottomOffset);
            break;
        }
        
        viewTopOffset = viewBottomOffset;
    }
    
//    CLogDebug(nil, @"scrollViewWillEndDragging targetContentOffset:%@", NSStringFromCGPoint(*targetContentOffset));
}

@end
