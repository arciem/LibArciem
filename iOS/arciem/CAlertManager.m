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

#import "CAlertManager.h"
#import "I18nUtils.h"
#import "InvocationUtils.h"

static CAlertManager* sAlertManager = nil;

const NSUInteger kCancelButtonIndex = 0;
const NSUInteger kOKButtonIndex = 1;

@interface CAlertManager ()

@property(nonatomic, retain) NSMutableArray* alerts;
@property(nonatomic, retain) NSMutableArray* completionBlocks;

@end

@implementation CAlertManager

@synthesize alerts = alerts_;
@synthesize completionBlocks = completionBlocks_;

- (id)init
{
	if((self = [super init])) {
		self.alerts = [NSMutableArray array];
		self.completionBlocks = [NSMutableArray array];
	}
	
	return self;
}

+ (CAlertManager*)sharedInstance
{
	if(sAlertManager == nil) {
		sAlertManager = [[CAlertManager alloc] init];
	}
	
	return sAlertManager;
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message buttonTitles:(NSArray*)buttonTitles completion:(void (^)(NSUInteger buttonIndex))completion
{
	@synchronized(self) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		if(buttonTitles == nil) {
			[alertView addButtonWithTitle:IString(@"Cancel")];
		} else {
			for(NSString* title in buttonTitles) {
				[alertView addButtonWithTitle:title];
			}
		}

		if(completion == nil) {
			completion = ^(NSUInteger idx) { };
		}

		[self.alerts addObject:alertView];
		[self.completionBlocks addObject:[completion copy]];
		
		[alertView show];
	}
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message completion:(void (^)(NSUInteger buttonIndex))completion
{
	[self showAlertWithTitle:title message:message buttonTitles:nil completion:completion];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
	[self showAlertWithTitle:title message:message completion:nil];
}

- (void)showConfirmAlertWithTitle:(NSString*)title message:(NSString*)message completion:(void (^)(NSUInteger buttonIndex))completion
{
	NSArray* titles = [NSArray arrayWithObjects:IString(@"Cancel"), IString(@"OK"), nil];
	[self showAlertWithTitle:title message:message buttonTitles:titles completion:completion];
}

//
#pragma mark UIAlertViewDelegate
//

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSUInteger)buttonIndex
{
	void(^completion)(NSUInteger idx) = nil;
	
	@synchronized(self) {
		NSUInteger index = [self.alerts indexOfObject:alertView];
		if(index != NSNotFound) {
			completion = [self.completionBlocks objectAtIndex:index];
			if(completion != nil) {
				[self.alerts removeObjectAtIndex:index];
				[self.completionBlocks removeObjectAtIndex:index];
			}
		}
	}
	
	if(completion != nil) completion(buttonIndex);
}

@end
