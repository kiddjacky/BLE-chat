//
//  CurrentUser.h
//  app
//
//  Created by kiddjacky on 5/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contacts, DiscoverUser;

@interface CurrentUser : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * age;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * interest;
@property (nonatomic, retain) NSString * selfDescription;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) id contactList;
@property (nonatomic, retain) NSString * userFullName;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *discovers;
@end

@interface CurrentUser (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contacts *)value;
- (void)removeContactsObject:(Contacts *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addDiscoversObject:(DiscoverUser *)value;
- (void)removeDiscoversObject:(DiscoverUser *)value;
- (void)addDiscovers:(NSSet *)values;
- (void)removeDiscovers:(NSSet *)values;

@end
