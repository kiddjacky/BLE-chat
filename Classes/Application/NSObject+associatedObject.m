//
//  NSObject+associatedObject.m
//  app
//
//  Created by Daniel Lau on 8/15/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "NSObject+associatedObject.h"

@implementation NSObject (associatedObject)

- (id)associatedObject
{
    return objc_getAssociatedObject(self, @selector(associatedObject));
}

- (void)setAssociatedObject:(id)associatedObject
{
    objc_setAssociatedObject(self,
                             @selector(associatedObject),
                             associatedObject,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
