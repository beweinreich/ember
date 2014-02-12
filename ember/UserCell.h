//
//  UserCell.h
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MCSwipeTableViewCell/MCSwipeTableViewCell.h>
#import "User.h"

@interface UserCell : MCSwipeTableViewCell

@property (strong, nonatomic) User *user;

-(void)setupCell;

@end
