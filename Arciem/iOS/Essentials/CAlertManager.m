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
#import "CSerializer.h"

const NSUInteger kCancelButtonIndex = 0;
const NSUInteger kOKButtonIndex = 1;

@interface CAlertManager ()

@property(nonatomic) NSMutableArray *alerts;
@property(nonatomic) NSMutableArray *completionBlocks;
@property (nonatomic) CSerializer *serializer;

@end

@implementation CAlertManager

@synthesize alerts = alerts_;
@synthesize completionBlocks = completionBlocks_;

- (instancetype)init {
	if((self = [super init])) {
		self.alerts = [NSMutableArray array];
		self.completionBlocks = [NSMutableArray array];
        self.serializer = [CSerializer newSerializerWithName:@"AlertManager Serializer"];
	}
	
	return self;
}

+ (CAlertManager *)sharedAlertManager {
    static CAlertManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [CAlertManager new];
    });
    return instance;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completion:(alert_completion_block_t)completion {
    [self.serializer dispatch:
	^{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		if(buttonTitles == nil) {
			[alertView addButtonWithTitle:IString(@"Cancel")];
		} else {
			for(NSString *title in buttonTitles) {
				[alertView addButtonWithTitle:title];
			}
		}

		[self.alerts addObject:alertView];
        if(completion == NULL) {
            [self.completionBlocks addObject:[^(NSUInteger idx) { } copy]];
        } else {
            [self.completionBlocks addObject:[completion copy]];
        }
		
		[alertView show];
	}];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title message:message buttonTitles:nil completion:NULL];
}

- (void)showCancelAlertWithTitle:(NSString *)title message:(NSString *)message completion:(alert_completion_block_t)completion {
	[self showAlertWithTitle:title message:message buttonTitles:nil completion:completion];
}

- (void)showCancelAlertWithTitle:(NSString *)title message:(NSString *)message {
	[self showCancelAlertWithTitle:title message:message completion:nil];
}

- (void)showConfirmAlertWithTitle:(NSString *)title message:(NSString *)message completion:(alert_completion_block_t)completion {
	[self showAlertWithTitle:title message:message buttonTitles:@[IString(@"Cancel"), IString(@"OK")] completion:completion];
}

- (void)showOKAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title message:message buttonTitles:@[IString(@"OK")] completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSUInteger)buttonIndex {
    SerializerBlock f = ^{
        void(^result)(NSUInteger) = NULL;
        NSUInteger index = [self.alerts indexOfObject:alertView];
        if(index != NSNotFound) {
            result = (self.completionBlocks)[index];
            [self.alerts removeObjectAtIndex:index];
            [self.completionBlocks removeObjectAtIndex:index];
        }
        return (id)result;
    };
	alert_completion_block_t completion = [self.serializer dispatchWithResult:f];
	
	if(completion != NULL) completion(buttonIndex);
}

@end
