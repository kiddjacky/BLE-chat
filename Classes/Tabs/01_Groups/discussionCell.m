//
//  discussionCell.m
//  app
//
//  Created by kiddjacky on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "discussionCell.h"
#import "AppConstant.h"
#import "ChatView.h"

@implementation discussionCell

@synthesize cardView = _cardView;
@synthesize topic = _topic;
@synthesize topicDescription = _topicDescription;
@synthesize image = _image;
@synthesize status = _status;
@synthesize down = _down;
@synthesize up  = _up;
@synthesize join = _join;

-(void) layoutSubviews
{
    self.backgroundColor = [UIColor lightGrayColor];
    [self cardSetup];
    [self imageSetup];
    
}

-(void)cardSetup
{
    [self.cardView setAlpha:1];
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.cornerRadius =1;
    self.cardView.layer.shadowOffset = CGSizeMake(-.5f, .5f);
    self.cardView.layer.shadowRadius = 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cardView.bounds];
    self.cardView.layer.shadowPath = path.CGPath;
    self.cardView.layer.shadowOpacity = 0.5;
    //self.cardView.layer.shadowColor = [UIColor redColor];
    
    /*
    // Center horizontally
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
     // Center vertically
     [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:self.contentView
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0
     constant:0.0]];*/
}

-(void)imageSetup
{
    self.image.clipsToBounds = YES;
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.backgroundColor = [UIColor whiteColor];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(PFObject *)group
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (1) { //should check if group is pfgroup
        self.image.layer.masksToBounds = YES;

        //[self.image setContentMode:UIViewContentModeScaleAspectFit];
        //PFUser *lastUser = discovered_users[PF_MESSAGES_LASTUSER];
        //[self.imageUser setFile:discovered_user[PF_USER_PICTURE]];
        //[self.imageUser loadInBackground];
    
        if (group[PF_GROUPS_PICTURE]) {
            PFFile *pic = group[PF_GROUPS_PICTURE];
            self.image.file = pic;
            [self.image loadInBackground];
        }


    }
    
}

@end
