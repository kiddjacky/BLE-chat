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


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self cardSetup];
        [self imageSetup];
        [self cellLayout];
        [self drawButton];
    }
    return self;
}
/*
-(void) layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor greenColor];
    //[self cardSetup];
    //[self imageSetup];
    //[self cellLayout];
    //CGFloat viewWidth = self.contentView.frame.size.width;
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
}*/


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
    //self.topic.backgroundColor = [UIColor redColor];
    //self.topic.text = @"test";
    [self.contentView addSubview:self.topic];
    
    _topicDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topicDescription.translatesAutoresizingMaskIntoConstraints = NO;
    //self.topicDescription.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.topicDescription];
    
    _image = [[PFImageView alloc] initWithFrame:CGRectZero];
    self.image.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.image];
    
    _up = [[UIButton alloc] initWithFrame:CGRectZero];
    self.up.translatesAutoresizingMaskIntoConstraints = NO;
    [self.up setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    //[self.up setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.up setTitle:@"Yes" forState:UIControlStateNormal];
    //self.up.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.up];
    
    
    _down = [[UIButton alloc] initWithFrame:CGRectZero];
    self.down.translatesAutoresizingMaskIntoConstraints = NO;
    [self.down setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.down setTitle:@"No" forState:UIControlStateNormal];
    //self.down.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.down];
    
    _join = [[UIButton alloc] initWithFrame:CGRectZero];
    self.join.translatesAutoresizingMaskIntoConstraints = NO;
    [self.down setTitle:@"Join" forState:UIControlStateNormal];
    [self.join setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //self.join.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:self.join];

    
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
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topic
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    
    
    //position
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topicDescription
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.8
                                                               constant:0]];
    // Center horizontally
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topicDescription
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0.0]];
    // set heigh to 30
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topicDescription
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0
                                                               constant:30]];
    
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
                                                               constant:280]];

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
    
    // Width constraint, full of parent view width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.up
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.down
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    // Width constraint, full of parent view width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.up
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.join
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1
                                                               constant:0]];
    
    //relative position constriants
    NSDictionary *viewsDictionary = @{@"nameView":self.topic, @"detailView":self.topicDescription, @"yesVote":self.up, @"noVote":self.down,  @"join":self.join, @"picture":self.image, @"card":self.cardView };
    
    
    NSArray *constraint_POS_V_name = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[nameView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    
    NSArray *constraint_POS_V_picture = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameView]-5-[picture]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_V_detail = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[picture]-5-[detailView]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_V_yesVote = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10-[yesVote]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_V_noVote = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10-[noVote]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_V_join = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10-[join]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_H_button = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[yesVote]-10-[join]-10-[noVote]-10-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_V_card = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[card]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_H_card = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[card]-10-|"
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
    [self.contentView addConstraints:constraint_POS_H_card];
    [self.contentView addConstraints:constraint_POS_V_card];
    
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
