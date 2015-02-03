//
//  Bucket+Create.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "Bucket.h"

@interface Bucket (Create)

+ (Bucket *)addBucketWithIdentifier:(NSNumber *)identifierNum
                               name:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context
                              error:(NSError **)error;

@end
