//
//  Creencia.h
//  Creencias Adventistas
//
//  Created by Daniel Scholtus on 28/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MasterViewController.h"

@interface Creencia : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;

+ (Creencia *)factory;

+ (NSFetchedResultsController *)fetchedResultsController;

+ (void)initFetchedResultsControllerDelegate:(MasterViewController *)delegate;

+ (void)insert:(id)title at:(id)index for:(id)section;

@end
