//
//  feedbackCell.m
//  app
//
//  Created by kiddjacky on 9/20/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "feedbackCell.h"

@implementation feedbackCell

@synthesize cardView = _cardView;
@synthesize topic = _topic;
@synthesize topicDescription = _topicDescription;
@synthesize image = _image;

@synthesize join = _join;
@synthesize share = _share;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self cardSetup];
        //[self imageSetup];
        [self cellLayout];
        //[self drawButton];
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
    self.topic.text = @"Leave Us your feedback!";
    //self.topic.backgroundColor = [UIColor redColor];
    //self.topic.text = @"test";
    [self.contentView addSubview:self.topic];
    
    _topicDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topicDescription.translatesAutoresizingMaskIntoConstraints = NO;
    self.topicDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.topicDescription.numberOfLines = 0;
    self.topicDescription.text = @"Please leave us your thought about the discussion topic, your feeling about the app, or any app problem!";
    //self.topicDescription.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.topicDescription];
    
    _image = [[PFImageView alloc] initWithFrame:CGRectZero];
    self.image.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.image];
    
    _join = [[UIButton alloc] initWithFrame:CGRectZero];
    self.join.translatesAutoresizingMaskIntoConstraints = NO;
    [self.join setTitle:@"Feedback" forState:UIControlStateNormal];
    [self.join setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //self.join.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:self.join];
    
    _share = [[UIButton alloc] initWithFrame:CGRectZero];
    self.share.translatesAutoresizingMaskIntoConstraints = NO;
    [self.share setTitle:@"Share" forState:UIControlStateNormal];
    [self.share setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.share];
    
    
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
                                                                  constant:160]];
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
                                                                  constant:160]];
    
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
    
    // Width constraint, full of parent view width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.join
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.share
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0]];
    
    //relative position constriants
    NSDictionary *viewsDictionary = @{@"nameView":self.topic, @"detailView":self.topicDescription,  @"join":self.join, @"picture":self.image, @"card":self.cardView, @"share":self.share };
    
    
    NSArray *constraint_POS_V_name = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[nameView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    /*
    NSArray *constraint_POS_V_picture = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameView]-5-[picture]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    
    NSArray *constraint_POS_V_detail = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[picture]-5-[detailView]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
     */
    
    NSArray *constraint_POS_V_detail = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameView]-10-[detailView]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    
    NSArray *constraint_POS_V_join = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10-[join]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_V_share = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-10-[share]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_H_button = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[join]-10-[share]-10-|"
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
    //[self.contentView addConstraints:constraint_POS_V_picture];
    [self.contentView addConstraints:constraint_POS_V_detail];
    [self.contentView addConstraints:constraint_POS_V_join];
    [self.contentView addConstraints:constraint_POS_H_button];
    [self.contentView addConstraints:constraint_POS_H_card];
    [self.contentView addConstraints:constraint_POS_V_card];
    [self.contentView addConstraints:constraint_POS_V_share];
}




- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
