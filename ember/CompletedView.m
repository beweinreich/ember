//
//  CompletedView.m
//  example_ember
//
//  Created by bw on 12/26/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import "CompletedView.h"
#import <CSAnimationView.h>
#import "UIAlertView+Blocks.h"
#import <RestKit.h>

@implementation CompletedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = TRUE;
        
        // Label Animation View
        CSAnimationView *labelView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0, 0, 200, 88)];
        labelView.duration = 0.5;
        labelView.delay    = 0;
        labelView.type     = CSAnimationTypeFadeIn;
        labelView.backgroundColor = [UIColor blackColor];
        // Label
        UILabel *completedBy = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 88)];
        [completedBy setText:@"Complete by:"];
        [completedBy setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [completedBy setTextColor:[UIColor lightGrayColor]];
        [labelView addSubview:completedBy];
        
        // Call Button Animation View
        CSAnimationView *callView = [[CSAnimationView alloc] initWithFrame:CGRectZero];
        callView.duration = 0.3;
        callView.delay    = 0.0;
        callView.type     = CSAnimationTypeMorph;
        callView.backgroundColor = [UIColor blackColor];
        // Call button
        UIButton *callButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [callButton setBackgroundImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        [callButton addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        [callView addSubview:callButton];
        [callButton sizeToFit];
        [callView sizeToFit];
        [callButton setFrame:CGRectMake(166, 34, callButton.frame.size.width, callButton.frame.size.height)];
//        [callView setFrame:CGRectMake(166, 34, callView.frame.size.width, callView.frame.size.height)];
        [callView setUserInteractionEnabled:TRUE];
        
        // Text Button Animation View
        CSAnimationView *smsView = [[CSAnimationView alloc] initWithFrame:CGRectZero];
        smsView.duration = 0.3;
        smsView.delay    = 0.1;
        smsView.type     = CSAnimationTypeMorph;
        smsView.backgroundColor = [UIColor blackColor];
        // Call button
        UIButton *smsButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [smsButton setBackgroundImage:[UIImage imageNamed:@"sms"] forState:UIControlStateNormal];
        [smsButton addTarget:self action:@selector(text:) forControlEvents:UIControlEventTouchUpInside];
        [smsView addSubview:smsButton];
        [smsButton sizeToFit];
        [smsView sizeToFit];
        [smsButton setFrame:CGRectMake(212, 37, smsButton.frame.size.width, smsButton.frame.size.height)];
//        [smsView setFrame:CGRectMake(212, 37, smsView.frame.size.width, smsView.frame.size.height)];
        
        // Email Button Animation View
        CSAnimationView *emailView = [[CSAnimationView alloc] initWithFrame:CGRectZero];
        emailView.duration = 0.3;
        emailView.delay    = 0.2;
        emailView.type     = CSAnimationTypeMorph;
        emailView.backgroundColor = [UIColor blackColor];
        // Call button
        UIButton *emailButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [emailButton setBackgroundImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
        [emailButton addTarget:self action:@selector(email:) forControlEvents:UIControlEventTouchUpInside];
        [emailView addSubview:emailButton];
        [emailButton sizeToFit];
        [emailView sizeToFit];
        [emailButton setFrame:CGRectMake(264, 37, emailButton.frame.size.width, emailButton.frame.size.height)];
//        [emailView setFrame:CGRectMake(264, 37, smsView.frame.size.width, smsView.frame.size.height)];
        
//        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(smsView, callView);
//        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[smsView]-200-[callView]" options:0 metrics:nil views:viewsDictionary];
//        [self addConstraints:constraints];
        
        // Add items to subview
        [self addSubview:labelView];
        [self addSubview:callButton];
        [self addSubview:smsButton];
        [self addSubview:emailButton];

        // Animate the layers
//        [labelView startCanvasAnimation];
//        [callView startCanvasAnimation];
//        [smsView startCanvasAnimation];
//        [emailView startCanvasAnimation];

    }
    return self;
}


-(void)call:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone" message:[NSString stringWithFormat:@"Call %@?", self.user.name] delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yes", nil];
    [alertView showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.user.phone]]];
        }
    }];

    self.user.isComplete = @0;
    self.user.hasReminder = @0;
    self.user.reminderDate = NULL;
    
    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];

    [self.delegate completedViewIsDone:self.user];
}

-(void)text:(id)sender {
    self.user.isComplete = @0;
    self.user.hasReminder = @0;
    self.user.reminderDate = NULL;
    
    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];
    
    [self.delegate completedViewIsDone:self.user];
}

-(void)email:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email" message:[NSString stringWithFormat:@"Email %@?", self.user.name] delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yes", nil];
    [alertView showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
        } else {
            NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=Hello there!", self.user.email];
            NSString *body = @"&body=It is raining in Syracuse!";
            NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }];
    
    self.user.isComplete = @0;
    self.user.hasReminder = @0;
    self.user.reminderDate = NULL;
    
    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];
    
    [self.delegate completedViewIsDone:self.user];
}

@end
