//
//  CurrentUser.h
//  app
//
//  Created by kiddjacky on 5/3/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUser : NSObject {
    NSString *userName;
}

@property(nonatomic, retain)NSString *userName;
+(CurrentUser*) getInstance;

@end
