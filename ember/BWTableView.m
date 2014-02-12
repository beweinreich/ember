//
//  BWTableView.m
//  ember
//
//  Created by bw on 2/11/14.
//  Copyright (c) 2014 bw. All rights reserved.
//

#import "BWTableView.h"

@implementation BWTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        // Set background of tableview to gray, so when you pull a cell, you see the gray background
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [backgroundView setBackgroundColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]];
        [self setBackgroundView:backgroundView];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setShowsVerticalScrollIndicator:NO];

        // fix for refresh control
        self.backgroundView.layer.zPosition -= 1;

    }
    return self;
}

@end
