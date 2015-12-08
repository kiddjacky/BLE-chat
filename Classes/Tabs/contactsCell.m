//
//  contactsCell.m
//  app
//
//  Created by Daniel Lau on 7/22/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//
//
//#import "contactsCell.h"
//
//@implementation contactsCell
//
//- (void)awakeFromNib {
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
//
//@end
//


//
//  contactsCell.m
//  app
//
//  Created by Daniel Lau on 6/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "AppConstant.h"
#import "utilities.h"


#import "contactsCell.h"

@interface contactsCell()
{
    PFObject *discovered_users;
}
/*
 @property (strong, nonatomic) IBOutlet UIImageView *imageUser;
 @property (strong, nonatomic) IBOutlet UILabel *userFullName;
 @property (strong, nonatomic) IBOutlet UILabel *localDateTime;
 */
@end

@implementation contactsCell

@synthesize imageUser = _imageUser;
@synthesize userFullName = _userFullName;
@synthesize localDateTime = _localDateTime;


- (void)awakeFromNib {
    // Initialization code
    // _userFullName.text = @"test1";
    // _localDateTime.text = @"test2";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)bindData:(PFObject *)discovered_user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
     //discovered_user = discovered_user;
    //self.imageUser.frame = CGRectMake(10, 10, 50, 50);
    self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width/2;
    

    self.imageUser.layer.masksToBounds = YES;
     //---------------------------------------------------------------------------------------------------------------------------------------------
    [self.imageUser setContentMode:UIViewContentModeScaleAspectFit];
     //PFUser *lastUser = discovered_users[PF_MESSAGES_LASTUSER];
     //[self.imageUser setFile:discovered_user[PF_USER_PICTURE]];
     //[self.imageUser loadInBackground];
    
    if (discovered_user[PF_USER_PICTURE]) {
        PFFile *discoverThumbnail = discovered_user[PF_USER_THUMBNAIL];
        self.imageUser.file = discoverThumbnail;
        [self.imageUser loadInBackground];
    }
     //userFullName.text = @"test";
     //localDateTime.text = @"test";
    
    
}


@end
