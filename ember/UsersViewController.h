//
//  UsersViewController.h
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol UsersViewControllerDelegate <NSObject>
- (void)completedViewIsDone:(User *)user;
@end

@interface UsersViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UsersViewControllerDelegate>

@end
