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


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
