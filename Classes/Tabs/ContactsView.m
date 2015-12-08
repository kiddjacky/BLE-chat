//
//  ContactsView.m
//  app
//
//  Created by kiddjacky on 5/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "ContactsView.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "DatabaseAvailability.h"
#import "utilities.h"
#import "contactsCell.h"

#import "Contacts.h"
#import "contactDetailsVC.h"

@interface ContactsView()
{
    UIView *nomatchesView;
}
@end

@implementation ContactsView

/*
-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Get Contact database notification");
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
}
*/

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"contact-icon"]];
        self.tabBarItem.title = @"Contacts";
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Get Contact database notification");
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contacts"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"userFullName"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    
    //NSLog(@"Discover set managed object context %@", managedObjectContext);
    //NSLog(@"about to fetch contacts!" );
    //NSError *error;
    //NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"contact now is %lu", (unsigned long)[matches count]);
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:@"firstLetter"
                                                                                   cacheName:nil];
    
    
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Contacts";
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"contactsCell" bundle:nil] forCellReuseIdentifier:@"contactsCell"];

    //if (!self.managedObjectContext) [self useDocument];
    //[self setupFetchedResultsController]

    
    //add subview when no match
    nomatchesView = [[UIView alloc] initWithFrame:self.view.frame];
    nomatchesView.backgroundColor = [UIColor clearColor];
    
    UILabel *matchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,320)];
    matchesLabel.font = [UIFont boldSystemFontOfSize:18];
    //matchesLabel.minimumFontSize = 12.0f;
    matchesLabel.numberOfLines = 1;
    //matchesLabel.lineBreakMode = UILineBreakModeWordWrap;
    //matchesLabel.shadowColor = [UIColor lightTextColor];
    matchesLabel.textColor = [UIColor lightGrayColor];
    matchesLabel.shadowOffset = CGSizeMake(0, 1);
    matchesLabel.backgroundColor = [UIColor clearColor];
    matchesLabel.textAlignment =  NSTextAlignmentCenter;
    
    //Here is the text for when there are no results
    matchesLabel.text = @"You don't have any contact yet";
    
    
    nomatchesView.hidden = YES;
    [nomatchesView addSubview:matchesLabel];
    [self.tableView insertSubview:nomatchesView belowSubview:self.tableView];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        if ([[PFUser currentUser][PF_USER_IS_BLACK_LIST] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            LoginUser(self);
        } else {
        //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
        [self loadContacts];
        }
    }
    else LoginUser(self);
}

-(void) loadContacts
{
    //[self reloadData];
}


- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - table view


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    contactsCell *cell = (contactsCell *)[tableView dequeueReusableCellWithIdentifier:@"contactsCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        //cell = [[discoversCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discoversCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"contactsCell" forIndexPath:indexPath];
    }
    

    
    
    Contacts *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.userFullName.text = contact.userFullName;
    cell.localDateTime.text = contact.selfDescription;
    NSLog(@"update contacts view, first letter %@",contact.firstLetter);
    /*
    if (contact.thumbnail != nil) {
    cell.imageView.image = [UIImage imageWithData:contact.thumbnail];
    }
    */
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:contact.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             PFUser *pfuser = [objects firstObject];
             if (pfuser[PF_USER_THUMBNAIL] == nil)
             {
                 UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
                 //UIImage *def_image = [UIImage imageNamed:@"profile_blank@2x.png"];
                 cell.imageUser.image = def_image;
                 
             } else {
                 [cell bindData:pfuser];
             }
             /*
             PFFile *contactThumbnail = user[PF_USER_THUMBNAIL];
             [contactThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                 //NSLog(@"in the block");
                 if(!error) {
                     //NSLog(@"no error!");
                     UIImage *image = [UIImage imageWithData:data];
                     NSLog(@"load contact %@ image ", contact.userFullName);
                     cell.imageUser.image = image;
                     //dispatch_async(dispatch_get_main_queue(), ^{ NSLog(@"in main queue, load cell image");
                     //    cell.imageUser.image = image; });
                 }
             }];*/
         }
     }];

     return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contacts *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    contactDetailsVC *ivc = [[contactDetailsVC alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:contact.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             
             PFUser *user = [objects firstObject];
             contact.userFullName = user[PF_USER_FULLNAME];
             contact.sex = user[PF_USER_SEX];
             contact.interest = user[PF_USER_INTEREST];
             contact.selfDescription = user[PF_USER_SELF_DESCRIPTION];
             ivc.contact = contact;
             [self.navigationController pushViewController:ivc animated:YES];
         }
     }];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFUser *user = [PFUser currentUser];
        Contacts *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self.fetchedResultsController.managedObjectContext deleteObject:contact];
    
    
    
    NSMutableArray *contactList = user[PF_USER_CONTACTS];
    NSLog(@"old contact list is %@", contactList);
    [contactList removeObject:contact.userName];
        NSLog(@"new contact list is %@", contactList);
    user[PF_USER_CONTACTS] = contactList;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [ProgressHUD showSuccess:@"Delete Contact!"];
         }
         else [ProgressHUD showError:@"Network error."];
     }];
}


#pragma mark - Table view delegate
-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    Contacts *user_contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[contactDetailsVC class]]) {
        contactDetailsVC *dv = (contactDetailsVC *)vc;
        dv.contact = user_contact;
 //    NSLog(@"debug prepare = %@", dv.discoverUser.userName);
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}



@end
