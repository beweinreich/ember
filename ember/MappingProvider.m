//
//  MappingProvider.m
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import "MappingProvider.h"
#import "User.h"
#import "EmberDataModel.h"

@implementation MappingProvider

+ (RKMapping *)userMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{ @"id": @"userID", @"first_name": @"name" }];
    mapping.identificationAttributes = @[@"userID"];

    RKResponseDescriptor *indexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/users.json" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *showResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/users/:user_id.json" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[indexResponseDescriptor, showResponseDescriptor]];
    
    return mapping;
}

@end
