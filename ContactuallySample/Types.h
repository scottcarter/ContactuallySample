//
//  Types.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#ifndef ContactuallySample_Types_h
#define ContactuallySample_Types_h


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ContactuallyConnection
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//

typedef void (^contactuallyConnection_completionBlock_t)(BOOL success, NSError *error, NSDictionary *jsonDict, NSURLResponse *response);

typedef void(^contactuallyConnectionBuckets_completionBlock_t)(BOOL success, NSError *error, NSArray *buckets);

typedef void(^contactuallyConnectionContacts_completionBlock_t)(BOOL success, NSError *error, NSArray *contacts);


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Error codes for our custom NSError objects
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Error domains in Project.h


// CoreDataErrorDomain
//

typedef enum : NSUInteger {
    CoreDataDatabaseCorrupt,
    CoreDataFetchError,
    CoreDataObtainPermanentIdError,
    CoreDataSaveDocumentError,
    CoreDataRemovePersistentStoreError,
    CoreDataRemovePersistentStoreFileError,
    CoreDataAddPersistentStoreError,
    CoreDataObtainPermanentIDsForObjectsError
} CoreDataError;



// ApplicationErrorDomain
//
typedef enum : NSUInteger {
    ApplicationFailed,
    wrongNumberCoreDataMatchesError,
} ApplicationError;



#endif
