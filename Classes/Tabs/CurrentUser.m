//
//  CurrentUser.m
//  app
//
//  Created by kiddjacky on 5/3/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

@synthesize userName;

static CurrentUser *instance = nil;

+(CurrentUser *) getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance = [CurrentUser new];
        }
    }
    return instance;
}


@end
