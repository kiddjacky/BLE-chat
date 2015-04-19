//
//  DiscoversView.m
//  app
//
//  Created by kiddjacky on 3/22/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "DiscoversView.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <CoreLocation/CoreLocation.h>




@interface DiscoversView () <CBPeripheralManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, CLLocationManagerDelegate>
//setup BTLE
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
//unused for now
@property (strong, nonatomic) NSMutableData         *data;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) IBOutlet UITextView   *central_textview;
@property (strong, nonatomic) IBOutlet UITextView       *textView;
@property (strong, nonatomic) IBOutlet UISwitch         *advertisingSwitch;

@property (strong, nonatomic) NSMutableArray *discoveredDevices;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (readonly) CLLocationCoordinate2D *coordinate;
@end


#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DiscoversView()
{
    NSMutableArray *DiscoverItems;
    NSMutableArray *discoverLocation;
    NSMutableArray *discoverTime;
//    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSDate *eventDate;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

#define NOTIFY_MTU      20

@implementation DiscoversView

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
    return self;
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
    DiscoverItems = [[NSMutableArray alloc] init];
    discoverTime = [[NSMutableArray alloc] init];
    discoverLocation = [[NSMutableArray alloc] init];
    self.discoveredDevices = [[NSMutableArray alloc] init];
    
    //BTLE
    
    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
    // Start up the CBCentralManager
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // And somewhere to store the incoming data
    _data = [[NSMutableData alloc] init];
    [self CurrentLocationIdentifier]; // call this method
    
    //start ad
    [self btle_seq];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        [self loadDiscovers];
    }
    else LoginUser(self);
}

-(void) loadDiscovers //load discover people or ibeacon
{
    
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
    return [DiscoverItems count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 50;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    
    PFUser *user = DiscoverItems[indexPath.row];
    cell.textLabel.text = user[PF_USER_FULLNAME];

    
    CLLocation *location = discoverLocation[indexPath.row];
    if (cell.detailTextLabel.text == nil) cell.detailTextLabel.text = [NSString stringWithFormat:@"latitude %+.6f, longtitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude];
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
}

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
    [self scan];
    
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}

//------------ Current Location Address-----
-(void)CurrentLocationIdentifier
{
    //---- For getting current gps location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
 //   _locationManager.distanceFilter = kCLDistanceFilterNone;
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
    currentLocation = [locations lastObject];
    //[locationManager stopUpdatingLocation];
    eventDate = currentLocation.timestamp;
    NSLog(@"Update Location is called\n");
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              currentLocation.coordinate.latitude,
              currentLocation.coordinate.longitude);
    }
}
    
    -(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
        NSLog(@"%@", error.localizedDescription);
    }

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Authorization status changed to %d\n", status   );
}
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


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -35) {
        return;
    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    BOOL matched = 0;
    for (CBPeripheral *discovered in self.discoveredDevices) {
        if (discovered == peripheral) {
            matched = 1;
        }
    }
    
    // Ok, it's in range - have we already seen it?
    //if (self.discoveredPeripheral != peripheral) {
    if (!matched) {
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        //self.discoveredPeripheral = peripheral;
        [self.discoveredDevices addObject:peripheral];
        /* no need to connect
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
         */
        NSString *userName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];

        NSLog(@"userName is %@, advertisement Data is %@", userName, advertisementData);
        PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query whereKey:PF_USER_USERNAME equalTo:userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if ([objects count] != 0)
             {
                 PFUser *user = [objects firstObject];
                 [DiscoverItems addObject:user];
                 [discoverLocation addObject:currentLocation];
                 [discoverTime addObject:eventDate];
                 [self.tableView reloadData];
             }
         }];

        
    }
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
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
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
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
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
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
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
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        // We have, so show the data,
        [self.central_textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    // Otherwise, just add the data on to what we already have
    [self.data appendData:characteristic.value];
    
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
    [self scan];
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
    
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] , CBAdvertisementDataLocalNameKey : user.username   }];
    NSLog(@"send out advertisment data");
    
    //self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(btle_switch_mode:) userInfo:nil repeats:YES];
    
    
    
}

@end
