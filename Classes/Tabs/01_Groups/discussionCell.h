//
//  discussionCell.h
//  app
//
//  Created by kiddjacky on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface discussionCell : UITableViewCell

@property (strong, nonatomic) PFObject *group;

@property (strong, nonatomic) IBOutlet UILabel *topic;
//@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *topicDescription;

@property (strong, nonatomic) IBOutlet PFImageView *image;
@property (strong, nonatomic) IBOutlet UIView *cardView;

@property (strong, nonatomic) IBOutlet UIButton *down;
@property (strong, nonatomic) IBOutlet UIButton *up;
@property (strong, nonatomic) IBOutlet UIButton *join;

@property (strong, nonatomic) UIButton *share;

@property (nonatomic, assign)   BOOL didSetupConstraints;

-(void)bindData:(PFObject *)group;

@end
