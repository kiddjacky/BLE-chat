//
//  discoversCell.h
//  app
//
//  Created by Daniel Lau on 6/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface discoversCell : PFTableViewCell

- (void)bindData:(PFUser *)discovered_user;

@property (strong, nonatomic) IBOutlet PFImageView *pfImageView;

@property (strong, nonatomic) IBOutlet UILabel *userFullName;
@property (strong, nonatomic) IBOutlet UILabel *localDateTime;

/*
 @property (nonatomic, weak) IBOutlet UIImageView *imageUser;
@property (nonatomic, weak) IBOutlet UILabel *userFullName;
@property (nonatomic, weak) IBOutlet UILabel *localDateTime;
*/
@end
