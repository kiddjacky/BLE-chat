//
//  detailsView.h
//  app
//
//  Created by kiddjacky on 4/28/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DiscoverUser.h"

@interface detailsView : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) DiscoverUser *discoverUser;
@end
