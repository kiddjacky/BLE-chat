//
//  Contacts.h
//  app
//
//  Created by kiddjacky on 7/21/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"

@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * age;
@property (nonatomic, retain) NSString * interest;
@property (nonatomic, retain) NSString * selfDescription;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * userFullName;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * firstLetter;
@property (nonatomic, retain) NSString * address;
//@property (nonatomic, retain) PFUser * pfUser;
@end
