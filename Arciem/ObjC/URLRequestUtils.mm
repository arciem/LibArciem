//
//  URLRequestUtils.m
//  Arciem
//
//  Created by Robert McNally on 6/5/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "URLRequestUtils.h"

@implementation NSURLRequest (URLRequestUtils)

- (NSString*)HTTPBodyAsString {
    return [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
}

@end
