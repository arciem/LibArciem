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

#import "CDebugAnnotationView.h"
#import "CDebugAnnotation.h"
#import "ObjectUtils.h"

static void* const kAnnotationChangedContext = (void*)0x1;
static void* const kAnnotationCoordinateChangedContext = (void*)0x2;

@interface CDebugAnnotationView ()

@property (strong, nonatomic) UILabel* label;

@end

@implementation CDebugAnnotationView

@synthesize label = label_;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		self.label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.label.opaque = NO;
		self.label.backgroundColor = [UIColor clearColor];
		self.label.font = [UIFont boldSystemFontOfSize:10.0];
		self.label.textColor = [UIColor whiteColor];
		self.label.textAlignment = NSTextAlignmentRight;
		self.label.numberOfLines = 2;
		self.label.text = @"Line 1\nLine 2";
		[self.label sizeToFit];
		self.rightCalloutAccessoryView = self.label;
		
		[self addObserver:self forKeyPath:@"annotation" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:kAnnotationChangedContext];
	}
	
	return self;
}

- (void)dealloc
{
	self.annotation = nil;
	[self removeObserver:self forKeyPath:@"annotation"];
}

+ (CDebugAnnotationView*)debugAnnotationViewWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier
{
	return [[self alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(context == kAnnotationChangedContext) {
//		CLogDebug(nil, @"%@ annotation changed:%@", self, change);
		CDebugAnnotation* oldAnnotation = [change objectForKey:NSKeyValueChangeOldKey];
		CDebugAnnotation* newAnnotation = [change objectForKey:NSKeyValueChangeNewKey];
		if(oldAnnotation != newAnnotation) {
			if(!IsNull(oldAnnotation)) {
				[oldAnnotation removeObserver:self forKeyPath:@"coordinate" context:kAnnotationCoordinateChangedContext];
			}
			
			if(!IsNull(newAnnotation)) {
				[newAnnotation addObserver:self forKeyPath:@"coordinate" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:kAnnotationCoordinateChangedContext];
			}
		}
	} else if(context == kAnnotationCoordinateChangedContext) {
//		CLogDebug(nil, @"%@ annotation coordinate changed:%@", self, change);
		CDebugAnnotation* newAnnotation = [change objectForKey:NSKeyValueChangeNewKey];
		if(!IsNull(newAnnotation)) {
			self.label.text = [NSString stringWithFormat:@"lat %@\nlon %@", [NSNumber numberWithDouble:self.annotation.coordinate.latitude], [NSNumber numberWithDouble:self.annotation.coordinate.longitude]];
			[self.label sizeToFit];
		}
	}
}
@end
