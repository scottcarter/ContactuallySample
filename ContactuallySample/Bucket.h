//
//  Bucket.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/18/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Bucket : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * contactsLoaded;
@property (nonatomic, retain) NSSet *contact;
@end

@interface Bucket (CoreDataGeneratedAccessors)

- (void)addContactObject:(Contact *)value;
- (void)removeContactObject:(Contact *)value;
- (void)addContact:(NSSet *)values;
- (void)removeContact:(NSSet *)values;

@end
