//
//  blockVC.m
//  app
//
//  Created by kiddjacky on 9/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "blockVC.h"

@interface blockVC ()

@end

@implementation blockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Block User";
   	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self
                                                                            action:@selector(actionCancel)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.userlist = [[NSMutableArray alloc] init];
    self.selection = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    //PFUser *user = users[indexPath.row];
    //cell.textLabel.text = user[PF_USER_FULLNAME];
    NSString *name = self.userlist[indexPath.row];
    cell.textLabel.text = self.userlist[indexPath.row];

    BOOL selected = [self.selection containsObject:name];
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


@end
