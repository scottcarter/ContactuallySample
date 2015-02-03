//
//  DetailViewController.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "DetailViewController.h"

#import "Project.h"

#import "AppDelegate.h"

#import "Contact.h"


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Private Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
@interface DetailViewController ()

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
@implementation DetailViewController

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

// Setter for Bucket id
- (void)setBucketIdNum:(NSNumber *)bucketIdNum {
    
    if (_bucketIdNum != bucketIdNum) {
        _bucketIdNum = bucketIdNum;
    }
}



// ==========================================================================
// Actions
// ==========================================================================
//
#pragma mark -
#pragma mark Actions

// None



// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations


- (void)awakeFromNib {
    [super awakeFromNib];
    
    // PLOG_TOP("DetailViewController awakeFromNib  self=%@", self)
}




- (void)dealloc
{
    // PLOG_TOP("DetailViewController dealloc  self=%@", self)
    
    [self.contactuallyConnection freeMemory];  // Invalidate the session
    self.contactuallyConnection = nil;
    
    // Unregister from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    
    // PLOG_TOP("DetailViewController viewDidLoad  self=%@", self)
    
    
    // Initialize base class properties
    
    
    // Not using cache with Detail since we are frequently changing predicate (bucket selection)
    self.fetchedResultsCacheName = nil;
    
    self.entityName = @"Contact";
    self.sortFieldName = @"last_name";
    
    
    // Set managedObjectContext for base class.
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods

// None



// ==========================================================================
// Override base class methods
// ==========================================================================
//
#pragma mark -
#pragma mark Override base class methods



#pragma mark - Table View

// Need to override base class method
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = (Contact *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *first_name = contact.first_name;
    NSString *last_name = contact.last_name;
    
    NSString *name = [NSString stringWithFormat:@"%@, %@", last_name, first_name];
    
    cell.textLabel.text = name;
    
    // Use a text style that scales for Dynamic Text
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
}


#pragma mark NSFetchedResultsController


- (NSPredicate *)fetchPredicate
{
    // On an iPad, we need to make sure that bucket has been selected before attempting to
    // fetch contacts.   One way to do this is to use an invalid bucket identifier if
    // self.bucketIdNum not set.
    //
    NSNumber *bucketIdNum;
    if(self.bucketIdNum){
        bucketIdNum = self.bucketIdNum;
    }
    else {
        bucketIdNum = @-1;
    }
    
    // PLOG_TOP("fetchPredicate  bucketIdNum=%@  self=%@", bucketIdNum, self)
    
    // Article discusses options for many to many relationships in an NSPredicate.
    // http://stackoverflow.com/questions/4217849/core-data-nspredicate-for-many-to-many-relationship-to-many-key-not-allowed
    return [NSPredicate predicateWithFormat:@"bucket.identifier CONTAINS %@", bucketIdNum];
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

// None





@end
















