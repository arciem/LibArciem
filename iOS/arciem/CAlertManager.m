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

const NSInteger kCancelButtonIndex = 0;
const NSInteger kOKButtonIndex = 1;

@interface CAlertManager ()

@property(nonatomic, retain) NSMutableArray* alerts;
@property(nonatomic, retain) NSMutableArray* invocations;

@end

@implementation CAlertManager

@synthesize alerts = _alerts;
@synthesize invocations = _invocations;

- (id)init
{
	if((self = [super init])) {
		self.alerts = [NSMutableArray array];
		self.invocations = [NSMutableArray array];
	}
	
	return self;
}

- (void)dealloc
{
	self.alerts = nil;
	self.invocations = nil;
	
	[super dealloc];
}

+ (CAlertManager*)sharedInstance
{
	if(sAlertManager == nil) {
		sAlertManager = [[CAlertManager alloc] init];
	}
	
	return sAlertManager;
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector buttonTitles:(NSArray*)buttonTitles argument:(id)argument
{
	@synchronized(self) {
		UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
		if(buttonTitles == nil) {
			[alertView addButtonWithTitle:IString(@"Cancel")];
		} else {
			for(NSString* title in buttonTitles) {
				[alertView addButtonWithTitle:title];
			}
		}
		
		NSInvocation* invocation = [NSInvocation invocationForTarget:target selector:selector argument1:nil argument2:argument];
		if(invocation != nil) {
			[self.invocations addObject:invocation];
			[self.alerts addObject:alertView];
		}
		
		[alertView show];
	}
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector buttonTitles:(NSArray*)buttonTitles
{
	[self showAlertWithTitle:title message:message target:target selector:selector buttonTitles:buttonTitles argument:NULL];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector
{
	[self showAlertWithTitle:title message:message target:target selector:selector buttonTitles:nil];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
	[self showAlertWithTitle:title message:message target:nil selector:nil];
}

- (void)showConfirmAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector
{
	NSArray* titles = [NSArray arrayWithObjects:IString(@"Cancel"), IString(@"OK"), nil];
	[self showAlertWithTitle:title message:message target:target selector:selector buttonTitles:titles];
}

//
#pragma mark UIAlertViewDelegate
//

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSInvocation* invocation = nil;
	
	@synchronized(self) {
		NSUInteger index = [self.alerts indexOfObject:alertView];
		if(index != NSNotFound) {
			invocation = [self.invocations objectAtIndex:index];
			if(invocation != nil) {
				[[invocation retain] autorelease];
				NSNumber* arg = [NSNumber numberWithInteger:buttonIndex];
				[invocation setArgument:&arg atIndex:2];
				[self.alerts removeObjectAtIndex:index];
				[self.invocations removeObjectAtIndex:index];
			}
		}
	}
	
	if(invocation != nil) {
		[invocation invoke];
	}
}

@end
