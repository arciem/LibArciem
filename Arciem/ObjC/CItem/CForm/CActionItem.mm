//
//  CActionItem.mm
//  Arciem
//
//  Created by Robert McNally on 10/22/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CActionItem.h"
#import "CActionTableRowItem.h"

@implementation CActionItem

+ (CActionItem*)actionItemWithTitle:(NSString*)title key:(NSString*)key actionValue:(NSString *)actionValue {
	return [[self alloc] initWithDictionary:@{@"title": title,
                                              @"key": key,
                                              @"value": actionValue,
                                              @"type": @"action"}];
}

- (NSArray*)tableRowItems
{
	CActionTableRowItem* item = [CActionTableRowItem tableActionItemWithKey:self.key title:self.title actionItem:self];
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
