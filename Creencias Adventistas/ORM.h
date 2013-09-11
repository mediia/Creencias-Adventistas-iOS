//
//  ORM.h
//  Creencias Adventistas
//
//  Created by Daniel Scholtus on 28/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORM : NSManagedObject

+ (void)saveContext;

+ (ORM *)factory:(NSString *)entity;

+ (ORM *)factory:(NSString *)entity withValues:(NSDictionary *)values;

+ (ORM *)factory:(NSString *)entity at:(NSIndexPath *)indexPath;

+ (void)setFetchedResultsControllerDelegate:(id)delegate forEntity:(NSString *)entity;

+ (int)sectionsForEntity:(NSString *)entity;

+ (int)entities:(NSString *)entity forSection:(NSInteger)section;

+ (void)prefillDatabase;

@end
