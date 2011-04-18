//
//  NibUtils.m
//  LibArciem
//
//  Created by Robert McNally on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NibUtils.h"


@implementation NSObject(NibUtils)

+ (id)loadFromClassNamedNib
{
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	for (NSObject *obj in nibObjects) {
		if ([obj isKindOfClass:[self class]]) {
			return obj;
		}
	}
	return nil;
}

+ (id)loadFromNibNamed:(NSString*)nibName
{
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
	for (NSObject *obj in nibObjects) {
		if ([obj isKindOfClass:[self class]]) {
			return obj;
		}
	}
	return nil;
}

@end
