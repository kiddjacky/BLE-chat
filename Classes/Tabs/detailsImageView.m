//
//  detailsImageView.m
//  app
//
//  Created by Daniel Lau on 8/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "detailsImageView.h"

@interface detailsImageView ()
@property UIView *imageContainerView;
@end

@implementation detailsImageView

- (void)viewDidLoad {
    [super viewDidLoad];
     self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    // set an animation
//    imgview.animationImages = [NSArray arrayWithObjects:
//                               [UIImage imageNamed:@"tab_discovers_2"],
//                               [UIImage imageNamed:@"AppleUSA2.jpg"], nil];
    
//    imgview.image = [UIImage imageNamed:@"tab_discovers_2"];
    [self.imageView setImage:self.mImg];
    //imgview.animationDuration = 4.0;
    //imgview.contentMode = UIViewContentModeCenter;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //[imgview startAnimating];
    [self.view addSubview:self.imageView];

    // Do any additional setup after loading the view.
    // Width constraint, full of parent view width
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
     // Center vertically
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:self.view
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0
     constant:0.0]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
