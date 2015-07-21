//
//  CurrentUser.m
//  app
//
//  Created by kiddjacky on 5/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CurrentUser.h"
#import "Contacts.h"
#import "DiscoverUser.h"


@implementation CurrentUser

@dynamic age;
@dynamic birthday;
@dynamic interest;
@dynamic selfDescription;
@dynamic sex;
@dynamic userName;
@dynamic thumbnail;
@dynamic picture;
@dynamic contactList;
@dynamic userFullName;
@dynamic contacts;
@dynamic discovers;
@dynamic firstLetter;


@end


@interface Contacts (firstLetter)

@end

@implementation Contacts (firstLetter)

- (NSString *)firstLetter {
    [self willAccessValueForKey:@"firstLetter"];
    NSString *aString = [[self valueForKey:@"userFullName"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    [self didAccessValueForKey:@"firstLetter"];
    return stringToReturn;
}

@end
