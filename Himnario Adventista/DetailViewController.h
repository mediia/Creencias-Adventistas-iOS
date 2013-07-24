//
//  DetailViewController.h
//  Himnario Adventista
//
//  Created by Daniel Scholtus on 24/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
