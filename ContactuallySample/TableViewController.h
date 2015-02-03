//
//  TableViewController.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/17/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ContactuallyConnection.h"



@interface TableViewController : UITableViewController


# pragma mark Properties initialized in subclass

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



// Our model of the Contactually service
@property (strong, nonatomic) ContactuallyConnection *contactuallyConnection;


// Cache used by NSFetchedResultsController
@property (strong, nonatomic) NSString *fetchedResultsCacheName;


// Entity name used by NSFetchedResultsController
@property (strong, nonatomic) NSString *entityName;

// Sort field name used by NSFetchedResultsController
@property (strong, nonatomic) NSString *sortFieldName;


@end
