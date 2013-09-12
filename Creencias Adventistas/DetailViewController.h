//
//  DetailViewController.h
//  Creencias Adventistas
//
//  Created by Daniel Scholtus on 28/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITextView *detailDescriptionTextView;

@end
