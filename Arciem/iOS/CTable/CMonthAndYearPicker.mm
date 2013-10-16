/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CMonthAndYearPicker.h"
#import "UIViewUtils.h"
#import "ObjectUtils.h"
#import "UIColorUtils.h"
#import "DateTimeUtils.h"

@interface CMonthAndYearPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) UIPickerView* pickerView;
@property (nonatomic) UIImageView* backgroundView;
@property (readonly, nonatomic) NSLocale* locale;
@property (readonly, nonatomic) NSCalendar* calendar;
@property (readonly, nonatomic) NSDateFormatter* dateFormatter;
@property (readonly, nonatomic) NSInteger minimumYear;
@property (readonly, nonatomic) NSInteger maximumYear;
@property (readonly, nonatomic) NSDate* currentDate;
@property (readonly, nonatomic) NSInteger currentMonth;
@property (readonly, nonatomic) NSInteger currentYear;

@end

@implementation CMonthAndYearPicker

@synthesize pickerView = pickerView_;
@synthesize date = date_;
@synthesize locale = locale_;
@synthesize calendar = calendar_;
@synthesize dateFormatter = dateFormatter_;
@synthesize currentDate = currentDate_;

- (id)init
{
	if(self = [self initWithFrame:CGRectZero]) {
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:CGRectMake(0, 0, 320, 216)]) {
		self.date = [NSDate date];

        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];

		pickerView_ = [[UIPickerView alloc] initWithFrame:self.bounds];
		pickerView_.dataSource = self;
		pickerView_.delegate = self;
		pickerView_.showsSelectionIndicator = YES;
		[self addSubview:pickerView_];
	}
	
	return self;
}

- (NSLocale*)locale
{
	if(locale_ == nil) {
		locale_ = [NSLocale currentLocale];
	}
	
	return locale_;
}

- (NSCalendar*)calendar
{
	if(calendar_ == nil) {
		calendar_ = [NSCalendar currentCalendar];
		calendar_.locale = self.locale;
	}
	
	return calendar_;
}

- (NSDateFormatter*)dateFormatter
{
	if(dateFormatter_ == nil) {
		dateFormatter_ = [[NSDateFormatter alloc] init];
		dateFormatter_.locale = self.locale;
		dateFormatter_.calendar = self.calendar;
		NSString* format = [NSDateFormatter dateFormatFromTemplate:@"yMMMM" options:0 locale:self.locale];
		[dateFormatter_ setDateFormat:format];
	}
	
	return dateFormatter_;
}

- (NSDate*)currentDate
{
	if(currentDate_ == nil) {
		currentDate_ = [NSDate date];
	}
	
	return currentDate_;
}

- (NSInteger)currentMonth
{
	NSDateComponents* comps = [self.calendar components:NSMonthCalendarUnit fromDate:self.currentDate];
	return comps.month;
}

- (NSInteger)currentYear
{
	NSDateComponents* comps = [self.calendar components:NSYearCalendarUnit fromDate:self.currentDate];
	return comps.year;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGSize newSize = [self.pickerView sizeThatFits:size];
	newSize.width = self.superview.boundsWidth;
	return newSize;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CFrame* pickerFrame = self.pickerView.cframe;
	[pickerFrame sizeToFit];
	pickerFrame.centerX = self.boundsCenterX;
}

- (void)didMoveToSuperview
{
	if(self.superview != nil) {
		[self sizeToFit];
		[self.pickerView reloadAllComponents];
		[self syncToDateAnimated:NO];
	}
}

- (void)syncToPicker
{
	NSInteger month = [self monthForMonthRow:[self.pickerView selectedRowInComponent:0]];
	NSInteger year = [self yearForYearRow:[self.pickerView selectedRowInComponent:1]];
	NSDate* date = [self dateForMonth:month year:year];
	if(self.minimumDate != nil && [date isEarlierThanDate:self.minimumDate]) {
		date = self.minimumDate;
		[self setDate:date animated:YES];
	} else if(self.maximumDate != nil && [date isLaterThanDate:self.maximumDate]) {
		date = self.maximumDate;
		[self setDate:date animated:YES];
	} else {
		self.date = date;
	}
}

- (void)syncToDateAnimated:(BOOL)animated
{
	NSDateComponents* comps = [self.calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.date];
	NSInteger monthRow = comps.month - 1;
	NSInteger yearRow = comps.year - self.minimumYear;
	[self.pickerView selectRow:monthRow inComponent:0 animated:animated];
	[self.pickerView selectRow:yearRow inComponent:1 animated:animated];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger result = 0;
	
	switch (component) {
		case 0:
			result = self.dateFormatter.standaloneMonthSymbols.count;
			break;
		case 1:
			result = self.maximumYear - self.minimumYear + 1;
			break;
		default:
			break;
	}
	
	return result;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString* result = nil;
	
	switch (component) {
		case 0:
			result = (self.dateFormatter.standaloneMonthSymbols)[row];
			break;
		case 1:
			result = [NSString stringWithFormat:@"%d", self.minimumYear + row];
			break;
		default:
			break;
	}
	
	return result;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 44.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat result = 0.0;
	
	switch (component) {
		case 0:
			result = 202.0;
			break;
		case 1:
			result = 78.0;
			break;
		default:
			break;
	}
	
	return result;
}

- (NSDate*)dateForMonth:(NSInteger)month year:(NSInteger)year
{
	NSDateComponents* comps = [[NSDateComponents alloc] init];
	comps.month = month;
	comps.year = year;
	return [self.calendar dateFromComponents:comps];
}

- (NSInteger)monthForMonthRow:(NSInteger)monthRow
{
	return monthRow + 1;
}

- (NSInteger)yearForYearRow:(NSInteger)yearRow
{
	return yearRow + self.minimumYear;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel* label = (UILabel*)view;
	
	if(label == nil) {
		label = [[UILabel alloc] init];
		label.font = [UIFont boldSystemFontOfSize:24.0];
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
//		label.backgroundColor = component == 0 ? [UIColor redColor] : [UIColor blueColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	}

	BOOL highlighted = NO;
	NSInteger month = 0;
	NSInteger year = 0;
	
	switch (component) {
		case 0: {
			month = [self monthForMonthRow:row];
			year = [self yearForYearRow:[pickerView selectedRowInComponent:1]];

			NSString* monthString = (self.dateFormatter.standaloneMonthSymbols)[row];
			
			label.text = [NSString stringWithFormat:@"%@ %02d", monthString, month];
			label.textAlignment = NSTextAlignmentRight;
			
			highlighted = month == self.currentMonth;
		} break;
		case 1: {
			month = [self monthForMonthRow:[pickerView selectedRowInComponent:0]];
			year = [self yearForYearRow:row];
					 
			label.text = [NSString stringWithFormat:@"%d", year];
			label.textAlignment = NSTextAlignmentCenter;
					 
			highlighted = year == self.currentYear;
		} break;
		default:
			break;
	}

	BOOL disabled = NO;

	NSDate* date = [self dateForMonth:month year:year];
	if(self.minimumDate != nil && [date isEarlierThanDate:self.minimumDate]) {
		disabled = YES;
	} else if(self.maximumDate != nil && [date isLaterThanDate:self.maximumDate]) {
		disabled = YES;
	}

	if(highlighted) {
		label.textColor = [UIColor systemHighlightBlue];
	} else {
		if(disabled) {
			label.textColor = [UIColor grayColor];
		} else {
			label.textColor = [UIColor blackColor];
		}
	}
	
	[label sizeToFit];
	label.cframe.width = [self pickerView:pickerView widthForComponent:component] - 20;
	
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//	CLogDebug(nil, @"%@ didSelectRow:%d inComponent:%d", pickerView, row, component);
	[self syncToPicker];
	[self.pickerView reloadAllComponents];
}

#pragma mark - @property minimumYear

- (NSInteger)minimumYear
{
	NSInteger result = 0;
	
	NSDate* date = self.minimumDate;
	
	if(date == nil) {
		date = [NSDate distantPast];
	}
	
	NSDateComponents* comps = [self.calendar components:NSYearCalendarUnit fromDate:date];
	result = comps.year;
	
	return result;
}

#pragma mark - @property maximumYear

- (NSInteger)maximumYear
{
	NSInteger result = 0;
	
	NSDate* date = self.maximumDate;
	
	if(date == nil) {
		date = [NSDate distantFuture];
	}
	
	NSDateComponents* comps = [self.calendar components:NSYearCalendarUnit fromDate:date];
	result = comps.year;
	
	return result;
}

#pragma mark - @property date

+ (BOOL)automaticallyNotifiesObserversOfDate
{
	return NO;
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
//	if(!Same(date_, date)) {
		[self willChangeValueForKey:@"date"];
		date_ = date;
		[self didChangeValueForKey:@"date"];
		[self syncToDateAnimated:animated];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
//	}
}

- (NSDate*)date
{
	return date_;
}

- (void)setDate:(NSDate *)date
{
	[self setDate:date animated:NO];
}

@end
