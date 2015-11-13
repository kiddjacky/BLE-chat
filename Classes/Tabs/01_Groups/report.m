//
//  report.m
//  app
//
//  Created by kiddjacky on 11/8/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "report.h"

@interface report ()

@end

@implementation report

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Setting";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = @"The content contains violence or pornography.";
        
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"The content violates copy rights.";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"It is a spam.";
    }
    else {
        cell.textLabel.text = @"It makes me uncomfortable.";
    }
    
    return cell;
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFUser *user = [PFUser currentUser];
    NSString *reason = @"";
    if (indexPath.row==0) {
        reason = @"The content contains violence or pornography.";
    }
    else if (indexPath.row == 1) {
        reason = @"The content violates copy rights.";
    }
    else if (indexPath.row == 2) {
        reason = @"It is a spam.";
    }
    else {
        reason = @"It makes me uncomfortable.";
    }
    if (self.group.objectId != nil) {
        if (user[PF_USER_BLOCKED_TOPICS]) {
            NSLog(@"block list is nil");
            [user[PF_USER_BLOCKED_TOPICS] addObject:self.group.objectId];
        }
        else {
            user[PF_USER_BLOCKED_TOPICS] = [[NSMutableArray alloc] init];
            [user[PF_USER_BLOCKED_TOPICS] addObject:self.group.objectId];
        }
        NSLog(@"block topic list is %@", user[PF_USER_BLOCKED_TOPICS]);
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
                 [ProgressHUD showSuccess:@"Thank you! We will investage, and have blocked this topic from your feed."];
                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                 params[@"id"] = self.group.objectId;
                 params[@"user"] = [PFUser currentUser].objectId;
                 params[@"reason"] = reason;
                 params[@"userName"] = [PFUser currentUser].username;
                 [PFCloud callFunctionInBackground:@"userReport" withParameters:params];
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
             else [ProgressHUD showError:@"Network error."];
         }];
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = @"Help us understand why you don't want to see this?";
    return sectionName;
}




@end
