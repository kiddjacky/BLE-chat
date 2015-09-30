//
//  blockVC.m
//  app
//
//  Created by kiddjacky on 9/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "blockVC.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"

@interface blockVC ()

@end

@implementation blockVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Block User";
   	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self
                                                                            action:@selector(actionCancel)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self
                                                                             action:@selector(actionDone)];
    
    
    //self.userlist = [[NSMutableArray alloc] init];
    //self.selection = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //if (!self.managedObjectContext) [self useDocument];
    //[users removeAllObjects];
    NSLog(@"user list in block view is %@", self.userlist);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //if ([self.selection count] == 0) { [ProgressHUD showError:@"No user is blocked"]; return; }
    [self dismissViewControllerAnimated:YES completion:^{
        if (delegate != nil)
        {
            NSLog(@"selection is %@", self.selection);
            [delegate blockUser:self.selection];
        }
    }];


}

#pragma mark - Table view data source
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [self.userlist count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    //PFUser *user = users[indexPath.row];
    //cell.textLabel.text = user[PF_USER_FULLNAME];
    NSString *name = self.namelist[indexPath.row];
    NSString *userName = self.userlist[indexPath.row];
    cell.textLabel.text = name;

    BOOL selected = [self.selection containsObject:userName];
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    //PFUser *user = users[indexPath.row];
    NSString *userName = self.userlist[indexPath.row];
    
    BOOL selected = [self.selection containsObject:userName];
    if (selected) [self.selection removeObject:userName]; else [self.selection addObject:userName];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self.tableView reloadData];
}

@end
