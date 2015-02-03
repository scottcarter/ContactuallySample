//
//  Project.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//
#ifndef ContactuallySample_Project_h
#define ContactuallySample_Project_h


// Introduce PROJECT_DEVELOPMENT macro (instead of relying on just DEBUG), so that we can
// test development or release environment (with appropriate changes to defines below).
//
// Define for PROJECT_DEVELOPMENT must come before Global.h import in order to override default there.

#ifdef DEBUG
#define PROJECT_DEVELOPMENT 1
#else
#define PROJECT_DEVELOPMENT 0
#endif

// If ENABLE_PRAGMA_FOR_FLOG is set to 1, we enable pragma messages for calls to FLOG
// so that they show up in Issues Navigator
#define ENABLE_PRAGMA_FOR_FLOG 0


// Import my global, project independent header file
#import "Global.h"




// +++++++++++++++++++++++++++++++++++++++++++
// Configuration macros
// +++++++++++++++++++++++++++++++++++++++++++
//



// ++++++++++++++++++++++++++++++++++
// General project constants
// ++++++++++++++++++++++++++++++++++
//
FOUNDATION_EXPORT NSString *const CONTACTUALLY_API_BASE;

FOUNDATION_EXPORT NSString *const KEYCHAIN_API_KEY;


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Error domains for our custom NSError objects
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//

// Error domains
// ============
// https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorObjectsDomains/ErrorObjectsDomains.html
//
// com.company.framework_or_app.ErrorDomain
//
// In my case, com.company is "scarter"
// scarter.ContactuallySample.ErrorDomain
//


FOUNDATION_EXPORT NSString *const ContactuallyErrorDomain;

FOUNDATION_EXPORT NSString *const CoreDataErrorDomain;

FOUNDATION_EXPORT NSString *const ApplicationErrorDomain;



// +++++++++++++++++++++++++++++++++++++++++++
// Project specific logging macros
// +++++++++++++++++++++++++++++++++++++++++++
//
// These work the same as NLOG, but are meant to be left in the code
// and enabled (by changing the definition) as needed for debug.  Each
// PLOG_X macro is specific to a certain functionality.  DSLOG (Debug Singleton log) can
// be added as desired.
//
// Set ENABLE_PRAGMA_FOR_FLOG to 1 to show FLOG calls in Issue Navigator
//


// Top level operations
// (used in multiple files)
//
//#define PLOG_TOP(...)
#define PLOG_TOP(FormatLiteral, ...)  FLOG("PLOG_TOP","PLOG_TOP", FormatLiteral, ##__VA_ARGS__)



#endif






