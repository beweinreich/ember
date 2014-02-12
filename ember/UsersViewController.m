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
#import "CoreData+MagicalRecord.h"
#import <CSAnimationView.h>
#import <SVProgressHUD.h>
#import "NSDate+Methods.h"
#import "BWTableView.h"
#import "UIViewController+AddressBook.h"

@interface UsersViewController () <NSFetchedResultsControllerDelegate, MCSwipeTableViewCellDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation UsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self setupNavigationBar];
    
    self.tableView = [[BWTableView alloc] initWithFrame:self.tableView.frame];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self refresh];
}

-(void)setupNavigationBar {
    self.title = @"Ember";
    
    UIBarButtonItem *manageUsersButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(manageUsers)];
    manageUsersButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = manageUsersButton;
}

-(void)refresh {
    [self.tableView reloadData];
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"reminderDate" ascending:YES];
    NSSortDescriptor *sortByHasReminder = [NSSortDescriptor sortDescriptorWithKey:@"hasReminder" ascending:NO];
    [self fetchFromLocal:@"User" andSortDescriptors:@[sortByHasReminder, sortByDate] andPredicate:@"(tracking == 1)"];
}


#pragma mark - MCSwipeTableViewCellDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCellIdentifier";
    UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupCell];

    return cell;
}


#pragma mark Protocols & Delegates
-(void)completedViewIsDone:(User *)user {
    [self.tableView reloadData];
}
















// *********************************************************************************************** //
// Everything below should go in some generic file so we can use this on all tableviewcontrollers
// *********************************************************************************************** //
#pragma mark – Fetch Results

- (void)fetchFromLocal:(NSString *)entityName andSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSString *)predicate {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    NSLog(@"%@",sortDescriptors);
    
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
