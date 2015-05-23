//
//  Contacts.h
//  app
//
//  Created by kiddjacky on 5/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userFullName;
@property (nonatomic, retain) NSDecimalNumber * age;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * interest;
@property (nonatomic, retain) NSString * selfDescription;
@property (nonatomic, retain) id thumbnail;

@end
