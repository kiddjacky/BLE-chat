//
//  feedbackCell.h
//  app
//
//  Created by kiddjacky on 9/20/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface feedbackCell : UITableViewCell
@property (strong, nonatomic) UILabel *topic;
//@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) UILabel *topicDescription;

@property (strong, nonatomic) PFImageView *image;
@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) UIButton *join;

@property (strong, nonatomic) UIButton *share;

@end
