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

#import "CFieldValidationView.h"

@interface CFieldValidationView ()

- (void)syncToState;

@end

@implementation CFieldValidationView

@synthesize field = field_;

- (void)setup
{
	[super setup];
	[self syncToState];
	self.userInteractionEnabled = NO;
}

- (void)dealloc
{
	self.field = nil;
}

- (CField*)field
{
	return field_;
}

- (void)setField:(CField *)field
{
	if(field_ != field) {
		if(field_ != nil) {
			[self removeObserver:field_ forKeyPath:@"state"];
		}
		field_ = field;
		if(field_ != nil) {
			[field_ addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:NULL];
		}
	}
}

- (void)syncToState
{
	switch(self.field.state) {
		case CFieldStateIndeterminate:
			self.debugColor = [UIColor grayColor];
			break;
		case CFieldStateOmitted:
			self.debugColor = [UIColor purpleColor];
			break;
		case CFieldStateValid:
			self.debugColor = [UIColor greenColor];
			break;
		case CFieldStateProcessing:
			self.debugColor = [UIColor blueColor];
			break;
		case CFieldStateInvalid:
			self.debugColor = [UIColor redColor];
			break;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self.field) {
		if([keyPath isEqualToString:@"state"]) {
			[self syncToState];
		}
	}
}

@end
