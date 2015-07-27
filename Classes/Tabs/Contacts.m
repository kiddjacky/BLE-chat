//
//  Contacts.m
//  app
//
//  Created by kiddjacky on 7/21/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "Contacts.h"


@implementation Contacts

@dynamic age;
@dynamic interest;
@dynamic selfDescription;
@dynamic sex;
@dynamic thumbnail;
@dynamic userFullName;
@dynamic userName;
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