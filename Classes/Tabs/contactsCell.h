//
//  contactsCell.h
//  app
//
//  Created by Daniel Lau on 7/22/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface contactsCell : UITableViewCell

- (void)bindData:(PFUser *)discovered_user;
@property (nonatomic, weak) IBOutlet PFImageView *imageUser;
@property (nonatomic, weak) IBOutlet UILabel *userFullName;
@property (nonatomic, weak) IBOutlet UILabel *localDateTime;



@end
