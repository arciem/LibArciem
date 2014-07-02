//
//  CSectionItem.m
//  Arciem
//
//  Created by Robert McNally on 10/22/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CSectionItem.h"
#import "CTableSectionItem.h"

@implementation CSectionItem

+ (CSectionItem*)newSectionItemWithTitle:(NSString*)title key:(NSString*)key {
	return [[self alloc] initWithDictionary:@{@"title": EnsureRealString(title),
                                              @"key": EnsureRealString(key),
                                              @"type": @"section"}];
}

- (NSArray*)tableRowItems
{
    CTableSectionItem *tableSectionItem = [CTableSectionItem newTableSectionItemWithTitle:self.title key:self.key];
    tableSectionItem.hidden = self.hidden;
	for(CItem* subitem in self.subitems) {
		NSArray* rowItems = [subitem tableRowItems];
        [tableSectionItem addSubitems:rowItems];
	}
	return @[tableSectionItem];
}

@end
