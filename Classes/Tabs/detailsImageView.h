//
//  detailsImageView.h
//  app
//
//  Created by Daniel Lau on 8/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface detailsImageView : UIViewController {
    UIImageView* mImageView;
    UIImage *mImg;

}

@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIImage *mImg;

@end
