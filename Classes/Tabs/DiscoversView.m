//
//  DiscoversView.m
//  app
//
//  Created by kiddjacky on 3/22/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "DiscoversView.h"
#import "detailsView.h"
#import "DiscoverUser.h"
#import "discoversCell.h"


#import "DatabaseAvailability.h"

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DiscoversView()
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    UIView *nomatchesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------


@implementation DiscoversView
/*
 - (void)awakeFromNib
 {
 NSLog(@"load into the discover awakeFromNib");
 [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
 object:nil
 queue:nil
 usingBlock:^(NSNotification *note) {
 NSLog(@"Get database notification");
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
        [self.tabBarItem setImage:[UIImage imageNamed:@"Find_User-100"]];
        self.tabBarItem.title = @"Discovers";
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Get database notification");
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
    return self;
}


- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
    request.predicate = nil;
    
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeMeet"
                                                              ascending:NO]];
    
    
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    
    
}



//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"Discovers";
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self
    //                                                                         action:@selector(actionNew)];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.tableView.tableFooterView = [[UIView alloc] init];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSLog(@"into Discover view did load");
    geocoder = [[CLGeocoder alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"discoversCell" bundle:nil] forCellReuseIdentifier:@"discoversCell"];
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    
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
    matchesLabel.text = @"No Whaler around 200m of you";
    
    
    nomatchesView.hidden = YES;
    [nomatchesView addSubview:matchesLabel];
    [self.tableView insertSubview:nomatchesView belowSubview:self.tableView];
    
    //[self.tableView reloadData];
    //setup observer before ask the appdelegate to post
    //[[NSNotificationCenter defaultCenter] postNotificationName:DiscoverViewReady object:nil];
    //self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
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
        [self loadDiscovers];
        }
    }
    else LoginUser(self);
}

-(void) loadDiscovers //load discover people or ibeacon
{
    // [self reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
        if ([sectionInfo numberOfObjects] ==0 ) {
            nomatchesView.hidden = NO;
        }
        else {
            nomatchesView.hidden = YES;
        }
    }
    else {
        nomatchesView.hidden = NO;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    discoversCell *cell = (discoversCell *)[tableView dequeueReusableCellWithIdentifier:@"discoversCell" forIndexPath:indexPath];
    if (cell == nil) {
        
        //cell = [[discoversCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discoversCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"discoversCell" forIndexPath:indexPath];
    }
    

    DiscoverUser *discoverUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd/MM/yyyy HH:mm"];
    //df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *localDateString = [df stringFromDate:discoverUser.timeMeet];
    
    if (discoverUser.userFullName == nil) {
        cell.userFullName.text = @"Anonymous";
    } else {
        cell.userFullName.text = discoverUser.userFullName;
    }
    cell.localDateTime.text = localDateString;
    
 //   UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
    UIImage *def_image = [UIImage imageNamed:@"male"];
    //UIImage *def_image = [UIImage imageNamed:@"profile_blank@2x.png"];
    cell.pfImageView.image = def_image;
    //UIImage *def_image = [UIImage imageNamed:@"messages_blank.png"];
    //cell.pfImageView.image = def_image;
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:discoverUser.userName];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             
             PFUser *user = [objects firstObject];
             
             if (discoverUser.userFullName == nil) {
                 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
                 request.predicate = [NSPredicate predicateWithFormat:@"userName = %@", user.username];
                 
                 NSError *error;
                 NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
                 
                 if (error) {
                     
                 } else {
                     DiscoverUser *discover = [matches firstObject];
                    discover.userFullName = user[PF_USER_FULLNAME];
                     cell.userFullName.text = user[PF_USER_FULLNAME];
                 }
                 
                 NSError *save_error=nil;
                 
                 if (![self.managedObjectContext save:&save_error]) {
                     NSLog(@"Couldn't save %@", [error localizedDescription]);
                 }
                 
                 //NSLog(@"Discover add is %@, %@, %@, %@", discoverUser.userName, discoverUser.timeMeet, discoverUser.latitude, discoverUser.longitude);
                 
                 //setup notification to other view controller that the context is avaiable.
                 NSDictionary *userInfo = self.managedObjectContext ? @{DatabaseAvailabilityContext : self.managedObjectContext } : nil;
                 [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
                 
                 NSLog(@"Post database notification!");
                 
             }
             if (user[PF_USER_THUMBNAIL] == nil)
             {
                 UIImage *def_image_male = [UIImage imageNamed:@"male"];
                  UIImage *def_image_female = [UIImage imageNamed:@"female"];
                 
                 //UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
                 if ([user[PF_USER_SEX]  isEqual: @"Male"])
                 {
                  cell.pfImageView.image = def_image_male;
                 }
                 
                 else  if ([user[PF_USER_SEX]  isEqual: @"Female"])
                 {
                     cell.pfImageView.image = def_image_female;
                     
                 }
                 
                 else
                 {
                     cell.pfImageView.image = def_image_male;
                 }
                 //UIImage *def_image = [UIImage imageNamed:@"profile_blank@2x.png"];


             } else {
                 [cell bindData:user];
             }
         }
     }];

    
    return cell;
}
/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(discoversCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"update discover table view");
    DiscoverUser *discoverUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd/MM/yyyy HH:mm"];
    //df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *localDateString = [df stringFromDate:discoverUser.timeMeet];
    
    cell.localDateTime.text = localDateString;
    cell.userFullName.text = discoverUser.userFullName;
    
    
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:discoverUser.userName];
    
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             
             PFUser *user = [objects firstObject];
             PFFile *discoverThumbnail = user[PF_USER_THUMBNAIL];
             if (user[PF_USER_THUMBNAIL] == nil)
             {
                 UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
                 cell.imageUser.image = def_image;
             }

             [discoverThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                 //NSLog(@"in the block");
                 if(!error) {
                     //NSLog(@"no error!");
                     UIImage *image = [UIImage imageWithData:data];
                     //NSLog(@"data is %@", data);
                     cell.imageUser.image = image;
                     //dispatch_async(dispatch_get_main_queue(), ^{ cell.imageView.image = image; });
                 }
             }];
         }
     }];
    
}
*/

#pragma mark - Table view delegate
-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    DiscoverUser *discoverUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[detailsView class]]) {
        detailsView *dv = (detailsView *)vc;
        dv.discoverUser = discoverUser;
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


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    /*
     id detailvc = [self.splitViewController.viewControllers lastObject];
     if([detailvc isKindOfClass:[UINavigationController class]]) {
     detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
     [self prepareViewController:detailvc forSegue:nil fromIndexPath:indexPath];
     }
     */
    
    DiscoverUser *discoverUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    detailsView *dv = [[detailsView alloc] init];
    dv.discoverUser = discoverUser;
    CLLocationDegrees longitude = [discoverUser.longitude doubleValue];
    CLLocationDegrees latitude = [discoverUser.latitude doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    dv.location = location;
    dv.context = self.managedObjectContext;
    [self.navigationController pushViewController:dv animated:YES];
    /*
     //---------------------------------------------------------------------------------------------------------------------------------------------
     PFUser *user = DiscoverItems[indexPath.row];
     //NSString *discoverId = discover.objectId;
     //---------------------------------------------------------------------------------------------------------------------------------------------
     //CreateMessageItem([PFUser currentUser], discoverId, discover[PF_GROUPS_NAME]);
     NSString *discoverId = StartPrivateChat([PFUser currentUser], user);
     //---------------------------------------------------------------------------------------------------------------------------------------------
     ChatView *chatView = [[ChatView alloc] initWith:discoverId];
     chatView.hidesBottomBarWhenPushed = YES;
     [self.navigationController pushViewController:chatView animated:YES];
     */
}


@end