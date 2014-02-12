//
//  UsersViewController.m
//  example_ember
//
//  Created by bw on 12/15/13.
//  Copyright (c) 2013 bw. All rights reserved.
//

#import "UsersViewController.h"
#import "UserCell.h"
#import "MappingProvider.h"
#import "CompletedView.h"
#import <KNMultiItemSelector/KNMultiItemSelector.h>
#import <AddressBook/AddressBook.h>
#import "CoreData+MagicalRecord.h"
#import <CKCalendar/CKCalendarView.h>
#import <CSAnimationView.h>
#import <SVProgressHUD.h>
#import "NSDate+Methods.h"
#import "BWTableView.h"

@interface UsersViewController () <NSFetchedResultsControllerDelegate, MCSwipeTableViewCellDelegate, KNMultiItemSelectorDelegate, CKCalendarDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) User *calendarUser;
@property (nonatomic, strong) CSAnimationView *calendarView;
@property (nonatomic, strong) CSAnimationView *calendarBackgroundView;
@property (nonatomic, strong) CompletedView *completedView;

@end

@implementation UsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Setup navigation bar
    [self setupNavigationBar];
    
    // Setup TableView
    self.tableView = [[BWTableView alloc] initWithFrame:self.tableView.frame];

    // setup the completed view
//    _completedView = [[CompletedView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    
    // Setup refresh control
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Refresh the data
    [self refresh];
    
    // Setup the calendar popup
    [self setupCalendarView];
}

-(void)setupNavigationBar {
    self.title = @"Ember";
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    
    UIBarButtonItem *manageUsersButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(manageUsers:)];
    manageUsersButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = manageUsersButton;
}

// Performs a local refresh of data
-(void)refresh {
    [self.tableView reloadData];
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"reminderDate" ascending:YES];
    NSSortDescriptor *sortByHasReminder = [NSSortDescriptor sortDescriptorWithKey:@"hasReminder" ascending:NO];
    [self fetchFromLocal:@"User" andSortDescriptors:@[sortByDate, sortByHasReminder] andPredicate:@"(tracking == 1)"];
}

-(void)completedViewIsDone:(User *)user {
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCellIdentifier";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    return cell;
}

#pragma mark - MCSwipeTableViewCellDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

#pragma mark Calendar Delegate
-(void)setupCalendarView {
    _calendarView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0, 75, 320, 290)];
    _calendarBackgroundView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0, 0, 320, 800)];
    [_calendarBackgroundView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7]];
  
    UIButton *closeCalendarViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 800)];
    [closeCalendarViewButton addTarget:self action:@selector(closeCalendarAndReload) forControlEvents:UIControlEventTouchDown];
    [closeCalendarViewButton setBackgroundColor:[UIColor clearColor]];
    [_calendarBackgroundView addSubview:closeCalendarViewButton];
    
    CKCalendarView *calendar = [[CKCalendarView alloc] init];
    calendar.delegate = self;
    [_calendarView addSubview:calendar];
    [_calendarView sizeToFit];
}

-(void)launchCalendar {
    [_calendarView setFrame:CGRectMake(_calendarView.frame.origin.x, self.tableView.contentOffset.y+135, _calendarView.frame.size.width, _calendarView.frame.size.height)];
    [_calendarView sizeToFit];
    [_calendarBackgroundView setFrame:CGRectMake(_calendarBackgroundView.frame.origin.x, self.tableView.contentOffset.y, _calendarBackgroundView.frame.size.width, _calendarBackgroundView.frame.size.height)];
    
    if (![self.view.subviews containsObject:_calendarBackgroundView]) {
        [self.view addSubview:_calendarBackgroundView];
    }
    
    if (![self.view.subviews containsObject:_calendarView]) {
        [self.view addSubview:_calendarView];
    }

    _calendarBackgroundView.duration = 0.2;
    _calendarBackgroundView.type     = CSAnimationTypeFadeIn;
    [_calendarBackgroundView startCanvasAnimation];
    
    _calendarView.duration = 0.0;
    _calendarView.type     = CSAnimationTypeFadeIn;
    [_calendarView startCanvasAnimation];
    
    _calendarView.duration = 0.3;
    _calendarView.delay    = 0.0;
    _calendarView.type     = CSAnimationTypeBounceUp;
    [_calendarView startCanvasAnimation];
}

-(void)closeCalendarAndReload {
    [self.tableView reloadData];
    [self closeCalendar];
}

-(void)closeCalendar {
    _calendarView.duration = 0.2;
    _calendarView.delay    = 0.0;
    _calendarView.type     = CSAnimationTypeFadeOut;
    [_calendarView startCanvasAnimation];
    
    _calendarBackgroundView.duration = 0.2;
    _calendarBackgroundView.delay    = 0.0;
    _calendarBackgroundView.type     = CSAnimationTypeFadeOut;
    [_calendarBackgroundView startCanvasAnimation];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {

    [self closeCalendar];
    
    _calendarUser.reminderDate = date;
    _calendarUser.hasReminder = @1;
    
    NSLog(@"setting calendar for user %@ on date %@",_calendarUser.name, date);
    
    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:nil];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [NSString stringWithFormat:@"Reach out to %@", _calendarUser.name];
    localNotif.alertAction = @"Sure thing";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}





#pragma mark Address Book Delegate

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

- (void)manageUsers:(id)sender {
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











// *********************************************************************************************** //
// Everything below should go in some generic file so we can use this on all tableviewcontrollers
// *********************************************************************************************** //
#pragma mark – Fetch Results

- (void)fetchFromLocal:(NSString *)entityName andSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSString *)predicate {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if (!(predicate==nil)) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@", predicate]]];
    }
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching data: %@", error);
    }
    
    [self.refreshControl endRefreshing];
}

- (void)listenForChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)contextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
    });
}

#pragma mark - Fetched results tableview updates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (indexPath!=NULL) {
                [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        default:
            [self.tableView reloadData];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Custom Delete Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
