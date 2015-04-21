//
//  DiscoverUser.h
//  app
//
//  Created by kiddjacky on 4/18/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiscoverUser : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDate * timeMeet;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSNumber * latitude;

@end
