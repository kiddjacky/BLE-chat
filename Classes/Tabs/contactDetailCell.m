//
//  contactDetailCell.m
//  app
//
//  Created by kiddjacky on 8/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "contactDetailCell.h"

@implementation contactDetailCell

@synthesize title = _title;
@synthesize content = _content;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.content.lineBreakMode = NSLineBreakByWordWrapping;
        self.content.numberOfLines = 0;
        self.content.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[title]-30-[bodyLabel]-6-|" options:0 metrics:nil views:@{ @"bodyLabel": self.content, @"title":self.title }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[bodyLabel]-6-|" options:0 metrics:nil views:@{ @"bodyLabel": self.content }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[title]" options:0 metrics:nil views:@{ @"title": self.title }]];
    }
    
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    //self.content.preferredMaxLayoutWidth = CGRectGetWidth(self.content.frame);
    //self.title.preferredMaxLayoutWidth = CGRectGetWidth(self.content.frame);
}


- (void)awakeFromNib {
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
