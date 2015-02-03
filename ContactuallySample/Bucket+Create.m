//
//  Bucket+Create.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "Bucket+Create.h"

#import "Project.h"
#import "Types.h"

@implementation Bucket (Create)


+ (Bucket *)addBucketWithIdentifier:(NSNumber *)identifierNum
                               name:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context
                              error:(NSError **)error
{
    Bucket *bucket = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bucket"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [identifierNum integerValue]];
    
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"?" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    if(fetchError) {
        if(error != NULL){
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Core Data fetch failed", @""),
                                              NSUnderlyingErrorKey : fetchError};
            *error = [[NSError alloc] initWithDomain:CoreDataErrorDomain code:CoreDataFetchError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        return nil;
    }
    
    
    // We expect matches to be non NULL and have no entries.
    if (!matches || ([matches count] != 0)) {
        if(error != NULL){
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Wrong number of Core data matches", @"")};
            *error = [[NSError alloc] initWithDomain:ApplicationErrorDomain code:wrongNumberCoreDataMatchesError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        return nil;
    }
    
    else  {
        bucket = [NSEntityDescription insertNewObjectForEntityForName:@"Bucket" inManagedObjectContext:context];
        
        bucket.identifier = identifierNum;
        bucket.name = name;
        bucket.contactsLoaded = @NO;
    }
    
    
    return bucket;
}


@end
