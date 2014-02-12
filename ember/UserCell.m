//
//  UserCell.m
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import "UserCell.h"
#import "User.h"
#import <RestKit.h>

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if(self){
        [self setupCell];
    }
    return self;
}

-(void)setupCell {
    UITableView *tableView = (UITableView *)self.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:self];

    // Remove inset of iOS 7 separators.
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        self.separatorInset = UIEdgeInsetsZero;
    }

    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    // Setting the background color of the cell.
    self.contentView.backgroundColor = [UIColor whiteColor];

    // Right side color view indicating when the reminder is coming
    float blueTint = (indexPath.row*40) > 255 ? 255 : (indexPath.row*40);
    UIColor *redBlueColor = [UIColor colorWithRed:228.0/255.0 green:55.0/255.0 blue:blueTint/255.0 alpha:1];
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(310, 0, 10, 88)];
    [colorView setBackgroundColor:redBlueColor];
    [self addSubview:colorView];

    // Configuring the views and colors.
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *blackColor = [UIColor colorWithRed:0.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];

    UIView *crossView = [self viewWithImageName:@"cross"];
    UIView *clockView = [self viewWithImageName:@"clock"];

    // Setting the default inactive state color to the tableView background color.
    [self setDefaultColor:tableView.backgroundView.backgroundColor];

//    User *u = ((User *)[self.fetchedResultsController objectAtIndexPath:indexPath]);
//    self.textLabel.text = [NSString stringWithFormat:@"%@", u.name];

//    if (u.reminderDate) {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"eeee, MMMM d"];
//        [self.detailTextLabel setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:u.reminderDate]]];
//    } else {
//        [self.detailTextLabel setText:@""];
//    }

    // setting up the completed view
    [[self viewWithTag:99] removeFromSuperview];
//    _completedView.tag = 99;
//    [_completedView setFrame:(CGRectMake(0, 0, 320, 88))];
//    [_completedView setDelegate:self];
//    [_completedView setUser:u];
//    [self addSubview:_completedView];

//    if([u.isComplete isEqual:@1]) {
//        [_completedView setHidden:FALSE];
//    } else {
//        [_completedView setHidden:TRUE];
//    }

    // Adding gestures per state basis.
    [self setSwipeGestureWithView:checkView color:blackColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
//        User *u = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
//        u.isComplete = @1;
//        [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] save:nil];
    }];

    [self setSwipeGestureWithView:crossView color:redBlueColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
//        User *u = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
//        u.tracking = @0;
//        u.reminderDate = NULL;
//        u.hasReminder = @0;
        [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] save:nil];
    }];

    [self setSwipeGestureWithView:clockView color:redBlueColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
//        _calendarUser = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
//        [self launchCalendar];
    }];

    [self setSwipeGestureWithView:clockView color:redBlueColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
//        _calendarUser = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
//        [self launchCalendar];
    }];
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
