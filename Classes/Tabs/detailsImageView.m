//
//  detailsImageView.m
//  app
//
//  Created by Daniel Lau on 8/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "detailsImageView.h"

@interface detailsImageView ()

@end

@implementation detailsImageView

@synthesize imageView = mImageView;
@synthesize mImg;

- (void)viewDidLoad {
    [super viewDidLoad];
     UIImageView *imgview = [[UIImageView alloc]
                            initWithFrame:CGRectMake(10, 10, 300, 400)];
    // set an animation
//    imgview.animationImages = [NSArray arrayWithObjects:
//                               [UIImage imageNamed:@"tab_discovers_2"],
//                               [UIImage imageNamed:@"AppleUSA2.jpg"], nil];
    
//    imgview.image = [UIImage imageNamed:@"tab_discovers_2"];
    [imgview setImage:self.mImg];
    imgview.animationDuration = 4.0;
    imgview.contentMode = UIViewContentModeCenter;
    [imgview startAnimating];
    [self.view addSubview:imgview];
    // Do any additional setup after loading the view.
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
