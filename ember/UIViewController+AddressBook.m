//
//  UIViewController+AddressBook.m
//  ember
//
//  Created by bw on 2/11/14.
//  Copyright (c) 2014 bw. All rights reserved.
//

#import "UIViewController+AddressBook.h"
#import <AddressBook/AddressBook.h>
#import "CoreData+MagicalRecord.h"
#import "User.h"
#import <RestKit.h>
#import <KNMultiItemSelector/KNMultiItemSelector.h>

@interface UIViewController () <KNMultiItemSelectorDelegate>
@end

@implementation UIViewController (AddressBook)

- (void)manageUsers {
    if ([self hasAddressBookPermission]) {
        
        [self addressBookContacts];
        
        NSMutableArray *contacts = [NSMutableArray new];
        [[User MR_findAll] enumerateObjectsUsingBlock:^(User *u, NSUInteger idx, BOOL *stop) {
            if (![u.tracking isEqual:@1]) {
                [contacts addObject:[[KNSelectorItem alloc] initWithDisplayValue:[NSString stringWithFormat:@"%@", u.name] selectValue:u.email imageUrl:nil]];
            }
        }];
        
        NSArray *sortedContacts = [contacts sortedArrayUsingSelector:@selector(compareByDisplayValue:)];
        
        KNMultiItemSelector *selector = [[KNMultiItemSelector alloc] initWithItems:sortedContacts
                                                                  preselectedItems:nil
                                                                             title:@"Select Contacts"
                                                                   placeholderText:@"Search..."
                                                                          delegate:self];
        selector.allowSearchControl = YES;
        selector.useRecentItems = YES;
        selector.recentItemStorageKey = @"managed_contacts";
        selector.maxNumberOfRecentItems = 10;
        UINavigationController *uinav = [[UINavigationController alloc] initWithRootViewController:selector];
        uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:uinav animated:TRUE completion:nil];
    }
}

- (BOOL)hasAddressBookPermission {
    ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    __block BOOL hasPermission;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(UsersAddressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                hasPermission = TRUE;
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                hasPermission = FALSE;
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        hasPermission = TRUE;
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        hasPermission = FALSE;
    }
    return hasPermission;
}


- (NSMutableArray *)addressBookContacts {
    NSMutableArray *contacts = [NSMutableArray new];
    
    ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    CFArrayRef ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
    
    //get the total number of count of the users contact
    CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
    
    //iterate through each record and add the value in the array
    for (int i =0; i<numberofPeople; i++) {
        ABRecordRef currentPerson = CFArrayGetValueAtIndex(ContactInfoArray, i);
        
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        
        if (emailAddresses.count > 0 && firstName != NULL) {
            NSString *email = (NSString *)[emailAddresses objectAtIndex:0];
            
            if ([User MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(email == '%@')", email]]] == 0) {
                if ([User MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(name == '%@')", [[NSString stringWithFormat:@"%@ %@",firstName, lastName] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"] ]]] == 0) {
                    User *u = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
                    u.name = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
                    u.email = email;
                    u.isComplete = @0;
                    u.hasReminder = @0;
                    u.reminderDate = NULL;
                    
                    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];
                    [contacts addObject:u];
                }
            }
        }
    }
    
    return contacts;
}


#pragma mark - KNMultiItemSelectorDelegate

-(void)selectorDidSelectItem:(KNSelectorItem *)selectedItem {
    NSLog(@"Selected %@", selectedItem.selectValue);
    User *u = [User MR_findFirstByAttribute:@"email" withValue:selectedItem.selectValue];
    u.tracking = @1;
    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];
}

-(void)selectorDidDeselectItem:(KNSelectorItem *)selectedItem {
    NSLog(@"Removed %@", selectedItem.selectValue);
    User *u = [User MR_findFirstByAttribute:@"email" withValue:selectedItem.selectValue];
    u.tracking = @0;
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    [context saveToPersistentStore:nil];
}

-(void)selectorDidFinishSelectionWithItems:(NSArray *)selectedItems {
    NSString *text = @"Selected: ";
    for (KNSelectorItem * i in selectedItems) {
        text = [text stringByAppendingFormat:@"%@,", i.selectValue];
    }
    NSLog(@"%@",text);
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)selectorDidCancelSelection {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


@end
