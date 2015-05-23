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
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_discover"]];
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
                                                              ascending:NO
                                                               selector:@selector(localizedStandardCompare:)]];
    
    
    //NSLog(@"Discover set managed object context %@", managedObjectContext);
    
    
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
    
    

     //setup observer before ask the appdelegate to post
     [[NSNotificationCenter defaultCenter] postNotificationName:DiscoverViewReady object:nil];
    
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
        [self loadDiscovers];
    }
    else LoginUser(self);
}

-(void) loadDiscovers //load discover people or ibeacon
{
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    NSLog(@"update table view");
    DiscoverUser *discoverUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = discoverUser.userName;
    
    //find the actual full name
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:discoverUser.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             
             PFUser *user = [objects firstObject];
             NSLog(@"found user %@", user[PF_USER_FULLNAME]);
             cell.textLabel.text = user[PF_USER_FULLNAME];
         }
     }];
    
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd/MM/yyyy HH:mm"];
    //df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *localDateString = [df stringFromDate:discoverUser.timeMeet];
    
    cell.detailTextLabel.text = localDateString;
    NSLog(@"discover user at latitude %@, longitude %@", discoverUser.latitude, discoverUser.longitude);
    /*
    CLLocationDegrees longitude = [discoverUser.longitude doubleValue];
    CLLocationDegrees latitude = [discoverUser.latitude doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             NSLog(@"%@",CountryArea);
             //cell.detailTextLabel.text = Area;
             cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ at %@", localDateString, Area];
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
             //CountryArea = NULL;
         }
     }];
    */

    //PFUser *user = DiscoverItems[indexPath.row];
    //cell.textLabel.text = user[PF_USER_FULLNAME];
    



    
    //if (cell.detailTextLabel.text == nil) cell.detailTextLabel.text = [NSString stringWithFormat:@"latitude %+.6f, longtitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    /*
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_GROUPID equalTo:discover.objectId];
    [query orderByDescending:PF_CHAT_CREATEDAT];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             PFObject *chat = [objects firstObject];
             NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:chat.createdAt];
             cell.detailTextLabel.text = [NSString stringWithFormat:@"%d messages (%@)", (int) [objects count], TimeElapsed(seconds)];
         }
         else cell.detailTextLabel.text = @"No message";
     }];
    */
    return cell;
}

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
