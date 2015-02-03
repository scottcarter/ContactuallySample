//
//  EnterApiKeyController.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "EnterApiKeyController.h"

#import "Project.h"

#import "DisplayApiKeyController.h"

#import "ContactuallyConnection.h"

#import "KeychainHelper.h"


@interface EnterApiKeyController () <DisplayApiKeyControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

// Our model of the Contactually service
@property (strong, nonatomic) ContactuallyConnection *contactuallyConnection;

@end



@implementation EnterApiKeyController

NSString *const ApiKey = @"replace_with_your_api_key";


- (void)dealloc
{
    // PLOG_TOP("EnterApiKeyController dealloc")
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField.text = @"";
    
    self.textField.placeholder = @"Enter 32 character API Key";
    
    
}


// Set ourselves as the delegage for DisplayApiKeyController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[DisplayApiKeyController class]]){
        DisplayApiKeyController *displayApiKeyController = (DisplayApiKeyController *)segue.destinationViewController;
        displayApiKeyController.delegate = self;
    }
    
}


// Use hard coded value for Api Key
- (IBAction)hardCodedKeyAction:(UIButton *)sender {
    self.textField.text = ApiKey;
}


// User submitted an API Key
- (IBAction)submitKeyAction:(UIButton *)sender {
    
    NSString *apiKey = self.textField.text;
    
    // PLOG_TOP("Verifying API key %@", apiKey)
    
    // API Key should be 32 characters - http://developers.contactually.com/
    if ([apiKey length] != 32) {
        self.textField.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid API Key" message:@"Re-enter API key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    

    // We will make a call to Contactually to verify and then store the key in the iOS Keychain on success
    // (more secure than storing in NSUserDefaults)
    //
    if(!_contactuallyConnection){
        self.contactuallyConnection = [[ContactuallyConnection alloc] initWithAPIKey:apiKey];
    }
  
    
    
    // Make call to get buckets
    [self.contactuallyConnection getBucketsWithCompletion:^(BOOL success, NSError *error, NSArray *buckets) {
        
        if(success){
            
            // Store API Key
            [KeychainHelper setPassword:apiKey forKey:KEYCHAIN_API_KEY];
            
            [self.contactuallyConnection freeMemory];  // Invalidate the session before we are dismissed.
            self.contactuallyConnection = nil;
            
            [self.delegate dismissEnterApiKeyController:buckets]; // Request dismissal, return buckets.
        }
        else {
            
            // Key was not valid, so invalidate session
            [self.contactuallyConnection freeMemory]; 
            self.contactuallyConnection = nil;
            
            self.textField.text = @"";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error connecting to Contactually" message:@"Re-enter API key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
    
    
}


// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods



#pragma mark DisplayApiKeyControllerDelegate

// Dismiss the Web view once user has obtained and copied key.
- (void)dismissDisplayApiKeyController {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
