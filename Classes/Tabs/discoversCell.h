//
//  discoversCell.h
//  app
//
//  Created by Daniel Lau on 6/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface discoversCell : UITableViewCell

- (void)bindData:(PFObject *)discovered_users_;
@property (retain, nonatomic) IBOutlet UIImageView *imageUser;
@property (retain, nonatomic) IBOutlet UILabel *userFullName;
@property (retain, nonatomic) IBOutlet UILabel *localDateTime;

@end
