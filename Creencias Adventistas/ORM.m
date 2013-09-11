//
//  ORM.m
//  Creencias Adventistas
//
//  Created by Daniel Scholtus on 28/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import "ORM.h"

@interface ORM () {
    
}

@end

@implementation ORM

static NSManagedObjectContext *sManagedObjectContext;
static NSManagedObjectModel *sManagedObjectModel;
static NSPersistentStoreCoordinator *sPersistentStoreCoordinator;
static NSMutableDictionary *sFetchedResultsControllers;

# pragma mark - Core Data Stack management

+ (void)initialize {
    
    // Document directory
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager]
                                             URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask] lastObject];
    
    // Managed Object Model
    NSURL *modelURL = [[NSBundle mainBundle]
                       URLForResource:@"Creencias_Adventistas"
                       withExtension:@"momd"];
    sManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // Persistent Store Coordinator
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Creencias_Adventistas.sqlite"];
    
    NSError *error = nil;
    sPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:sManagedObjectModel];
    if (![sPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        /*
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path.
         Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Managed Object Context
    sManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [sManagedObjectContext setPersistentStoreCoordinator:sPersistentStoreCoordinator];
    
    [ORM prefillDatabase];
}

+ (void)saveContext
{
    NSError *error = nil;
    if (sManagedObjectContext != nil) {
        if ([sManagedObjectContext hasChanges] && ![sManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

# pragma mark - Objects instantiation

+ (ORM *)factory:(NSString *)entity
{
    [ORM fetchedResultsControllerForEntity:entity];
    ORM *orm = [NSEntityDescription
                insertNewObjectForEntityForName:entity
                inManagedObjectContext:sManagedObjectContext];

    return orm;
}

+ (ORM *)factory:(NSString *)entity withValues:(NSDictionary *)values
{
    [ORM fetchedResultsControllerForEntity:entity];
    ORM *orm = [NSEntityDescription
                insertNewObjectForEntityForName:entity
                inManagedObjectContext:sManagedObjectContext];
    [orm setValuesForKeysWithDictionary:values];
    return orm;

}

+ (ORM *)factory:(NSString *)entity at:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    ORM *orm = [fetchedResultsController objectAtIndexPath:indexPath];
    return orm;
}

#pragma mark - Fetched Results Controllers Handling

+ (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString *)entity
{
    NSFetchedResultsController *fetchedResultsController = [sFetchedResultsControllers objectForKey:entity];
    if (fetchedResultsController) {
        // The Fetched Results Controller exists, no need to recreate
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entityDescription = [NSEntityDescription
                                   entityForName:entity
                                   inManagedObjectContext:sManagedObjectContext];
    
    [fetchRequest setEntity:entityDescription];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:28];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    fetchedResultsController = [[NSFetchedResultsController alloc]
                                initWithFetchRequest:fetchRequest
                                managedObjectContext:sManagedObjectContext
                                sectionNameKeyPath:@"section"
                                cacheName:@"Master"];
    
    [sFetchedResultsControllers setObject:fetchedResultsController  forKey:entity];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}

+ (void)setFetchedResultsControllerDelegate:(id)delegate forEntity:(NSString *)entity {
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    fetchedResultsController.delegate = delegate;
}

#pragma mark - Fetched Results Controllers querying

/** Get the sections count */
+ (int)sectionsForEntity:(NSString *)entity
{
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    
    return [[fetchedResultsController sections] count];
}

/** Get the entities count for a section */
+ (int)entities:(NSString *)entity forSection:(NSInteger)section
{
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    
    return [[fetchedResultsController sections][section] numberOfObjects];

}

# pragma mark - Database prefilling

+ (void)prefillDatabase
{
    if ([ORM sectionsForEntity:@"Belief"] == 0) {
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @0,
         @"section" : @0,
         @"title" : @"Doctrina de Dios",
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Palabra de Dios",
         @"content" : @"Test successful!",
         @"section" : @0,
         @"index" : @0,
         }];
    }
}
@end
