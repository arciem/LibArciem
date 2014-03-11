//
//  CStatusBar.h
//  Arciem
//
//  Created by Robert McNally on 10/25/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CStatusBarProxy;

@interface CStatusBar : NSObject

+ (CStatusBar *)sharedStatusBar;

- (void)addProxy:(CStatusBarProxy *)proxy;
- (void)removeProxy:(CStatusBarProxy *)proxy;

@end

@interface CStatusBarProxy : NSObject

@property (nonatomic) UIStatusBarStyle statusBarStyle;

+ (CStatusBarProxy *)proxyWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle;
+ (CStatusBarProxy *)proxy;

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;

@end