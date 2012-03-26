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

static NSString* const sClassTag = @"C_ROW_ITEM_TABLE_VIEW_CELL";

@interface CRowItemTableViewCell ()

@property (strong, readwrite, nonatomic) NSMutableArray* mutableValidationViews;
@property (strong, nonatomic) CTapToDismissKeyboardManager* tapDismiss1;
@property (strong, nonatomic) CTapToDismissKeyboardManager* tapDismiss2;
@property (strong, nonatomic) CObserver* rowItemObserver;
@property (strong, nonatomic) NSMutableArray* modelValueObservers;

@end

@implementation CRowItemTableViewCell

@synthesize rowItem = rowItem_;
@synthesize mutableValidationViews = mutableValidationViews_;
@synthesize activeItem = activeItem_;
@synthesize tapDismiss1 = tapDismiss1_;
@synthesize tapDismiss2 = tapDismiss2_;
@synthesize delegate = delegate_;
@synthesize rowItemObserver = rowItemObserver_;
@synthesize modelValueObservers = modelValueObservers_;
@dynamic validationViewsNeeded;

+ (void)initialize
{
//	CLogSetTagActive(sClassTag, YES);
}

- (void)setup
{
	[super setup];

	self.textLabel.backgroundColor = [UIColor clearColor];

//	[self addObserver:self forKeyPath:@"rowItem" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
	__weak CRowItemTableViewCell* self__ = self;
	self.rowItemObserver = [CObserver observerWithKeyPath:@"rowItem" ofObject:self action:^(CTableRowItem* newRowItem, CTableRowItem* oldRowItem, NSKeyValueChange kind, NSIndexSet *indexes) {
		[self__ rowItemDidChangeFrom:oldRowItem to:newRowItem];
	}];

	CLogTrace(sClassTag, @"%@ setup", self);
}

- (void)dealloc
{
	CLogTrace(sClassTag, @"%@ dealloc", self);
	self.rowItemObserver = nil;
	self.rowItem = nil;
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
		self.mutableValidationViews = [NSMutableArray array];
	}
	
	while(self.mutableValidationViews.count <= index) {
		CFieldValidationView* view = [[CFieldValidationView alloc] initWithFrame:CGRectZero];
		//		view.backgroundColor = [UIColor redColor];
		view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.mutableValidationViews addObject:view];
		[self.contentView addSubview:view];
		[self setNeedsLayout];
	}
	
	return [self.mutableValidationViews objectAtIndex:index];
}

- (CFieldValidationView*)validationView
{
	return [self validationViewAtIndex:0];
}

- (void)setValidationView:(CFieldValidationView *)validationView atIndex:(NSUInteger)index
{
	CFieldValidationView* oldValidationView = [self validationViewAtIndex:index];
	if(validationView != oldValidationView) {
		[oldValidationView removeFromSuperview];
		[self.mutableValidationViews replaceObjectAtIndex:index withObject:validationView];
		[self.contentView addSubview:validationView];
		[self setNeedsLayout];
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

- (void)setNumberOfValidationViewsTo:(NSUInteger)count
{
	while(self.mutableValidationViews.count > count) {
		CFieldValidationView* view = self.mutableValidationViews.lastObject;
		[view removeFromSuperview];
		[self.mutableValidationViews removeLastObject];
	}
	if(count > 0) {
		[self validationViewAtIndex:count - 1];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	for(CFieldValidationView* validationView in self.validationViews) {
		[validationView sizeToFit];
		validationView.right = self.contentView.boundsRight - 10;
		validationView.centerY = self.boundsCenterY;
		validationView.frame = CGRectIntegral(self.validationView.frame);
	}
}

+ (BOOL)automaticallyNotifiesObserversOfRowItem
{
	return NO;
}

- (CTableRowItem*)rowItem
{
	return rowItem_;
}

- (void)setRowItem:(CTableRowItem *)rowItem
{
	if(rowItem_ != rowItem) {
		[self willChangeValueForKey:@"rowItem"];
		rowItem_ = rowItem;
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
		CItem* model = [self.models objectAtIndex:idx];
		view.item = model;
	}];
}

// May be overridden by subclasses
- (void)syncToRowItem
{
	self.textLabel.text = self.rowItem.title;

	CTableItem* tableItem = (CTableItem*)self.rowItem.superitem.superitem;
	[self applyAttributes:tableItem.textLabel toLabel:self.textLabel];
	[self applyAttributes:self.rowItem.textLabel toLabel:self.textLabel];

	self.textLabel.alpha = self.rowItem.isDisabled ? 0.4 : 1.0;
	
	if(self.rowItem.isUnselectable) {
		self.tapDismiss1 = [[CTapToDismissKeyboardManager alloc] initWithView:self];
		self.tapDismiss2 = [[CTapToDismissKeyboardManager alloc] initWithView:self.contentView];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.tapDismiss1 = nil;
		self.tapDismiss2 = nil;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	[self syncValidationViews];

	[self setNeedsLayout];
}

- (void)applyAttributes:(NSDictionary*)attributes toLabel:(UILabel*)label
{
	static NSDictionary* switchDict = nil;
	if(switchDict == nil) {
		switchDict = [NSDictionary dictionaryWithKeysAndObjects:
					  @"adjustsFontSizeToFitWidth",
					  ^(UILabel* lbl, id value) {
						  lbl.adjustsFontSizeToFitWidth = [value boolValue];
					  },
					  @"minimumFontSize",
					  ^(UILabel* lbl, id value) {
						  lbl.minimumFontSize = [value floatValue]; 
					  },
					  @"fontSize",
					  ^(UILabel* lbl, id value) {
						  lbl.font = [UIFont fontWithName:lbl.font.fontName size:[value floatValue]];
					  },
					  @"textColor",
					  ^(UILabel* lbl, id value) {
						  lbl.textColor = [UIColor colorWithString:(NSString*)value];
					  },
					  nil];
	}
	for(NSString* key in attributes) {
		void (^caseBlock)(UILabel*, id) = [switchDict objectForKey:key];
		NSAssert1(caseBlock != NULL, @"No case found for key '%@'", key);
		id value = [attributes objectForKey:key];
		caseBlock(label, value);
	}
}

- (void)rowItemDidChangeFrom:(CTableRowItem*)oldRowItem to:(CTableRowItem*)newRowItem
{
	if(oldRowItem != newRowItem) {
		[self syncToRowItem];
		self.modelValueObservers = [NSMutableArray array];
		__weak CRowItemTableViewCell* self__ = self;
		for(CItem* newModel in newRowItem.models) {
			CObserver* modelValueObserver = [CObserver observerWithKeyPath:@"value" ofObject:newModel action:^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
				[self__ model:newModel valueDidChangeFrom:oldValue to:newValue];
			} initial:^(id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
				[self__ model:newModel valueDidChangeFrom:oldValue to:newValue];
			}];
			[self.modelValueObservers addObject:modelValueObserver];
		}
	}
}

- (void)model:(CItem*)model valueDidChangeFrom:(id)oldValue to:(id)newValue
{
//	CLogDebug(nil, @"model:%@ valueDidChangeFrom:%@ to:%@", model, oldValue, newValue);
}

#pragma mark - @propery activeItem

- (CItem*)activeItem
{
	return activeItem_;
}

- (void)setActiveItem:(CItem *)activeItem
{
	activeItem_ = activeItem;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ItemDidBecomeActive" object:activeItem_];
}

@end
