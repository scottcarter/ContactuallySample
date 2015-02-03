//
//  Contact+Create.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "Contact+Create.h"

#import "Project.h"
#import "Types.h"


@implementation Contact (Create)

+ (Contact *)findOrAddContactWithIdentifier:(NSNumber *)identifierNum
                          first_name:(NSString *)first_name
                           last_name:(NSString *)last_name
              inManagedObjectContext:(NSManagedObjectContext *)context
                               error:(NSError **)error
{
    Contact *contact = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [identifierNum integerValue]];
    
    // Doesn't really matter how we sort this, since we should only be getting back 0 or 1 of these.
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
    
    
    // We expect matches to be non NULL and have 0 or 1 entries.
    if (!matches || ([matches count] > 1)) {
        if(error != NULL){
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Wrong number of Core data matches", @"")};
            *error = [[NSError alloc] initWithDomain:ApplicationErrorDomain code:wrongNumberCoreDataMatchesError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        return nil;
    }
    
    else if ([matches count] == 0) {
        contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        
        contact.identifier = identifierNum;
        contact.first_name = first_name;
        contact.last_name = last_name;
    }
    
    else {
        contact = [matches lastObject];
    }
    
    return contact;
}



@end
