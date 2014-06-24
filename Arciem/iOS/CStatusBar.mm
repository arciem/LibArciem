//
//  CStatusBar.mm
//  Arciem
//
//  Created by Robert McNally on 10/25/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CStatusBar.h"
#import "ThreadUtils.h"
#import "CSerializer.h"

@interface CStatusBar ()

@property (nonatomic) NSPointerArray *proxiesStack;
@property (readonly, nonatomic) CStatusBarProxy *activeProxy;
@property (nonatomic) CSerializer *serializer;

@end

@interface CStatusBarProxy ()

- (instancetype)initWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle;
- (void)syncStatusBarAnimated:(BOOL)animated;

@end

@implementation CStatusBar

- (instancetype)init {
    if(self = [super init]) {
        self.serializer = [CSerializer newSerializerWithName:@"CStatusBar Serializer"];
        self.proxiesStack = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

+ (CStatusBar *)sharedStatusBar {
    static CStatusBar *statusBar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statusBar = [CStatusBar new];
    });
    return statusBar;
}

- (CStatusBarProxy *)activeProxy {
    return [self.serializer performWithResult:^{
        [self.proxiesStack compact];
        NSArray *proxies = [self.proxiesStack allObjects];
        return proxies.lastObject;
    }];
}

- (void)addProxy:(CStatusBarProxy *)proxy {
    [self.serializer perform:^{
        [self.proxiesStack addPointer:(void *)proxy];
        [self update];
    }];
}

- (void)removeProxy:(CStatusBarProxy *)proxy {
    [self.serializer perform:^{
        NSUInteger proxyIndex = [[self.proxiesStack allObjects] indexOfObject:proxy];
        if(proxyIndex != NSNotFound) {
            [self.proxiesStack removePointerAtIndex:proxyIndex];
            [self update];
        }
    }];
}

- (void)update {
    [self.activeProxy syncStatusBarAnimated:YES];
}

@end

@implementation CStatusBarProxy

@synthesize statusBarStyle = _statusBarStyle;

- (instancetype)initWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    if(self = [super init]) {
        _statusBarStyle = statusBarStyle;
    }
    return self;
}

+ (CStatusBarProxy *)proxyWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    return [[CStatusBarProxy alloc] initWithStatusBarStyle:statusBarStyle];
}

+ (CStatusBarProxy *)proxy {
    return [self proxyWithStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc {
    [[CStatusBar sharedStatusBar] update];
}

- (UIStatusBarStyle)statusBarStyle {
    return _statusBarStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)syncStatusBarAnimated:(BOOL)animated {
    if([UIApplication sharedApplication].statusBarStyle != self.statusBarStyle) {
        [NSThread performBlockOnMainThread:^{
            [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:animated];
        } afterDelay:0.01];
    }
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    if(_statusBarStyle != statusBarStyle) {
        _statusBarStyle = statusBarStyle;
        if([CStatusBar sharedStatusBar].activeProxy == self) {
            [self syncStatusBarAnimated:animated];
        }
    }
}

@end