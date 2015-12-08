//
//  discussionCellWithoutPicture.h
//  app
//
//  Created by kiddjacky on 10/21/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface discussionCellWithoutPicture : UITableViewCell

@property (strong, nonatomic) PFObject *group;
@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) IBOutlet UILabel *topic;
@property (strong, nonatomic) IBOutlet UILabel *topicDescription;
@property (strong, nonatomic) IBOutlet UIButton *up;
@property (strong, nonatomic) IBOutlet UIButton *down;
@property (strong, nonatomic) IBOutlet UIButton *share;
@property (strong, nonatomic) IBOutlet UIButton *join;
@property (strong, nonatomic) IBOutlet UIButton *report;

/*
@property (strong, nonatomic) UILabel *topic;
//@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) UILabel *topicDescription;


@property (strong, nonatomic)  UIButton *down;
@property (strong, nonatomic)  UIButton *up;
@property (strong, nonatomic)  UIButton *join;

@property (strong, nonatomic) UIButton *share;
@property (strong, nonatomic) UIButton *report;
 
*/
@end
