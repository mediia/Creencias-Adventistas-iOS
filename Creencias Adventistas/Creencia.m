//
//  Creencia.m
//  Creencias Adventistas
//
//  Created by Daniel Scholtus on 28/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import "Creencia.h"
#import "MasterViewController.h"

@implementation Creencia

@synthesize title;
@synthesize content;

static NSFetchedResultsController *fetchedResultsController;

+ (Creencia *)factory {
    return [Creencia alloc];
}

+ (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController) {
        return fetchedResultsController;
    }
    
    NSLog(@"Creencia::$fetchedResultsController not initialized.");
    abort();
}

+ (void)initFetchedResultsControllerDelegate:(MasterViewController *)delegate
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Belief"
                                   inManagedObjectContext:delegate.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:28];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:delegate.managedObjectContext
                                                             sectionNameKeyPath:@"doctrine"
                                                             cacheName:@"New"];
    aFetchedResultsController.delegate = delegate;
    fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
}

+ (void)insert:(id)title at:(id)index for:(id)section
{
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription
                                         insertNewObjectForEntityForName:[entity name]
                                         inManagedObjectContext:context];

    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    
    [newManagedObject setValue:section forKey:@"section"];
    [newManagedObject setValue:index forKey:@"index"];
    [newManagedObject setValue:title forKey:@"title"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
