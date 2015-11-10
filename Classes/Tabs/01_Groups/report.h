//
//  report.h
//  app
//
//  Created by kiddjacky on 11/8/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstant.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"

@interface report : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) PFObject *group;
@end
