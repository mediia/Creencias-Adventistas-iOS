//
//  MasterViewController.h
//  Himnario Adventista
//
//  Created by Daniel Scholtus on 24/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
