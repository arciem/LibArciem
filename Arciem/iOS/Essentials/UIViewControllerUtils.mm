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

#import "UIViewControllerUtils.h"

@implementation UIViewController (UIViewControllerUtils)

- (void)printContainmentHierarchyWithIndent:(NSString*)indent level:(int)level {
	NSString* prefix = @"   ";
	CLogPrint(@"%@%@%3d %@", prefix, indent, level, self);
	indent = [indent stringByAppendingString:@"  |"];
    if(self.presentingViewController != nil) {
        CLogPrint(@"%@%@  presentingViewController: %@", prefix, indent, self.presentingViewController);
    }
    if(self.presentedViewController != nil) {
        CLogPrint(@"%@%@  presentedViewController: %@", prefix, indent, self.presentedViewController);
        [self.presentedViewController printContainmentHierarchyWithIndent:indent level:level+1];
    }
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController* childViewController, NSUInteger idx, BOOL *stop) {
        [childViewController printContainmentHierarchyWithIndent:indent level:level+1];
    }];
}

- (void)printContainmentHierarchy {
	[self printContainmentHierarchyWithIndent:@"" level:0];
}

- (void)printPresentationHierarchy:(NSString*)indent level:(int)level {
	NSString* prefix = @"   ";
	CLogPrint(@"%@%@%3d %@", prefix, indent, level, self);
	indent = [indent stringByAppendingString:@"  |"];
    [self.presentedViewController printPresentationHierarchy:indent level:level+1];
}

- (void)printPresentationHierarchy {
    [self printPresentationHierarchy:@"" level:0];
}

@end
