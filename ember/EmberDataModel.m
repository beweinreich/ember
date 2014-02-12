//
//  FlameDataModel.m
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import "EmberDataModel.h"
#import <CoreData/CoreData.h>
#import "CoreData+MagicalRecord.h"

// Use a class extension to expose access to MagicalRecord's private setter methods
@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end

@interface EmberDataModel ()

@end

@implementation EmberDataModel

+(void)setup {
    NSError *error = nil;
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000/"];

    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Ember" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    //Check if data directory exists
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) { RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error); }
    
    //Set up persistent storage
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Ember.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    
    if (! persistentStore) { RKLogError(@"Failed adding persistent store at path '%@': %@", path, error); }
    
    //Create contexts
    [managedObjectStore createManagedObjectContexts];
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    //Create the base object manager
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    //Send stuff as JSON
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    objectManager.managedObjectStore = managedObjectStore;
    
    //Set the shared manager to the created objectManager
    [RKObjectManager setSharedManager:objectManager];
    
    
    // Configure MagicalRecord to use RestKit's Core Data stack
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:managedObjectStore.mainQueueManagedObjectContext];
}

-(void)whyIsItBroken {
    NSManagedObjectContext *context = [[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext];
    NSLog(@"Context: %@", context);
    NSLog(@"PS Coord : %@",context.persistentStoreCoordinator);
    NSLog(@"MOM : %@", context.persistentStoreCoordinator.managedObjectModel);
    NSLog(@"Entities : %@",[[context.persistentStoreCoordinator.managedObjectModel entities] valueForKey:@"name"]);
}


@end
