//
//  discoversCell.m
//  app
//
//  Created by Daniel Lau on 6/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "AppConstant.h"
#import "utilities.h"


#import "discoversCell.h"

@interface discoversCell()
{
    //PFUser *discovered_users;
}
/*
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *userFullName;
@property (strong, nonatomic) IBOutlet UILabel *localDateTime;
*/
@end

@implementation discoversCell

@synthesize userFullName = _userFullName;
@synthesize localDateTime = _localDateTime;

@synthesize pfImageView = _pfImageView;

- (void)awakeFromNib {
    // Initialization code
   // _userFullName.text = @"test1";
   // _localDateTime.text = @"test2";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(PFUser *)discovered_user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self.pfImageView.frame = CGRectMake(10, 10, 50, 50);
    self.pfImageView.layer.cornerRadius = self.pfImageView.frame.size.width/2;
    self.pfImageView.layer.masksToBounds = YES;
    [self.pfImageView setContentMode:UIViewContentModeScaleAspectFit];
    //discovered_users = discovered_users_;
    if (discovered_user[PF_USER_PICTURE]) {
        PFFile *discoverThumbnail = discovered_user[PF_USER_THUMBNAIL];
        self.pfImageView.file = discoverThumbnail;
        [self.pfImageView loadInBackground];
    }

    
    //self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width/2;
    //self.imageUser.layer.masksToBounds = YES;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //PFUser *user = discovered_users;
    
    //[self.imageUser setFile:lastUser[PF_USER_PICTURE]];
    //[self.imageUser loadInBackground];

    //userFullName.text = @"test";
    //localDateTime.text = @"test";
    

}


@end
