//
//  DisplayApiKeyController.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//


@protocol DisplayApiKeyControllerDelegate <NSObject>

- (void)dismissDisplayApiKeyController;

@end


@interface DisplayApiKeyController : UIViewController


@property (weak, nonatomic) id<DisplayApiKeyControllerDelegate> delegate;

@end
