//
//  MasterViewController.m
//  Himnario Adventista
//
//  Created by Daniel Scholtus on 24/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "Data.h"

@implementation MasterViewController

// OnResume()
- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

// OnViewCreated()
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

#pragma mark - Table View
// Le dice a la tabla la cantidad de secciones (opcional)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int lSections = [Data sections];
    return lSections;
}

// Le dice a la tabla la cantidad de items de la sección del argumento
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int lItems = [Data itemsInSection:section];
    return lItems;
}

// Le da a la tabla el contenido del elemento en la posición solicitada.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Data *lItem = [Data item:indexPath];
    cell.textLabel.text = lItem.title;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *lTitle = [Data titleForSection:section];
    return lTitle;
}

// En tablets, simplemente se asocia el nuevo item al controller de detalle que es una propiedad de este controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController.dataItem = indexPath;
    }
}

// En teléfonos, se obtiene el controller de lo que sería el intent
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController setDataItem:indexPath];
    }
}

@end
