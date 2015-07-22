//
//  AppDelegate+MOC.h
//  app
//
//  Created by kiddjacky on 5/3/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (MOC)
- (NSManagedObjectContext *)createMainQueueManagedObjectContext;
@end
