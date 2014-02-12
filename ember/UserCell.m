//
//  UserCell.m
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import "UserCell.h"
#import <RestKit.h>
#import "BWTableView.h"
#import "CompletedView.h"
#import <CSAnimationView.h>
#import <CKCalendarView.h>

@interface UserCell () <CKCalendarDelegate>

@end

@implementation UserCell

//@property (nonatomic, strong) CSAnimationView *calendarView;
//@property (nonatomic, strong) CSAnimationView *calendarBackgroundView;

-(void)setupCell {

    // finding the tableview like this only works on ios7
    BWTableView *tableView = (BWTableView *)self.superview.superview;
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
    [self setDefaultColor:redBlueColor];

    self.textLabel.text = [NSString stringWithFormat:@"%@", self.user.name];
    if (self.user.reminderDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"eeee, MMMM d"];
        [self.detailTextLabel setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:self.user.reminderDate]]];
    } else {
        [self.detailTextLabel setText:@""];
    }

    // setting up the completed view
//    [[self viewWithTag:99] removeFromSuperview];
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

    __unsafe_unretained User *weakUser = self.user;
    // Adding gestures per state basis.
    [self setSwipeGestureWithView:checkView color:blackColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        weakUser.isComplete = @1;
        [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] save:nil];
    }];

    [self setSwipeGestureWithView:crossView color:redBlueColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        weakUser.tracking = @0;
        weakUser.reminderDate = NULL;
        weakUser.hasReminder = @0;
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


// setup the completed view
//    _completedView = [[CompletedView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];




//#pragma mark Calendar Delegate
//-(void)setupCalendarView {
//    _calendarView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0, 75, 320, 290)];
//    _calendarBackgroundView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0, 0, 320, 800)];
//    [_calendarBackgroundView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7]];
//    
//    UIButton *closeCalendarViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 800)];
//    [closeCalendarViewButton addTarget:self action:@selector(closeCalendarAndReload) forControlEvents:UIControlEventTouchDown];
//    [closeCalendarViewButton setBackgroundColor:[UIColor clearColor]];
//    [_calendarBackgroundView addSubview:closeCalendarViewButton];
//    
//    CKCalendarView *calendar = [[CKCalendarView alloc] init];
//    calendar.delegate = self;
//    [_calendarView addSubview:calendar];
//    [_calendarView sizeToFit];
//}
//
//-(void)launchCalendar {
//    [_calendarView setFrame:CGRectMake(_calendarView.frame.origin.x, self.tableView.contentOffset.y+135, _calendarView.frame.size.width, _calendarView.frame.size.height)];
//    [_calendarView sizeToFit];
//    [_calendarBackgroundView setFrame:CGRectMake(_calendarBackgroundView.frame.origin.x, self.tableView.contentOffset.y, _calendarBackgroundView.frame.size.width, _calendarBackgroundView.frame.size.height)];
//    
//    if (![self.view.subviews containsObject:_calendarBackgroundView]) {
//        [self.view addSubview:_calendarBackgroundView];
//    }
//    
//    if (![self.view.subviews containsObject:_calendarView]) {
//        [self.view addSubview:_calendarView];
//    }
//    
//    _calendarBackgroundView.duration = 0.2;
//    _calendarBackgroundView.type     = CSAnimationTypeFadeIn;
//    [_calendarBackgroundView startCanvasAnimation];
//    
//    _calendarView.duration = 0.0;
//    _calendarView.type     = CSAnimationTypeFadeIn;
//    [_calendarView startCanvasAnimation];
//    
//    _calendarView.duration = 0.3;
//    _calendarView.delay    = 0.0;
//    _calendarView.type     = CSAnimationTypeBounceUp;
//    [_calendarView startCanvasAnimation];
//}
//
//-(void)closeCalendarAndReload {
//    [self.tableView reloadData];
//    [self closeCalendar];
//}
//
//-(void)closeCalendar {
//    _calendarView.duration = 0.2;
//    _calendarView.delay    = 0.0;
//    _calendarView.type     = CSAnimationTypeFadeOut;
//    [_calendarView startCanvasAnimation];
//    
//    _calendarBackgroundView.duration = 0.2;
//    _calendarBackgroundView.delay    = 0.0;
//    _calendarBackgroundView.type     = CSAnimationTypeFadeOut;
//    [_calendarBackgroundView startCanvasAnimation];
//}
//
//- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
//    
//    [self closeCalendar];
//    
//    _calendarUser.reminderDate = date;
//    _calendarUser.hasReminder = @1;
//    
//    NSLog(@"setting calendar for user %@ on date %@",_calendarUser.name, date);
//    
//    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];
//    
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    localNotif.fireDate = date;
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//    localNotif.alertBody = [NSString stringWithFormat:@"Reach out to %@", _calendarUser.name];
//    localNotif.alertAction = @"Sure thing";
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.applicationIconBadgeNumber = 1;
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//}


@end
