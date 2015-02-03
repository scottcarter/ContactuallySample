//
//  MasterViewController.h
//  ContactuallySample
//
//  Created by Scott Carter on 1/16/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "TableViewController.h"


@class DetailViewController;

@interface MasterViewController : TableViewController


@property (strong, nonatomic) DetailViewController *detailViewController;


@end

