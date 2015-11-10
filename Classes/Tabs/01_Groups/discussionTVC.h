//
//  discussionTVC.h
//  app
//
//  Created by kiddjacky on 10/7/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface discussionTVC : UITableViewController  <UIActionSheetDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate >

@property (strong, nonatomic) PFObject *group;

@end
