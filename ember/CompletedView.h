//
//  CompletedView.h
//  example_ember
//
//  Created by bw on 12/26/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UsersViewController.h"

@interface CompletedView : UIView

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) id <UsersViewControllerDelegate> delegate;

@end