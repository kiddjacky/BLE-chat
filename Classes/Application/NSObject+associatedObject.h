//
//  NSObject+associatedObject.h
//  app
//
//  Created by Daniel Lau on 8/15/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (associatedObject)


@property (nonatomic, retain) id associatedObject;


@end
