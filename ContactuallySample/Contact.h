//
//  Contact.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/18/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bucket;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSSet *bucket;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addBucketObject:(Bucket *)value;
- (void)removeBucketObject:(Bucket *)value;
- (void)addBucket:(NSSet *)values;
- (void)removeBucket:(NSSet *)values;

@end
