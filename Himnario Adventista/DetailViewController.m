//
//  DetailViewController.m
//  Himnario Adventista
//
//  Created by Daniel Scholtus on 24/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import "DetailViewController.h"

#import "Data.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

@synthesize dataItem;
@synthesize detailTitleLabel;
@synthesize detailContentTextView;

- (void)setDataItem:(NSIndexPath *)newDataItem {
    if (dataItem != newDataItem) {
        dataItem = newDataItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (dataItem) {
        Data *lItem = [Data item:dataItem];
        detailTitleLabel.title = lItem.title;
        detailContentTextView.text = lItem.content;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Lista", @"Lista");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
