//
//  ContactuallyConnection.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "ContactuallyConnection.h"

#import "Project.h"



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Private Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
@interface ContactuallyConnection ()

// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark Properties

@property (strong, nonatomic) NSString *apiKey;

@property (strong, nonatomic) NSURLSession *defaultSession;


@end



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@implementation ContactuallyConnection

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines

// None



// ==========================================================================
// Getters and Setters
// ==========================================================================
//
#pragma mark -
#pragma mark Getters and Setters

// None



// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations

- (void)dealloc
{
    // PLOG_TOP("ContactuallyConnection dealloc")

}


- (void)freeMemory
{
    
    // NSURLSession class documentation:
    // "The session object keeps a strong reference to the delegate until your app explicitly
    // invalidates the session. If you do not invalidate the session by calling the
    // invalidateAndCancel or resetWithCompletionHandler: method, your app leaks memory."
    //
    [self.defaultSession invalidateAndCancel];
}



- (id)init {
    
    // If a class can’t be fully initialized by plain init, it is supposed to raise an exception in init.
    EXCEPTION_LOG("CoreDataConnection can't be fully initialized with init.  Use initWithCoreDataManagedDocument")
    
    self = [super init];
    
    if (self) {
        // Initialize self.
    }
    
    return self;
}


- (id)initWithAPIKey:(NSString *)apiKey
{

    self = [super init];
    
    if (self) {
        // Initialize self.
        self.apiKey = apiKey;
        
        // NLOG("Initializing with apiKey %@",self.apiKey)
        
        [self initializeSession];
    }
    
    return self;
}


- (void)initializeSession
{
    //
    // Session Configuration
    //
    // Note: With the exception of background configurations, you can reuse session configuration objects
    // to create additional sessions.
    //
    
    
    // NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // We use an ephemeralSessionConfiguration instead of defaultSessionConfiguration that
    // uses no persistent storage for caches, cookies, or credentials.  This will cause the API key to be required
    // on every access.
    //
    // Alternatively we could have used defaultSessionConfiguration and set defaultConfigObject.HTTPShouldSetCookies = NO
    //
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // Best practice recommends adding a User-Agent header
    [defaultConfigObject setHTTPAdditionalHeaders:@{@"User-Agent": @"Scott Carter Exercise"}];
    
    
    //PLOG_TOP("Additional headers to send: %@",[defaultConfigObject HTTPAdditionalHeaders])
    

    // What size for memory and disk cache?  Tens of Mbytes for disk cache said to be ok by Apple:
    // NSURLCache Class Reference:
    // "The returned NSURLCache is backed by disk, so developers can be more liberal with space when
    // choosing the capacity for this kind of cache. A disk cache measured in the tens of megabytes
    // should be acceptable in most cases."
    //
    // See also:
    // http://twobitlabs.com/2012/01/ios-ipad-iphone-nsurlcache-uiwebview-memory-utilization/
    //
    //    NSUInteger cacheSizeMemory = 4*1024*1024; // 4MB
    //    NSUInteger cacheSizeDisk = 32*1024*1024; // 32MB
    //    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"foobar"];
    
    // We won't be using a cache for now
    defaultConfigObject.URLCache = NULL; // myCache;
    //defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    // Create a session for configuration.
    //
    // Note that we do not need to assign a delegate if we use a completion callback.
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
}





// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods


// None



// ==========================================================================
// Class methods
// ==========================================================================
//
#pragma mark -
#pragma mark Class methods

// None

// ==========================================================================
// Instance methods
// ==========================================================================
//
#pragma mark -
#pragma mark Instance methods


- (void)getBucketsWithCompletion:(contactuallyConnectionBuckets_completionBlock_t)completionBlock
{
    
    // Make call to get groups of type "bucket"
    
    NSString *endpoint = @"groupings.json";
    NSString *params = @"&type=bucket";
    
    [self getContactually:endpoint params:params completionBlock:^(BOOL success, NSError *error, NSDictionary *jsonDict, NSURLResponse *response) {
        
        if(success){
            // NLOG("buckets=%@",jsonDict)
            
            // On success the jsonDict will contain a field for groupings.
            /*
             groupings = (
                 {
                     id = 34347685;
                     name = Top Contacts";
                     ...
                 }
                 ...
             )
             
             */
            
            
            completionBlock(success, error, jsonDict[@"groupings"]);
        }
        else {
            completionBlock(success, error, nil);
        }
        
    }];
     
}



// Get array of contacts
- (void)getContactsForBucketId:(NSNumber *)bucketIdNum
                WithCompletion:(contactuallyConnectionContacts_completionBlock_t)completionBlock
{

    // Make call to return information about contacts for selected bucket
    
    NSString *endpoint = @"contacts.json";
    
    NSString *params = [NSString stringWithFormat:@"&grouping_id=%ld",(long)[bucketIdNum integerValue]];
    
    [self getContactually:endpoint params:params  completionBlock:^(BOOL success, NSError *error, NSDictionary *jsonDict, NSURLResponse *response) {
        
        if(success){
            // NLOG("contacts=%@",jsonDict)
            
            // On success the jsonDict will contain a field for contacts
            /*
             contacts =     (
                 {
                     id = 145250053;
                     "first_name = "...";
                     "last_name=" = "...";
                 }
             );
             */
            
            completionBlock(success, error, jsonDict[@"contacts"]);
            
        }
        else {
            completionBlock(success, error, nil);
        }
        
    }];

}



// Make a GET API call to Contactually
//
// The versioned base is defined in Project.h as CONTACTUALLY_API_BASE (Ex: /api/v1/)
// The operation is the action to perform (Ex: groupings.json) and is appended to the base.
// Params are added after the API key (Ex: &param1=value1&param2=value2)
//
- (void)getContactually:(NSString *)operation
                 params:(NSString *)params
         completionBlock:(contactuallyConnection_completionBlock_t)completionBlock
{
    
    // Form the API URL including the API Key.
    NSString *apiPath = [NSString stringWithFormat:@"%@%@?api_key=%@", CONTACTUALLY_API_BASE,operation,self.apiKey];
    if(params){
        apiPath = [apiPath stringByAppendingString:params];
    }
    //NLOG("apiPath = %@",apiPath)

    NSURL *url = [NSURL URLWithString:apiPath];
    
    [[self.defaultSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *dataTaskError) {
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        PLOG_TOP("Got response=%@  error=%@  status code=%ld  jsonDict=%@\n", response, dataTaskError, (long)statusCode, jsonDict)
        
        
        NSError *error = nil;
        
        
        // Report errors using our defined domains
        if(statusCode != 200){
            
            NSDictionary *errorDictionary;
            if(dataTaskError){
                errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"dataTaskWithURL failed", @""),
                                              NSUnderlyingErrorKey : dataTaskError};
            }
            else {
                errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error response from Contactually", @"")};
            }
            
            NSError *error = [[NSError alloc] initWithDomain:ContactuallyErrorDomain code:statusCode userInfo:errorDictionary];
            ERROR_LOG("%@",error)
            
            completionBlock(NO, error, jsonDict, response);
            return;
        }
        
        
        completionBlock(YES, error, jsonDict, response);

        
    }] resume];
    
}




// ==========================================================================
// C methods
// ==========================================================================
//


#pragma mark -
#pragma mark C methods





@end











