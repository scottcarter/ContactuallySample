//
//  Contact+Create.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "Contact.h"

@interface Contact (Create)


+ (Contact *)findOrAddContactWithIdentifier:(NSNumber *)identifierNun
                           first_name:(NSString *)first_name
                            last_name:(NSString *)last_name
               inManagedObjectContext:(NSManagedObjectContext *)context
                                error:(NSError **)error;

@end
