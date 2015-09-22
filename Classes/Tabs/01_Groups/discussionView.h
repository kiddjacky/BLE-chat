//
//  discussionView.h
//  app
//
//  Created by kiddjacky on 8/30/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface discussionView : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) PFObject *group;

@end
