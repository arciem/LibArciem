//
//  NibUtils.h
//  LibArciem
//
//  Created by Robert McNally on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSObject(NibUtils)

+ (id)loadFromClassNamedNib;
+ (id)loadFromNibNamed:(NSString*)nibName;

@end
