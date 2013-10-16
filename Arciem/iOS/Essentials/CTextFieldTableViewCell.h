//
//  CTextFieldTableViewCell.h
//  Arciem
//
//  Created by Robert McNally on 10/12/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTextFieldTableViewCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@property(readonly, nonatomic) UITextField* textField;
@property(nonatomic) CGFloat textFieldLeft;

@end
