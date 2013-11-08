//
//  CSectionItem.mm
//  Arciem
//
//  Created by Robert McNally on 10/22/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CSectionItem.h"
#import "CTableSectionItem.h"

@implementation CSectionItem

+ (CSectionItem*)sectionItemWithTitle:(NSString*)title key:(NSString*)key {
	return [[self alloc] initWithDictionary:@{@"title": title,
                                              @"key": key,
                                              @"type": @"section"}];
}

- (NSArray*)tableRowItems
{
    CTableSectionItem *tableSectionItem = [CTableSectionItem tableSectionItemWithTitle:self.title key:self.key];
    tableSectionItem.hidden = self.hidden;
	for(CItem* subitem in self.subitems) {
		NSArray* rowItems = [subitem tableRowItems];
        [tableSectionItem addSubitems:rowItems];
	}
	return @[tableSectionItem];
}

@end
