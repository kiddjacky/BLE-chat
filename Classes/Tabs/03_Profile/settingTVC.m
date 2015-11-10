//
//  settingTVC.m
//  app
//
//  Created by kiddjacky on 10/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "settingTVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "ProfileView.h"
#import "contactsCell.h"
#import "utilities.h"
#import "pushnotification.h"
#import "DatabaseAvailability.h"
#import "ChatView.h"
#import "messages.h"
#import "privacy.h"


@interface settingTVC ()
{
    bool select;
}
@end

@implementation settingTVC

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_profile"]];
        self.tabBarItem.title = @"Setting";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Setting";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    select = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"contactsCell" bundle:nil] forCellReuseIdentifier:@"contactsCell"];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        [self.tableView reloadData];
    }
    else LoginUser(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 4;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return (section==0) ? 1 : ((section==1) ? 2 : 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        contactsCell *cell = (contactsCell *)[tableView dequeueReusableCellWithIdentifier:@"contactsCell" forIndexPath:indexPath];
        
        if (cell == nil) {
            
            //cell = [[discoversCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discoversCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"contactsCell" forIndexPath:indexPath];
        }
        PFUser *user = [PFUser currentUser];
        cell.userFullName.text = user[PF_USER_FULLNAME];
        cell.localDateTime.text = user[PF_USER_SELF_DESCRIPTION];
        [cell bindData:[PFUser currentUser]];
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        if (indexPath.row==0) {
            cell.textLabel.text = @"Privacy Policy";
        }
        if (indexPath.row==1) {
            cell.textLabel.text = @"Report";
        }
        return cell;
    }
    else if (indexPath.section== 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.textLabel.text = @"Disable Discover";
        cell.accessoryType = select ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        return cell;
        
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.textLabel.text = @"Log out";
        return cell;
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (indexPath.section == 0) {
        ProfileView *pv = [[ProfileView alloc] initWithNibName:nil bundle:nil];
        
        pv.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:pv animated:YES];
    }
    else if (indexPath.section==1) {
        if (indexPath.row==0) {
            privacy *pv = [[privacy alloc] initWithNibName:@"Privacy Policy" bundle:nil];
            pv.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pv animated:YES];
        }
        if (indexPath.row==1) {
        PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query whereKey:PF_USER_USERNAME equalTo:@"admin@bluewhalechat.com"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if ([objects count] != 0)
             {
                 PFUser *user1 = [PFUser currentUser];
                 PFUser *user2 = [objects firstObject];
                 NSString *groupId = StartPrivateChat(user1, user2);
                 ChatView *chatView = [[ChatView alloc] initWith:groupId];
                 chatView.hidesBottomBarWhenPushed = YES;
                 [self.navigationController pushViewController:chatView animated:YES];
             }
             else {
                 [ProgressHUD showError:@"Admin error."];
             }
         }];
        }
    }
    else if (indexPath.section == 2) {
        select = !select;
        if (select) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_DISABLE object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_ENABLE object:nil];
        }
        [self.tableView reloadData];
    }
    else if (indexPath.section==3) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Log out", nil];
        [action showFromTabBar:[[self tabBarController] tabBar]];
    }

}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section==0) ? 70.0f : 40.0f ;
}

#pragma logout

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Log out", nil];
    [action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        [PFUser logOut];
        ParsePushUserResign();
        PostNotification(NOTIFICATION_USER_LOGGED_OUT);
        //[self actionCleanup];
        [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        LoginUser(self);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
