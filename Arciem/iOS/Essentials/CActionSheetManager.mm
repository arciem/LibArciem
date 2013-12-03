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

#import "CActionSheetManager.h"
#import "StringUtils.h"

@interface CActionSheetManager () <UIActionSheetDelegate>

@property (nonatomic) NSMutableArray *actionSheets;
@property (nonatomic) NSMutableArray *completionBlocks;

@end

@implementation CActionSheetManager

- (id)init {
	if((self = [super init])) {
		self.actionSheets = [NSMutableArray array];
		self.completionBlocks = [NSMutableArray array];
	}
	
	return self;
}

+ (CActionSheetManager *)sharedActionSheetManager {
    static CActionSheetManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [CActionSheetManager new];
    });
    return instance;
}

- (UIActionSheet *)showActionSheetFromParent:(id)parent title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(void (^)(UIActionSheet *actionSheet, NSInteger buttonIndex))completion {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for(NSString *title in otherButtonTitles) {
        [actionSheet addButtonWithTitle:title];
    }
    if(!IsEmptyString(destructiveButtonTitle)) {
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
        actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
    }
    if(!IsEmptyString(cancelButtonTitle)) {
        [actionSheet addButtonWithTitle:cancelButtonTitle];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    }
    
    if(completion == NULL) {
        completion = ^(UIActionSheet *, NSInteger) { };
    }
    
    [self.actionSheets addObject:actionSheet];
    [self.completionBlocks addObject:[completion copy]];
    
    if([parent isKindOfClass:[UITabBar class]]) {
        [actionSheet showFromTabBar:(UITabBar *)parent];
    } else if([parent isKindOfClass:[UIToolbar class]]) {
        [actionSheet showFromToolbar:(UIToolbar *)parent];
    } else if([parent isKindOfClass:[UIBarButtonItem class]]) {
        [actionSheet showFromBarButtonItem:(UIBarButtonItem *)parent animated:YES];
    } else if([parent isKindOfClass:[UIView class]]) {
        [actionSheet showInView:(UIView *)parent];
    } else {
        NSAssert1(NO, @"Unsupported parent for UIActionSheet:%@", parent);
        actionSheet = nil;
    }
    
    return actionSheet;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    void(^completion)(UIActionSheet *, NSUInteger) = NULL;
    
    NSUInteger index = [self.actionSheets indexOfObject:actionSheet];
    if(index != NSNotFound) {
        completion = (self.completionBlocks)[index];
        [self.actionSheets removeObjectAtIndex:index];
        [self.completionBlocks removeObjectAtIndex:index];
        completion(actionSheet, buttonIndex);
    }
}

@end
