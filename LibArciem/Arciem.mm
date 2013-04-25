//
//  LibArciem.h
//  LibArciem
//
//  Created by Robert McNally on 2/12/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "LibArciem.h"

@implementation LibArciem

+ (NSBundle*)frameworkBundle
{
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"LibArciem.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

@end