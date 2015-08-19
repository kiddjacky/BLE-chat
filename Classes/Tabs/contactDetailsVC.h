//
//  contactDetailsVC.h
//  app
//
//  Created by kiddjacky on 5/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "DiscoverUser.h"

@interface contactDetailsVC : UITableViewController 
@property (strong, nonatomic) Contacts *contact;
//@property (strong, nonatomic) DiscoverUser *discoverUser;

@end
