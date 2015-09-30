//
//  blockVC.h
//  app
//
//  Created by kiddjacky on 9/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BlockUserDelegate <NSObject>

-(void) blockUser:(NSMutableArray *)blockedUsers;

@end

@interface blockVC : UITableViewController

@property(nonatomic,assign) id<BlockUserDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *userlist;
@property (strong, nonatomic) NSMutableArray *namelist;
@property (strong, nonatomic) NSMutableArray *selection;

@end
