//
//  UIViewControllerUtils.m
//  Arciem
//
//  Created by Robert McNally on 5/23/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "UIViewControllerUtils.h"

@implementation UIViewController (UIViewControllerUtils)

- (void)printContainmentHierarchyWithIndent:(NSString*)indent level:(int)level
{
	NSString* prefix = @"   ";
	CLogPrint(@"%@%@%3d %@", prefix, indent, level, self);
	indent = [indent stringByAppendingString:@"  |"];
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController* childViewController, NSUInteger idx, BOOL *stop) {
        [childViewController printContainmentHierarchyWithIndent:indent level:level+1];
    }];
}

- (void)printContainmentHierarchy
{
	[self printContainmentHierarchyWithIndent:@"" level:0];
}

@end
