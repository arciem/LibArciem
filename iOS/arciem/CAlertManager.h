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

#import <UIKit/UIKit.h>

extern const NSInteger kCancelButtonIndex;
extern const NSInteger kOKButtonIndex;

@interface CAlertManager : NSObject
{
	@private
	NSMutableArray* _alerts;
	NSMutableArray* _invocations;
}

+ (CAlertManager*)sharedInstance;

// callback must be of the form (but not necessarily the same name as):
// - (void)alertDidDismissWithButtonIndex:(NSNumber*)index;
// - (void)alertDidDismissWithButtonIndex:(NSNumber*)index argument:(id)argument;

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector buttonTitles:(NSArray*)buttonTitles argument:(id)argument;
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector buttonTitles:(NSArray*)buttonTitles;
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector;
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message;
- (void)showConfirmAlertWithTitle:(NSString*)title message:(NSString*)message target:(id)target selector:(SEL)selector;

@end
