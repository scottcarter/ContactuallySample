//
//  EnterApiKeyController.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//


@protocol EnterApiKeyControllerDelegate <NSObject>

- (void)dismissEnterApiKeyController:(NSArray *)buckets;

@end


@interface EnterApiKeyController : UIViewController

@property (weak, nonatomic) id<EnterApiKeyControllerDelegate> delegate;

@end
