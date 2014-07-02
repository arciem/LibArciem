//
//  CActionItem.m
//  Arciem
//
//  Created by Robert McNally on 10/22/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CActionItem.h"
#import "CActionTableRowItem.h"
#import "StringUtils.h"
#import "ObjectUtils.h"

@implementation CActionItem

+ (CActionItem*)newActionItemWithTitle:(NSString*)title key:(NSString*)key actionValue:(NSString *)actionValue {
	return [[self alloc] initWithDictionary:@{@"title": EnsureRealString(title),
                                              @"key": EnsureRealString(key),
                                              @"value": Denull(actionValue),
                                              @"type": @"action"}];
}

- (NSArray*)tableRowItems
{
	CActionTableRowItem* item = [CActionTableRowItem newTableActionItemWithKey:self.key title:self.title actionItem:self];
	return @[item];
}

+ (NSSet*)keyPathsForValuesAffectingActionValue {
    return [NSSet setWithArray:@[@"value"]];
}

- (NSString *)actionValue
{
	return (NSString *)self.value;
}

- (void)setActionValue:(NSString *)actionValue
{
	self.value = actionValue;
}

@end
