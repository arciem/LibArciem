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

#import "CRowItemTableViewCell.h"
#import "ObjectUtils.h"
#import "UIColorUtils.h"
#import "CTableItem.h"
#import "UIViewUtils.h"
#import "CTapToDismissKeyboardManager.h"
#import "CObserver.h"
#import "DeviceUtils.h"

static NSString* const sClassTag = @"C_ROW_ITEM_TABLE_VIEW_CELL";
static BOOL sTestingMode;

@interface CRowItemTableViewCell ()

@property (strong, readwrite, nonatomic) NSMutableArray* mutableValidationViews;
@property (nonatomic) NSMutableArray *mutableValidationViewConstraints;

@property (nonatomic) CObserver* rowItemObserver;
@property (nonatomic) NSMutableArray* modelValueObservers;
@property (nonatomic) CObserver* rowItemDisabledObserver;

@end

@implementation CRowItemTableViewCell

@synthesize rowItem = _rowItem;
@synthesize activeItem = _activeItem;

+ (void)initialize
{
//	CLogSetTagActive(sClassTag, YES);
}

- (void)setup
{
	[super setup];

	self.indentationWidth = IsPad() ? 30 : 10;

	BSELF;
	self.rowItemObserver = [CObserver observerWithKeyPath:@"rowItem" ofObject:self action:^(id object, CTableRowItem* newRowItem, CTableRowItem* oldRowItem, NSKeyValueChange kind, NSIndexSet *indexes) {
		[bself rowItemDidChangeFrom:oldRowItem to:newRowItem];
	}];

	CLogTrace(sClassTag, @"%@ setup", self);
}

- (void)dealloc
{
	CLogTrace(sClassTag, @"%@ dealloc", self);
	self.rowItem = nil;
	self.rowItemObserver = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];

	NSTimeInterval duration = animated ? 0.3 : 0.0;
	CGFloat alpha = editing ? 0.0 : 1.0;
	[UIView animateWithDuration:duration animations:^{
		for(CFieldValidationView* view in self.mutableValidationViews) {
			view.alpha = alpha;
		}
	}];
}

- (CFieldValidationView*)validationViewAtIndex:(NSUInteger)index
{
	if(self.mutableValidationViews == nil) {
		self.mutableValidationViews = [NSMutableArray new];
	}
	
	while(self.mutableValidationViews.count <= index) {
		CFieldValidationView* view = [[CFieldValidationView alloc] initWithFrame:CGRectZero];
#if 0
#warning DEBUG ONLY
		view.backgroundColor = [[UIColor blueColor] colorWithAlpha:0.2];
#endif
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		[self.mutableValidationViews addObject:view];
		[self.contentView addSubview:view];
		[self setNeedsUpdateConstraints];
	}
	
	return (self.mutableValidationViews)[index];
}

- (CLayoutConstraintsGroup *)validationViewConstraintsAtIndex:(NSUInteger)index {
	if(self.mutableValidationViewConstraints == nil) {
        self.mutableValidationViewConstraints = [NSMutableArray new];
	}
	
	while(self.mutableValidationViewConstraints.count <= index) {
        [self.mutableValidationViewConstraints addObject:[CLayoutConstraintsGroup groupWithOwner:self.contentView]];
	}
	
	return (self.mutableValidationViewConstraints)[index];
}

- (CFieldValidationView*)validationView
{
	return [self validationViewAtIndex:0];
}

- (CLayoutConstraintsGroup *)validationViewConstraints {
    return [self validationViewConstraintsAtIndex:0];
}

- (void)setValidationView:(CFieldValidationView *)validationView atIndex:(NSUInteger)index
{
	CFieldValidationView* oldValidationView = [self validationViewAtIndex:index];
	if(validationView != oldValidationView) {
        [[self validationViewConstraintsAtIndex:index] removeAllConstraints];
		[oldValidationView removeFromSuperview];
		(self.mutableValidationViews)[index] = validationView;
		[self.contentView addSubview:validationView];
		[self setNeedsUpdateConstraints];
	}
}

- (void)setValidationView:(CFieldValidationView *)validationView
{
	[self setValidationView:validationView atIndex:0];
}

- (NSArray*)validationViews
{
	return [self.mutableValidationViews copy];
}

- (NSArray *)validationViewsConstraints {
    return [self.mutableValidationViewConstraints copy];
}

- (void)setNumberOfValidationViewsTo:(NSUInteger)count
{
	while(self.mutableValidationViews.count > count) {
        CLayoutConstraintsGroup *constraints = self.mutableValidationViewConstraints.lastObject;
        [constraints removeAllConstraints];
        [self.mutableValidationViewConstraints removeLastObject];
		CFieldValidationView* view = self.mutableValidationViews.lastObject;
		[view removeFromSuperview];
		[self.mutableValidationViews removeLastObject];
	}
	if(count > 0) {
		[self validationViewAtIndex:count - 1];
	}
}

- (void)updateConstraints {
    [super updateConstraints];

    CLayoutConstraintsGroup *group = [self resetConstraintsGroupForKey:@"CRowItemTableViewCell_validationViews" owner:self.contentView];

    BSELF;
    [self.validationViews enumerateObjectsUsingBlock:^(CFieldValidationView* validationView, NSUInteger idx, BOOL *stop) {
        [group addConstraint:[validationView constrainCenterYEqualToCenterYOfItem:bself.contentView] withPriority:UILayoutPriorityDefaultLow];
    }];
}

+ (BOOL)automaticallyNotifiesObserversOfRowItem
{
	return NO;
}

- (CTableRowItem*)rowItem
{
	return _rowItem;
}

- (void)setRowItem:(CTableRowItem *)rowItem
{
	if(_rowItem != rowItem) {
		[self willChangeValueForKey:@"rowItem"];
		_rowItem = rowItem;
		[self didChangeValueForKey:@"rowItem"];
	}
}

// May be overridden by subclasses
- (NSUInteger)validationViewsNeeded
{
	return self.models.count;
}

- (NSArray*)models
{
	return self.rowItem.models;
}

// May be overridden by subclasses
- (void)syncValidationViews
{
	[self setNumberOfValidationViewsTo:self.validationViewsNeeded];
	[self.validationViews enumerateObjectsUsingBlock:^(CFieldValidationView* view, NSUInteger idx, BOOL *stop) {
		CItem* model = (self.models)[idx];
		view.item = model;
	}];
}

// May be overridden by subclasses
- (void)syncTitleLabelToRowItem {
	self.titleLabel.text = self.rowItem.title;
    
	CTableRowItem* rowItem = self.rowItem;
	self.indentationLevel = rowItem.indentationLevel;
    
	CTableItem* tableItem = (CTableItem*)rowItem.superitem.superitem;
	[self applyAttributes:tableItem.textLabelAttributes toLabel:self.titleLabel];
	[self applyAttributes:rowItem.textLabelAttributes toLabel:self.titleLabel];
    
	self.titleLabel.alpha = rowItem.disabled ? 0.5 : 1.0;
}

// May be overridden by subclasses
- (void)syncToRowItem
{
	CTableRowItem* rowItem = self.rowItem;
	
	if(!rowItem.rowSelectable) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
        if(IsOSVersionAtLeast7()) {
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else {
            self.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
	}
	
	[self syncValidationViews];

	[self setNeedsLayout];

//	CLogDebug(nil, @"%@ synced", rowItem);
}

- (void)applyAttributes:(NSDictionary*)attributes toLabel:(UILabel*)label
{
	static NSDictionary* switchDict = nil;
	if(switchDict == nil) {
		switchDict = @{
                 @"transparentBackground":
                     ^(UILabel* lbl, id value) {
                         if([value boolValue]) {
                             lbl.opaque = NO;
                             lbl.backgroundColor = [UIColor clearColor];
                         }
                     },
                 @"darkBackground":
                     ^(UILabel* lbl, id value) {
                         if([value boolValue]) {
                             lbl.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
                             lbl.highlightedTextColor = [UIColor blackColor];
                         }
                     },
                 @"adjustsFontSizeToFitWidth":
                     ^(UILabel* lbl, id value) {
                         lbl.adjustsFontSizeToFitWidth = [value boolValue];
                     },
                 @"minimumScaleFactor":
                     ^(UILabel* lbl, id value) {
                         lbl.minimumScaleFactor = [value floatValue];
                     },
                 @"minimumFontSize":
                     ^(UILabel* lbl, id value) {
                         NSAssert(NO, @"minimumFontSize is deprecated.");
                     },
                 @"fontSize":
                     ^(UILabel* lbl, id value) {
                         lbl.font = [UIFont fontWithName:lbl.font.fontName size:[value floatValue]];
                     },
                 @"textColor":
                     ^(UILabel* lbl, id value) {
                         lbl.textColor = [UIColor colorWithString:(NSString*)value];
                     },
                 @"bold":
                     ^(UILabel* lbl, id value) {
                         lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                     },
                 };
	}
	for(NSString* key in attributes) {
		void (^caseBlock)(UILabel*, id) = switchDict[key];
		NSAssert1(caseBlock != NULL, @"No case found for key '%@'", key);
		id value = attributes[key];
		caseBlock(label, value);
	}
}

- (void)rowItemDidChangeFrom:(CTableRowItem*)oldRowItem to:(CTableRowItem*)newRowItem
{
	if(oldRowItem != newRowItem) {
		[self syncToRowItem];
		self.modelValueObservers = [NSMutableArray array];
		BSELF;
        [newRowItem.models enumerateObjectsUsingBlock:^(CItem *newModel, NSUInteger idx, BOOL *stop) {
			CObserver* modelValueObserver = [CObserver observerWithKeyPath:@"value" ofObject:newModel action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
				[bself model:newModel valueDidChangeFrom:oldValue to:newValue];
			} initial:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
				[bself model:newModel valueDidChangeFrom:oldValue to:newValue];
			}];
			[bself.modelValueObservers addObject:modelValueObserver];
        }];
        self.rowItemDisabledObserver = [CObserver observerWithKeyPath:@"disabled" ofObject:newRowItem action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
            [bself syncToRowItem];
        }];
	}
}

- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue
{
//	CLogDebug(nil, @"model:%@ valueDidChangeFrom:%@ to:%@", model, oldValue, newValue);
}

+ (void)setTestingMode:(BOOL)testingMode {
    sTestingMode = testingMode;
}

- (BOOL)isTestingMode {
    return sTestingMode;
}

#pragma mark - @propery activeItem

- (CItem*)activeItem
{
	return _activeItem;
}

- (void)setActiveItem:(CItem *)activeItem
{
	_activeItem = activeItem;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ItemDidBecomeActive" object:_activeItem];
}

#pragma mark - @property fontSize

- (CGFloat)fontSize
{
	return IsPad() ? 20 : 14;
}

#pragma mark - @property font

- (UIFont*)font
{
	return [UIFont systemFontOfSize:self.fontSize];
}

#pragma mark - @property contentInset

- (UIEdgeInsets)contentInset {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    
    CGFloat margin;
	if(IsPad()) {
        margin = 70;
	} else {
		margin = self.editing ? 10 : 35;
	}

    inset.left += margin;
    inset.right += margin;
	
	CGFloat indentPoints = self.indentationLevel * self.indentationWidth;
	if(indentPoints > 0) {
		inset.left += indentPoints;
	}

    return inset;
}

#pragma mark - @property layoutFrame

- (CGRect)layoutFrame
{
	CGRect frame = CGRectZero;

	if(IsPad()) {
		frame.size = CGSizeMake(self.contentView.width - 140, 31);
	} else {
		CGFloat margins = self.editing ? 20 : 70;
		frame.size = CGSizeMake(self.contentView.width - margins, 31);
	}
	
	frame = CGRectIntegral([Geom alignRectMid:frame toPoint:[Geom rectMid:self.contentView.bounds]]);
	
	CGFloat indentPoints = self.indentationLevel * self.indentationWidth;
	if(indentPoints > 0) {
		frame.origin.x += indentPoints;
		frame.size.width -= indentPoints;
	}
	
	return frame;
}

@end
