//
//  Data.h
//  Himnario Adventista
//
//  Created by Daniel Scholtus on 25/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;

+ (NSArray *)items;
+ (Data *)item:(NSIndexPath *)position;

+ (int)sections;
+ (int)itemsInSection:(int)section;
+ (NSString *)titleForSection:(int)section;


@end