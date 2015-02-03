//
//  Project.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "Project.h"


// Define some constants that were declared in Project.h


// ++++++++++++++++++++++++++++++++++
// General project constants
// ++++++++++++++++++++++++++++++++++
//

NSString *const CONTACTUALLY_API_BASE = @"https://www.contactually.com/api/v1/";

NSString *const KEYCHAIN_API_KEY = @"ContactuallyAPIKey";


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Error domains for our custom NSError objects
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//

NSString *const ContactuallyErrorDomain = @"scarter.ContactuallySample.contactuallyErrorDomain";

NSString *const CoreDataErrorDomain = @"scarter.ContactuallySample.coreDataErrorDomain";

NSString *const ApplicationErrorDomain = @"scarter.ContactuallySample.applicationErrorDomain";


