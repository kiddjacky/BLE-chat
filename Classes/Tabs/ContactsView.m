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
    NSLog(@"about to fetch contacts!" );
    
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
    [self.tableView registerNib:[UINib nibWithNibName:@"contactsCell" bundle:nil] forCellReuseIdentifier:@"contactsCell"];

    //if (!self.managedObjectContext) [self useDocument];
    //[self setupFetchedResultsController];
    
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
        //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
        [self loadContacts];
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
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
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
             
             PFUser *user = [objects firstObject];
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
             }];
         }
     }];

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

#pragma mark - UIManagedDocument
- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"BLE_Document"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  //[self refresh];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}


@end
