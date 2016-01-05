//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "AppConstant.h"
#import "utilities.h"

#import "AppDelegate.h"
#import "GroupsView.h"
#import "MessagesView.h"
#import "ProfileView.h"
#import "NavigationController.h"
#import "DiscoversView.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <CoreLocation/CoreLocation.h>
#import "DiscoverUser.h"
#import "Contacts.h"
#import "DatabaseAvailability.h"
#import "AppDelegate+MOC.h"

@interface AppDelegate () <CBPeripheralManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, CLLocationManagerDelegate>
//setup BTLE
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral          *connectingPeripheral;
//unused for now
@property (strong, nonatomic) NSMutableData         *data;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) IBOutlet UITextView   *central_textview;
@property (strong, nonatomic) IBOutlet UITextView       *textView;
@property (strong, nonatomic) IBOutlet UISwitch         *advertisingSwitch;
//CLLocation

@property (strong, nonatomic) NSTimer *scanTimer;
@end


#define NOTIFY_MTU      20
#define DISCOVER_USER_LIMIT 50
#define SCAN_INTERVAL (60)

@implementation AppDelegate 

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Parse setApplicationId:@"KKRfZHzURmdqX5H4zkRNHU93DxkSd7qVxjKfVsa2" clientKey:@"JKxstA9Y2OW03FmPb0FC25N3Dxt7ZdXNHSWUCXlA"];
    [WXApi registerApp:@"wx82714711d1f95578"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFFacebookUtils initializeFacebook];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
	{
		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];
	}
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFImageView class];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.groupsView = [[GroupsView alloc] init];
	self.messagesView = [[MessagesView alloc] init];
	//self.profileView = [[ProfileView alloc] init];
    self.settingView = [[settingTVC alloc] initWithNibName:nil bundle:nil];
    self.discoversView = [[DiscoversView alloc] initWithNibName:nil bundle:nil];
    //self.discoversView.managedObjectContext = self.DiscoverDatabaseContext;
    self.contactsView = [[ContactsView alloc] initWithNibName:nil bundle:nil];
    //self.contactsView.managedObjectContext = self.DiscoverDatabaseContext;

	NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.groupsView];
	NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.messagesView];
	NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.contactsView];
    NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.discoversView];
    //NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.profileView];
    NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.settingView];

	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, navController4, navController5, nil];
	self.tabBarController.tabBar.translucent = NO;
	self.tabBarController.selectedIndex = DEFAULT_TAB;

	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    
    //create database
    //self.DiscoverDatabaseContext = [self createMainQueueManagedObjectContext];
    if (!self.DiscoverDatabaseContext) [self useDocument];
    
    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
    // Start up the CBCentralManager
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // And somewhere to store the incoming data
    _data = [[NSMutableData alloc] init];
    
    //_locationManager = [[CLLocationManager alloc] init];
    [self CurrentLocationIdentifier]; // call this method

    //[self post_context];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(post_context) name:DiscoverViewReady object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop_scan) name:PFUSER_DISABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(start_scan) name:PFUSER_ENABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop_scan) name:PFUSER_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(start_scan) name:PFUSER_READY object:nil];

    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"appDelegate get notification");
                                                      self.DiscoverDatabaseContext= note.userInfo[DatabaseAvailabilityContext];
                                                  }];
    
	return YES;
}


-(void)stop_scan
{
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    [self.centralManager stopScan];
    NSLog(@"stop scan!");
}

-(void)start_scan
{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    NSLog(@"central manager start to scan!");
    [self scan];
    NSLog(@"central manager setup scan timer");
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:SCAN_INTERVAL
                                                                       target:self
                                                                     selector:@selector(scan:)
                                                                     userInfo:nil
                                                                      repeats:YES];
    
    //[self scan];
}

-(void)scan:(NSTimer *)timer
{
    [self scan];
}


//setup discover database
/*
-(void)setDiscoverDatabaseContext:(NSManagedObjectContext *)DiscoverDatabaseContext
{
    _DiscoverDatabaseContext = DiscoverDatabaseContext;
    
    //setup notification to other view controller that the context is avaiable.
    NSDictionary *userInfo = self.DiscoverDatabaseContext ? @{DatabaseAvailabilityContext : self.DiscoverDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
    
    NSLog(@"Post database notification!");
    
}*/

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"enter background mode!");
    [self.locationManager startMonitoringSignificantLocationChanges];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
        NSLog(@"back from background mode!");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

#pragma mark - Facebook responses

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
	[currentInstallation saveInBackground];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//[PFPush handlePush:userInfo];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self performSelector:@selector(refreshMessagesView) withObject:nil afterDelay:4.0];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshMessagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.messagesView loadMessages];
}


#pragma Discover Scheme

#pragma mark - BTLE
/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    
    if (self.DiscoverDatabaseContext && self.scanTimer==nil) {
        [self start_scan];
    }
}



/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
    
    NSLog(@"Scanning started");
}

//------------ Current Location Address-----
-(void)CurrentLocationIdentifier
{
    //---- For getting current gps location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500; //500 meter filter
    //    [self.locationManager requestAlwaysAuthorization];
    //    NSLog(@"CurrentLocationIdentifier is called\n");
    
    [self.locationManager startUpdatingLocation];
    NSLog(@"Location Services enabled = %d", [CLLocationManager locationServicesEnabled]);
    NSLog(@"Authorization Status = %d", [CLLocationManager authorizationStatus]);
    NSLog(@"CurrentLocationIdentifier is called\n");
    //------
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    //[locationManager stopUpdatingLocation];
    //eventDate = currentLocation.timestamp;
    NSLog(@"Update Location is called\n");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdate" object:nil userInfo:nil];
    /*
     NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
     if (abs(howRecent) < 15.0) {
     // If the event is recent, do something with it.
     NSLog(@"latitude %+.6f, longitude %+.6f\n",
     currentLocation.coordinate.latitude,
     currentLocation.coordinate.longitude);
     }
     */
    
    /*
     CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
     [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
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
     }
     else
     {
     NSLog(@"Geocode failed with error %@", error);
     NSLog(@"\nCurrent Location Not Detected\n");
     //return;
     //CountryArea = NULL;
     }
     ---- For more results
     placemark.region);
     placemark.country);
     placemark.locality);
     placemark.name);
     placemark.ocean);
     placemark.postalCode);
     placemark.subLocality);
     placemark.location);
     ------
     
     }];
     */
    
    
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Authorization status changed to %d\n", status   );
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"enter call back");
    // Reject any where the value is above reasonable range
    /*
     if (RSSI.integerValue > -15) {
     return;
     }
     
     // Reject if the signal strength is too low to be close enough (Close is around -22dB)
     if (RSSI.integerValue < -35) {
     return;
     }
     */
 
    NSString *userName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"Discovered %@ at %@", userName, RSSI);
    NSString *identifier = [peripheral.identifier UUIDString];
    
    if (userName!=NULL && userName.length > 0 ) {
        [self get_info:userName with_identifier:identifier];
    }
    else { //if null, it is in back gorund, need ot connect
        //NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:@"DD2468AB-1865-B926-7FA4-AE3755D479D8"];
        NSArray *known_peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:peripheral.identifier]];
        NSLog(@"peripeheral is %@", peripheral);
        NSLog(@"known_periperal is %@", known_peripherals);
          if ([known_peripherals count] == 0) {
              NSLog(@"peripheral is in background, try to connect");
              if (peripheral.state == CBPeripheralStateDisconnected) {
                  NSLog(@"try to connect");
                  [self.centralManager connectPeripheral:peripheral options:nil];
                  self.connectingPeripheral = peripheral;
              }
           }
          else {
              //more than 5 mins reconnect again
              NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
              request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
              request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeMeet"
                                                                        ascending:NO]];
              NSError *error;
              NSArray *identifier_matches = [self.DiscoverDatabaseContext executeFetchRequest:request error:&error];
              
              if (error) {
                  
              } else if ([identifier_matches count]!=0) {
                  NSLog(@"already matched");
                  DiscoverUser *discoverUser = [identifier_matches firstObject];
                  NSLog(@"already discover user is %@, %@, %@, %@", discoverUser.userName, discoverUser.timeMeet, discoverUser.latitude, discoverUser.longitude);
                  //caculate time difference
                  NSTimeInterval distanceBetweeenDates = [[NSDate date] timeIntervalSinceDate:discoverUser.timeMeet];
                  double secondsInMin = 60;
                  NSInteger minsBetweenDates = distanceBetweeenDates / secondsInMin;
                  if (minsBetweenDates >= 2 )
                  {
                      NSLog(@"time meet for the same discover user is more than 2 mins, update location and time");
                      discoverUser.timeMeet = [NSDate date];
                      double latitude = (double)[self.currentLocation coordinate].latitude;
                      discoverUser.latitude = [NSNumber numberWithDouble:latitude];
                      double longitude = (double)[self.currentLocation coordinate].longitude;
                      discoverUser.longitude = [NSNumber numberWithDouble:longitude];
                      discoverUser.identifier = identifier;
                      
                      //find the actual full name
                      PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
                      [query whereKey:PF_USER_USERNAME equalTo:discoverUser.userName];
                      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                       {
                           if ([objects count] != 0)
                           {
                               NSLog(@"find pf user full name and thumbnail");
                               PFUser *user = [objects firstObject];
                               discoverUser.userFullName = user[PF_USER_FULLNAME];
                               [self save_and_post];
                               //NSLog(@"save and post finished!");
                               
                           }
                       }];
                      
                      [self save_and_post];
                  }
                  else {
                      NSLog(@"Background time meet for the same discover user is too soon to change");
                  }

              }
              /* sort make sure the first object is latest
              else if ([identifier_matches count]>1) {
                  //with more than one match, should choose the most up-to date one to update
              }*/
              else {
                  //no identifier match, might be the MOC haven't update, wait
                 
                  NSLog(@"2 peripheral is in background, try to connect");
                  if (peripheral.state == CBPeripheralStateDisconnected) {
                      NSLog(@"2 try to connect");
                      [self.centralManager connectPeripheral:peripheral options:nil];
                      self.connectingPeripheral = peripheral;
                  }
                
                  //NSLog(@"wait for MOC to update identifier");
              }
          }
    }
}


-(void) get_info:(NSString *)userName with_identifier:(NSString *)identifier
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"userName = %@", userName];
    
    NSError *error;
    NSArray *matches = [self.DiscoverDatabaseContext executeFetchRequest:request error:&error];
    
    if (error) {
        //handle error
        NSLog(@"request Error!");
    } else if ([matches count]==1) {
        //maybe need to update the location or time
        NSLog(@"already matched");
        DiscoverUser *discoverUser = [matches firstObject];
        NSLog(@"already discover user is %@, %@, %@, %@", discoverUser.userName, discoverUser.timeMeet, discoverUser.latitude, discoverUser.longitude);
        //caculate time difference
        NSTimeInterval distanceBetweeenDates = [[NSDate date] timeIntervalSinceDate:discoverUser.timeMeet];
        double secondsInMin = 1;
        NSInteger secondsBetweenDates = distanceBetweeenDates / secondsInMin;
        if (secondsBetweenDates >= 100 )
        {
            NSLog(@"time meet for the same discover user is more than 2 mins, update location and time");
            discoverUser.timeMeet = [NSDate date];
            double latitude = (double)[self.currentLocation coordinate].latitude;
            discoverUser.latitude = [NSNumber numberWithDouble:latitude];
            double longitude = (double)[self.currentLocation coordinate].longitude;
            discoverUser.longitude = [NSNumber numberWithDouble:longitude];
            discoverUser.identifier = identifier;
            
            //find the actual full name
            PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [query whereKey:PF_USER_USERNAME equalTo:discoverUser.userName];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if ([objects count] != 0)
                 {
                     //NSLog(@"find pf user full name and thumbnail");
                     PFUser *user = [objects firstObject];
                     discoverUser.userFullName = user[PF_USER_FULLNAME];
                     NSLog(@"found user %@, thumbnail is %@", discoverUser.userFullName, user[PF_USER_THUMBNAIL]);
                     /*
                     PFFile *discoverThumbnail = user[PF_USER_THUMBNAIL];
                     [discoverThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                         NSLog(@"in the block");
                         if(!error) {
                             NSLog(@"no error!");
                             discoverUser.thumbnail = data;
                             [self save_and_post];
                             NSLog(@"thumbnail is %@", discoverUser.thumbnail);
                         }
                     }];
                      */
                     //NSLog(@"save thumbnail %@", discoverUser.thumbnail);
                     [self save_and_post];
                     //NSLog(@"save and post finished!");
                     
                 }
             }];
            
            [self save_and_post];
        }
        else {
            NSLog(@"time meet for the same discover user is too soon to change");
        }
        
    } else {
        NSLog(@"create new core data");
        
        NSFetchRequest *add_request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
        add_request.predicate = nil;
        add_request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeMeet"
                                                                      ascending:NO]];
        
        NSError *add_error;
        NSArray *add_matches = [self.DiscoverDatabaseContext executeFetchRequest:add_request error:&add_error];
        
        if ([add_matches count] == DISCOVER_USER_LIMIT) {
            NSLog(@"discover user reaching limit, remove the earliest discover user");
            [self.DiscoverDatabaseContext deleteObject:[add_matches lastObject]];
        }
        
        NSManagedObjectContext *context = [self DiscoverDatabaseContext];
        DiscoverUser *discoverUser = [NSEntityDescription insertNewObjectForEntityForName:@"DiscoverUser" inManagedObjectContext:context];
        discoverUser.userName = userName;
        discoverUser.timeMeet = [NSDate date];
        double latitude = (double)[self.currentLocation coordinate].latitude;
        discoverUser.latitude = [NSNumber numberWithDouble:latitude];
        double longitude = (double)[self.currentLocation coordinate].longitude;
        discoverUser.longitude = [NSNumber numberWithDouble:longitude];
        discoverUser.identifier = identifier;
                  NSLog(@"using parse query");
        //find the actual full name
        PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query whereKey:PF_USER_USERNAME equalTo:discoverUser.userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if ([objects count] != 0)
             {
                 NSLog(@"find pf user full name and thumbnail");
                 PFUser *user = [objects firstObject];
                 discoverUser.userFullName = user[PF_USER_FULLNAME];
                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                 params[@"fullName"] = user[PF_USER_FULLNAME];
                 params[@"name"] = user[PF_USER_USERNAME];
                 params[@"installationId"] = [PFInstallation currentInstallation].installationId;
                 PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude
                                                            longitude:self.currentLocation.coordinate.longitude];
                 params[@"point"] = point;
                 [PFCloud callFunctionInBackground:@"meetNewUser" withParameters:params];
                 //NSLog(@"found user %@, thumbnail is %@", discoverUser.userFullName, user[PF_USER_THUMBNAIL]);
                 /*
                 PFFile *discoverThumbnail = user[PF_USER_THUMBNAIL];
                 [discoverThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                     NSLog(@"in the block");
                     if(!error) {
                         NSLog(@"no error!");
                         discoverUser.thumbnail = data;
                        [self save_and_post];
                         NSLog(@"thumbnail is %@", discoverUser.thumbnail);
                     }
                 }];
                  */
                 //NSLog(@"save thumbnail %@", discoverUser.thumbnail);
                 [self save_and_post];
                 NSLog(@"save and post finished!");

             }
         }];
        
        [self save_and_post];
        
    }
}

-(void) save_and_post
{
    
    NSError *error=nil;
    
    if (![self.DiscoverDatabaseContext save:&error]) {
        NSLog(@"Couldn't save %@", [error localizedDescription]);
    }
    
    //NSLog(@"Discover add is %@, %@, %@, %@", discoverUser.userName, discoverUser.timeMeet, discoverUser.latitude, discoverUser.longitude);
    
    //setup notification to other view controller that the context is avaiable.
    NSDictionary *userInfo = self.DiscoverDatabaseContext ? @{DatabaseAvailabilityContext : self.DiscoverDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
    
    NSLog(@"Post database notification!");
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    //[self.centralManager stopScan];
    //NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        NSLog(@"discover service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"discover characteristic");
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]) {
            NSLog(@"read characteristic!");
            [peripheral readValueForCharacteristic:characteristic];
            // If it is, subscribe to it
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    NSString *identifier = [peripheral.identifier UUIDString];
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"characteristic is %@", stringFromData);
    // Have we got everything we need?
    if (stringFromData != nil) {
        
        // We have, so show the data,
        [self get_info:stringFromData with_identifier:identifier];
        
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    // Otherwise, just add the data on to what we already have
    //[self.data appendData:characteristic.value];
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
    // We're disconnected, so start scanning again
    //[self scan];
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.discoveredPeripheral == CBPeripheralStateConnecting) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}




#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    
    // ... so build our service.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop_ad) name:PFUSER_DISABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btle_seq) name:PFUSER_ENABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btle_seq) name:PFUSER_READY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop_ad) name:PFUSER_LOGOUT object:nil];
    
    if ([PFUser currentUser] != nil) {
        [self btle_seq];
    } else {
        return;
    }
    /*
     // Start with the CBMutableCharacteristic
     self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
     properties:CBCharacteristicPropertyNotify
     value:nil
     permissions:CBAttributePermissionsReadable];
     
     // Then the service
     CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
     primary:YES];
     
     // Add the characteristic to the service
     transferService.characteristics = @[self.transferCharacteristic];
     
     // And add it to the peripheral manager
     [self.peripheralManager addService:transferService];
     */
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    // Get the data
    self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}


/** Start advertising
 */
- (IBAction)switchChanged:(id)sender
{
    if (self.advertisingSwitch.on) {
        // All we advertise is our service's UUID
        [self btle_seq];
        //        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
    
    else {
        [self.peripheralManager stopAdvertising];
    }
}

-(void)btle_switch_mode:(NSTimer *)switchtimer
{
    //    NSLog(@"Timer is fired off");
    
    //    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
    //        [self.peripheralManager stopAdvertising];
    //        return;
    //    }
    
}

- (void)btle_seq
{
    PFUser *user = [PFUser currentUser];

    
    [self.peripheralManager removeAllServices];
    // create our characteristics
    CBMutableCharacteristic *characteristic =
    [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                       properties:CBCharacteristicPropertyRead
                                            value:[user.username dataUsingEncoding:NSUTF8StringEncoding]
                                      permissions:CBAttributePermissionsReadable];
    
    // create the service with the characteristics
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
    service.characteristics = @[characteristic];

    [self.peripheralManager addService:service];
    
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] , CBAdvertisementDataLocalNameKey : user.username  }];
    NSLog(@"send out advertisment data, user name is %@", user.username);

    //self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(btle_switch_mode:) userInfo:nil repeats:YES];
}

-(void)stop_ad
{
    [self.peripheralManager stopAdvertising];
    NSLog(@"stop advertising");
}

-(void)post_context
{
    //setup notification to other view controller that the context is avaiable.
    NSDictionary *userInfo = self.DiscoverDatabaseContext ? @{DatabaseAvailabilityContext : self.DiscoverDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
    
    NSLog(@"Post database notification in observer!");
    
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
                  self.DiscoverDatabaseContext = document.managedObjectContext;
                  //[self refresh];
                  NSLog(@"create uidocument");
                  [self post_context];
                  [self start_scan];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.DiscoverDatabaseContext = document.managedObjectContext;
                NSLog(@"open uidocument");
                [self post_context];
                [self start_scan];
            }
        }];
    } else {
        self.DiscoverDatabaseContext = document.managedObjectContext;
        NSLog(@"just use ui document");
        [self post_context];
        [self start_scan];
    }
}

@end
