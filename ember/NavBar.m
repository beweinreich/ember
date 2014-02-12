//
//  NavBar.m
//  ember
//
//  Created by bw on 2/12/14.
//  Copyright (c) 2014 bw. All rights reserved.
//

#import "NavBar.h"

@implementation NavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translucent = NO;
        self.barTintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    }
    return self;
}


@end
