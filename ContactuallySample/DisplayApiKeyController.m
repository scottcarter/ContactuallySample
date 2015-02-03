//
//  DisplayApiKeyController.m
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "DisplayApiKeyController.h"


@interface DisplayApiKeyController()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DisplayApiKeyController


// Call our delegate to dismiss this view controller
- (IBAction)closeAction:(UIButton *)sender {
    [self.delegate dismissDisplayApiKeyController];
}

// Load the Contactually web page to find the API key.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    NSURL *url = [NSURL URLWithString:@"https://www.contactually.com/settings/integrations"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}


@end
