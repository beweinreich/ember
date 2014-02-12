//
//  User.h
//  ember
//
//  Created by bw on 2/10/14.
//  Copyright (c) 2014 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * tracking;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSDate * reminderDate;
@property (nonatomic, retain) NSNumber * hasReminder;
@property (nonatomic, retain) NSNumber * isComplete;

@end
