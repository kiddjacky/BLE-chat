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

#import "Contacts.h"
#import "contactDetailsVC.h"

@implementation ContactsView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Get Contact database notification");
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
    if (self)
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"contact-icon"]];
        self.tabBarItem.title = @"Contacts";
    }
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
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:@"firstLetter"
                                                                                   cacheName:@"MyCache"];
    
    
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Contacts";
    self.tableView.tableFooterView = [[UIView alloc] init];
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
        //[self loadContacts];
    }
    else LoginUser(self);
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
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - table view


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    
    Contacts *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = contact.userFullName;
    cell.detailTextLabel.text = contact.selfDescription;
        NSLog(@"update contacts view, first letter %@",contact.firstLetter);
    if (contact.thumbnail != nil) {
    cell.imageView.image = [UIImage imageWithData:contact.thumbnail];
    }
    /*
    cell.imageView.image = [UIImage imageWithData:contact.thumbnail];
    if (!cell.imageView.image) {
        dispatch_queue_t q = dispatch_queue_create("Thumbnail Contact Photo", 0);
        dispatch_async(q, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:contact.thumbnailURL]];
            [self.managedObjectContext performBlock:^{
                contact.thumbnail = imageData;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setNeedsLayout];
                });
            }];
        });
    }
    */
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contacts *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    contactDetailsVC *ivc = [[contactDetailsVC alloc] init];
    ivc.contact = contact;
    [self.navigationController pushViewController:ivc animated:YES];
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
