//
//  DiscoverUser.h
//  app
//
//  Created by kiddjacky on 5/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiscoverUser : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timeMeet;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) id thumbnail;

@end
