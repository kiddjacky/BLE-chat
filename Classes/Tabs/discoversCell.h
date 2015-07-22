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
@property (nonatomic, weak) IBOutlet UIImageView *imageUser;
@property (nonatomic, weak) IBOutlet UILabel *userFullName;
@property (nonatomic, weak) IBOutlet UILabel *localDateTime;

@end
