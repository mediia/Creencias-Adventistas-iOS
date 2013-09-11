//
//  DetailViewController.h
//  Himnario Adventista
//
//  Created by Daniel Scholtus on 24/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic) NSIndexPath *dataItem;

@property (weak, nonatomic) IBOutlet UITextView *detailContentTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailTitleLabel;

@end
