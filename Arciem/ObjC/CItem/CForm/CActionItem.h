//
//  CActionItem.h
//  Arciem
//
//  Created by Robert McNally on 10/22/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import "CItem.h"

@interface CActionItem : CItem

@property (nonatomic) NSString *actionValue;

+ (CActionItem*)newActionItemWithTitle:(NSString*)title key:(NSString*)key actionValue:(NSString *)actionValue;

@end
