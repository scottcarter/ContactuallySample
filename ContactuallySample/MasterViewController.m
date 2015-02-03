//
//  MasterViewController.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "Project.h"
#import "EnterApiKeyController.h"

#import "KeychainHelper.h"

#import "ContactuallyConnection.h"

#import "Bucket+Create.h"
#import "Contact+Create.h"



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Private Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
@interface MasterViewController () <EnterApiKeyControllerDelegate, UIAlertViewDelegate>

// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark Properties

// None

@end



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@implementation MasterViewController

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines

// None




// ==========================================================================
// Getters and Setters
// ==========================================================================
//
#pragma mark -
#pragma mark Getters and Setters


// None



// ==========================================================================
// Actions
// ==========================================================================
//
#pragma mark -
#pragma mark Actions

// User requested a logout
- (void)logout
{
    
    NSError *error = nil;
    
    // Cleanup NSFetchedResultsController for Master
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsCacheName];
    self.fetchedResultsController = nil;
    
    // Cleanup NSFetchedResultsController for Detail
    // Not using cache with Detail since we are frequently changing predicate (bucket selection)
    self.detailViewController.fetchedResultsController = nil;
    
    
    // Empty Core Data and reset the context to forget all managed objects
    if(![self emptyCoreData:self error:&error]){
        ERROR_LOG("Unable to empty core data: %@", error)
        abort();
    }
    
    
    // Remove API Key from Keychain
    [KeychainHelper removePasswordForKey:KEYCHAIN_API_KEY];
    
    
    // Present EnterApiKeyController to get the API key.
    [self requestNewAPIKey];
    
}


// User requested a reload from Contactually
//
// Fetch new records from Contactually and then call loadBucketsAndUpdate
// to update Core Data and reload Table View.
//
- (void)reloadBucketsFromContactually
{
    
    // Fetch buckets
    [self.contactuallyConnection getBucketsWithCompletion:^(BOOL success, NSError *error, NSArray *buckets) {
        
        if(success){
            
            // Call loadBucketsAndUpdate to update Core Data and reload
            // Table View.
            [self loadBucketsAndUpdate:buckets];
        }
        else {
            
            // Key was not valid, so invalidate session
            [self.contactuallyConnection freeMemory];
            self.contactuallyConnection = nil;
            
            // Alert the user about error and force logout in UIAlertView delegate method.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error connecting to Contactually" message:@"Re-enter API key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
    }];
    
}




// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //NLOG("MasterViewController awakeFromNib  self=%@", self)
    
    // Boiler plate for iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}


- (void)dealloc
{
    // PLOG_TOP("MasterViewController dealloc  self=%@", self)
    
    [self.contactuallyConnection freeMemory];  // Invalidate the session
    self.contactuallyConnection = nil;
    
    // Unregister from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Bucket *bucket = (Bucket *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        // Update our strong reference to the DetailViewController
        self.detailViewController= controller;
        
        // Have contacts been previously loaded for this bucket?
        if(![bucket.contactsLoaded boolValue]){
            [self contactsFromContactuallyForBucket:bucket];
        }
        
        // Why not store a reference to bucket in Detail View Controller?
        // Consider the case where we transition to Detail View Controller after setting
        // valid bucket, but call to contactsFromContactuallyForBucket had an error which
        // caused us to logout.  The logout process will empty Core Data and invalidate the
        // reference to bucket that Detail View Controller is holding onto (hit this case during testing).
        //
        // Safer to store bucket id in Detail View Controller instead.
        [controller setBucketIdNum:[bucket valueForKey:@"identifier"]];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
        NSString *detailTitle = [NSString stringWithFormat:@"Contacts - %@",[bucket valueForKey:@"name"]];
        controller.title = detailTitle;
    }
    else {
        EXCEPTION_LOG("Unhandled segue %@",[segue identifier])
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // NLOG("MasterViewController viewDidLoad  self=%@", self)
    
    self.title = @"Buckets";
    
    // Set preferred mode for larger devices to show master and detail in Portrait mode.
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    
    // Initialize base class properties
    self.fetchedResultsCacheName = @"BucketCache";
    self.entityName = @"Bucket";
    self.sortFieldName = @"name";
    
    
    // The boiler plate for a Master-Detail application creates a strong reference to the Detail View Controller here,
    // and we are able to access both Master and Detail View Controllers at this point, even on an iPhone.
    //
    // Some notes:
    // We do require a reference to the DetailViewController in order to be able to access its NSFetchedResultsController
    // to set it to nil before we perform our efficient emptying of Core Data.
    //
    // When a replace segue is invoked, the reference is no longer valid and needs to be updated.  We do this
    // in prepareForSegue.
    //
    // A strong reference will prevent the DetailViewController from deallocating, but after a segue replace (and update
    // of our strong reference), the previous DetailViewController can deallocate.
    //
    // We can not access the DetailViewController from self.splitViewController.viewControllers on an iPhone
    // outside of viewDidLoad.   The documentation also explicitly states:
    // "When the split view interface is expanded, this property contains two view controllers; when it is collapsed,
    // this property contains only one view controller. The first view controller in the array is always the primary
    // (or master) view controller. If a second view controller is present, that view controller is the secondary
    // (or detail) view controller."
    //
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadBucketsFromContactually)];
    self.navigationItem.leftBarButtonItem = addButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    
    // Configure for self sizing cells
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Listen for changes to text size
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}


// If text size changed, reload table cells
//
// Reference: http://useyourloaf.com/blog/2013/12/17/supporting-dynamic-type.html
//
- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
 
    // Has user verified and stored an API key?
    NSString *apiKey = [KeychainHelper getPasswordForKey:KEYCHAIN_API_KEY];
    
    if(!apiKey){
        [self requestNewAPIKey];
    }
    
}



// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods



#pragma mark EnterApiKeyControllerDelegate

// This is our entry point after validating a new API key using EnterApiKeyController.
//
// We can reach this point either from an initial login, or after a logout and new login.
//
// Dismiss EnterApiKeyController and call loadBucketsAndUpdate to update Core Data and reload
// Table View.
//
- (void)dismissEnterApiKeyController:(NSArray *)buckets
{
    // NLOG("Got buckets %@", buckets)
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self loadBucketsAndUpdate:buckets];
    }];
}


#pragma mark UIAlertViewDelegate


// We currently only use an alert with an error for which we wish to force an immediate logout.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self logout];
}


// ==========================================================================
// Override base class methods
// ==========================================================================
//
#pragma mark -
#pragma mark Override base class methods


#pragma mark Table View

// Need to override base class method
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
    
    // Use a text style that scales for Dynamic Text
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
}





// ==========================================================================
// Class methods
// ==========================================================================
//
#pragma mark -
#pragma mark Class methods

// None


// ==========================================================================
// Instance methods
// ==========================================================================
//
#pragma mark -
#pragma mark Instance methods


// User selected a bucket to display contents of.
//
// Fetch new records from Contactually and then update Core Data.
// Contacts are fetched in the background for performance reasons.
//
// DetailViewController will get updated automatically via NSFetchedResultsController
//
- (void)contactsFromContactuallyForBucket:(Bucket *)bucket
{
    NSNumber *bucketIdNum = bucket.identifier;
   
    [self.contactuallyConnection getContactsForBucketId:bucketIdNum WithCompletion:^(BOOL success, NSError *apiError, NSArray *contacts) {
        
        NSError *error = nil;
        
        if(success){
            
            // Load records from Contactually into Core Data.
            for (NSDictionary *dict in contacts) {
                NSString *first_name = dict[@"first_name"];
                NSString *last_name = dict[@"last_name"];
                NSNumber *identifierNum = (NSNumber *)dict[@"id"];
                
                // Lookup or add Contact
                Contact *contact = [Contact findOrAddContactWithIdentifier:identifierNum first_name:first_name last_name:last_name inManagedObjectContext:self.managedObjectContext error:&error];
                
                if(!contact){
                    ERROR_LOG("Unable to add new bucket: %@",error)
                    abort();
                }
                
                // Add contact to bucket
                [bucket addContactObject:contact];
                
            }
            
            bucket.contactsLoaded = @YES;
            
            // Save the context.
            if (![self.managedObjectContext save:&error]) {
                ERROR_LOG("Unable to save to Core Data %@", error);
                abort();
            }
            
        }
        else {
            
            // Key was not valid, so invalidate session
            [self.contactuallyConnection freeMemory];
            self.contactuallyConnection = nil;
            
            // Alert the user about error and force logout in UIAlertView delegate method.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error connecting to Contactually" message:@"Re-enter API key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
        
        
    }];
    
  

}



// Empty Core Data quickly by deleting and recreating the persistent store.
// The performance improvement could be very significant if the user has thousands of contacts.
//
// Follow by resetting the context.
//
// References:
// http://stackoverflow.com/questions/2375888/how-do-i-delete-all-objects-from-my-persistent-store-in-core-data/8467628#8467628
// http://stackoverflow.com/questions/1077810/delete-reset-all-entries-in-core-data
//
- (BOOL)emptyCoreData:(id)sender
                error:(NSError **)error
{
    // Retrieve the store URL
    NSURL * storeURL = [[self.managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    
    
    __block BOOL success = YES;
    
    // [self.managedObjectContext lock];  // Deprecated.  Lock the current context
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSError *underlyingError = nil;
        
        // Delete the store from the current managedObjectContext
        if ([[self.managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&underlyingError])
        {
            
            // Remove the file containing the data
            
            //            // Provoke error for testing  // Remove leading !
            //            underlyingError = [[NSError alloc] initWithDomain:ApplicationErrorDomain code:ApplicationFailed userInfo:nil];
            //            if([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&underlyingError]){
            
            if(![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&underlyingError]){
                
                if(error != NULL){
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Could not remove persistent store file", @""),
                                                      NSUnderlyingErrorKey : underlyingError};
                    *error = [[NSError alloc] initWithDomain:CoreDataErrorDomain code:CoreDataRemovePersistentStoreFileError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                success = NO;
                return;
            }
            
            // Recreate the persistent store
            // These options were also used when the PersistentStore was initially setup in AppDelegate.m, persistentStoreCoordinator
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            
            if(![[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&underlyingError]){
                
                if(error != NULL){
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Could not add persistent store", @""),
                                                      NSUnderlyingErrorKey : underlyingError};
                    *error = [[NSError alloc] initWithDomain:CoreDataErrorDomain code:CoreDataAddPersistentStoreError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                success = NO;
                return;
            }
        }
        
        else {
            if(error != NULL){
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Could not remove persistent store", @""),
                                                  NSUnderlyingErrorKey : underlyingError};
                *error = [[NSError alloc] initWithDomain:CoreDataErrorDomain code:CoreDataRemovePersistentStoreError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            success = NO;
            return;
        }
        
        [self.managedObjectContext reset];
        
        
    }]; // [self.managedObjectContext performBlockAndWait:^{
    
    
    // [self.managedObjectContext unlock]; // Deprecated.
    
    
    return success;
    
}


// Empty Core Data and reload from buckets that we previously fetched.
//
// Note that emptying will also remove all cached contacts from Core Data (intentional).
- (void)loadBucketsAndUpdate:(NSArray *)buckets
{
    NSError *error = nil;
    

    // Cleanup NSFetchedResultsController for Master
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsCacheName];
    self.fetchedResultsController = nil;
    
    // Cleanup NSFetchedResultsController for Detail
    // Not using cache with Detail since we are frequently changing predicate (bucket selection)
    self.detailViewController.fetchedResultsController = nil;
    
    
    // Empty Core Data and reset the context to forget all managed objects
    if(![self emptyCoreData:self error:&error]){
        ERROR_LOG("Unable to empty core data: %@", error)
        abort();
    }
    
    
    // Load records from Contactually into Core Data.
    for (NSDictionary *dict in buckets) {
        NSString *name = dict[@"name"];
        NSNumber *identifierNum = (NSNumber *)dict[@"id"];
        
        Bucket *bucket = [Bucket addBucketWithIdentifier:identifierNum name:name inManagedObjectContext:self.managedObjectContext error:&error];
        
        if(!bucket){
            ERROR_LOG("Unable to add new bucket: %@",error)
            abort();
        }
    }
    
    // Save the context.
    if (![self.managedObjectContext save:&error]) {
        ERROR_LOG("Unable to save to Core Data %@", error);
        abort();
    }
    
    
    // Note from the NSFetchedResultsController documentation:
    //
    // It’s possible for all the objects in a managed object context to be invalidated simultaneously.
    // (For example, as a result of calling reset, or if a store is removed from the the persistent
    // store coordinator.) When this happens, NSFetchedResultsController does not invalidate all objects,
    // nor does it send individual notifications for object deletions. Instead, you must call performFetch:
    // to reset the state of the controller then reload the data in the table view (reloadData).
    //
    //
    // Since we set fetchedResultsController to nil, the getter will automatically call performFetch:
    // when this property is referenced as a result of a table reload.
    
    
    // Call reloadData to reload the table view data
    [self.tableView reloadData];
    
}



// Present the EnterApiKeyController to get the API key and store to Keychain.
- (void)requestNewAPIKey
{
    UIStoryboard *storyboard = self.storyboard;
    
    EnterApiKeyController *enterKeyViewController = (EnterApiKeyController *)[storyboard instantiateViewControllerWithIdentifier:@"EnterApiKeyControllerId"];
    
    enterKeyViewController.delegate = self;
    
    
    // We need to present the EnterApiKeyController from the visible controller.  Otherwise
    // we will get the warning:
    //
    // "Presenting view controllers on detached view controllers is discouraged"
    //
    // Where might this be an issue?  Consider the case where we select a bucket and begin
    // a replace segue to Detail View Controller.  In prepareForSegue we make a call to
    // load contacts from Contactually and get an error which causes us to logout.  The
    // logout causes us to call this method and present EnterApiKeyController, but we
    // have already transitioned to Detail view controller.
    //
    //
    // Either Master VC (if split view expanded) or currently active VC (if split view collapsed)
    UIViewController *presentingVC = [[self.splitViewController.viewControllers firstObject] topViewController];
    
    [presentingVC presentViewController:enterKeyViewController animated:YES completion:nil];
}



@end






