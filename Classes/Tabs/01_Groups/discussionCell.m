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
//@synthesize status = _status;
@synthesize down = _down;
@synthesize up  = _up;
@synthesize join = _join;
@synthesize share = _share;
@synthesize report = _report;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self cardSetup];
        [self imageSetup];
        [self cellLayout];
        //[self drawButton];
    }
    return self;
}

/*
-(void) layoutSubviews
{
    [super layoutSubviews];
    
    //self.backgroundColor = [UIColor greenColor];
    [self cardSetup];
    [self imageSetup];
    [self cellLayout];
    //CGFloat viewWidth = self.contentView.frame.size.width;
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
}
*/

-(void)cardSetup
{
    self.cardView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardView.backgroundColor = [UIColor whiteColor];
    //[self.cardView setAlpha:1];
    //self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.cornerRadius = 5;
    self.cardView.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    self.cardView.layer.shadowRadius = 1.0f;
    //UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cardView.bounds];
    //self.cardView.layer.shadowPath = path.CGPath;
    self.cardView.layer.shadowOpacity = 0.5f;
    [self.contentView addSubview:self.cardView];
    
    self.topic = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topic.translatesAutoresizingMaskIntoConstraints = NO;
    self.topic.lineBreakMode = NSLineBreakByWordWrapping;
    self.topic.numberOfLines = 0;
    self.topic.textAlignment =  NSTextAlignmentCenter;
    self.topic.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    //self.topic.backgroundColor = [UIColor redColor];
    //self.topic.text = @"test";
    [self.contentView addSubview:self.topic];
    
    _topicDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topicDescription.translatesAutoresizingMaskIntoConstraints = NO;
    self.topicDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.topicDescription.numberOfLines = 0;
    self.topicDescription.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    //self.topicDescription.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.topicDescription];
    
    _image = [[PFImageView alloc] initWithFrame:CGRectZero];
    self.image.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.image];
    
    _up = [[UIButton alloc] initWithFrame:CGRectZero];
    self.up.translatesAutoresizingMaskIntoConstraints = NO;
    [self.up setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[self.up setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.up setTitle:@"Yes" forState:UIControlStateNormal];
    self.up.backgroundColor = [UIColor greenColor];
    self.up.layer.cornerRadius = 15;
    [self.contentView addSubview:self.up];
    
    
    _down = [[UIButton alloc] initWithFrame:CGRectZero];
    self.down.translatesAutoresizingMaskIntoConstraints = NO;
    [self.down setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.down setTitle:@"No" forState:UIControlStateNormal];
    self.down.backgroundColor = [UIColor redColor];
    self.down.layer.cornerRadius = 15;
    [self.contentView addSubview:self.down];
    
    _join = [[UIButton alloc] initWithFrame:CGRectZero];
    self.join.translatesAutoresizingMaskIntoConstraints = NO;
    [self.join setTitle:@"Join" forState:UIControlStateNormal];
    [self.join setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.join.backgroundColor = [UIColor blueColor];
    self.join.layer.cornerRadius = 15;
    [self.contentView addSubview:self.join];
    
    _share = [[UIButton alloc] initWithFrame:CGRectZero];
    self.share.translatesAutoresizingMaskIntoConstraints = NO;
    [self.share setTitle:@"Share" forState:UIControlStateNormal];
    [self.share setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.share.backgroundColor = [UIColor blueColor];
    self.share.layer.cornerRadius = 15;
    [self.contentView addSubview:self.share];

    _report = [[UIButton alloc] initWithFrame:CGRectZero];
    self.report.translatesAutoresizingMaskIntoConstraints = NO;
    [self.report setTitle:@"Report" forState:UIControlStateNormal];
    [self.report setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.report.backgroundColor = [UIColor blueColor];
    self.report.layer.cornerRadius = 15;
    [self.contentView addSubview:self.report];
}

-(void)drawButton
{
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = self.up.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [self.up.layer insertSublayer:btnGradient atIndex:0];
}

-(void)cellLayout
{
    //position
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topic
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    // Center horizontally
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topic
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
    /*
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topic
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    */
    
    //position
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topicDescription
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0
                                                               constant:280]];
    // Center horizontally
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topicDescription
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0.0]];
    /*
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topicDescription
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0
                                                               constant:30]];
    */

    //position
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.image
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0
                                                               constant:280]];
    // Center horizontally
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.image
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0.0]];
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.image
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0
                                                               constant:320]];
    
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.up
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0
                                                               constant:30]];
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.down
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0
                                                               constant:30]];
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.join
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0
                                                               constant:30]];

    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.share
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0
                                                                  constant:30]];
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.report
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0
                                                                  constant:30]];
    
    // Width constraint, full of parent view width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.up
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.down
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    // Width constraint, full of parent view width
    /*
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.report
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.join
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0
                                                               constant:0]];
     */
    
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.report
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0
                                                                  constant:90]];
    
    // Width constraint, full of parent view width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.report
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.share
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0]];
    
    //relative position constriants
    NSDictionary *viewsDictionary = @{@"nameView":self.topic, @"detailView":self.topicDescription, @"yesVote":self.up, @"noVote":self.down,  @"join":self.join, @"picture":self.image, @"card":self.cardView, @"share":self.share, @"report":self.report };
    
    
    NSArray *constraint_POS_V_name = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15@999-[nameView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_V_picture = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameView]-5@998-[picture]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_V_detail = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[picture]-5@997-[detailView]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];

    
    NSArray *constraint_POS_V_yesVote = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10@996-[yesVote]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_V_noVote = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10@995-[noVote]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_V_join = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesVote]-10@994-[join]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_V_share = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noVote]-10@993-[share]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_V_report = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noVote]-10@993-[report]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    
    NSArray *constraint_POS_H_button = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20@992-[yesVote]-20@991-[noVote]-20@990-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_H_button2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15@800-[share]-5@801-[join]-5@802-[report]-15@803-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_V_card = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5@986-[card]-5@985-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_H_card = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10@984-[card]-10@983-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    [self.contentView addConstraints:constraint_POS_V_name];
    [self.contentView addConstraints:constraint_POS_V_picture];
    [self.contentView addConstraints:constraint_POS_V_detail];
    [self.contentView addConstraints:constraint_POS_V_yesVote];
    [self.contentView addConstraints:constraint_POS_V_noVote];
    [self.contentView addConstraints:constraint_POS_V_join];
    [self.contentView addConstraints:constraint_POS_H_button];
    [self.contentView addConstraints:constraint_POS_H_button2];
    [self.contentView addConstraints:constraint_POS_H_card];
    [self.contentView addConstraints:constraint_POS_V_card];
    [self.contentView addConstraints:constraint_POS_V_share];
    [self.contentView addConstraints:constraint_POS_V_report];
}

-(void)imageSetup
{
    self.image.clipsToBounds = YES;
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    //self.image.backgroundColor = [UIColor blueColor];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
-(void)updateConstraints {
    if (!self.didSetupConstraints) {
        [self cellLayout];
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}
*/
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
            //self.image.contentMode = UIViewContentModeScaleAspectFit;
        }


    }
    
}

@end
