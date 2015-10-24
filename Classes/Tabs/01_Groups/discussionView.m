//
//  discussionView.m
//  app
//
//  Created by kiddjacky on 8/30/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "discussionView.h"

#import "ProgressHUD.h"

#import "AppConstant.h"
#import "camera.h"
#import "images.h"
#import "pushnotification.h"
#import "utilities.h"

@interface discussionView ()
@property (strong, nonatomic) UITextField *name;
@property (strong, nonatomic) UITextView *detail;
@property (strong, nonatomic) UITextField *noNumber;
@property (strong, nonatomic) UITextField *noName;
@property (strong, nonatomic) UITextField *yesNumber;
@property (strong, nonatomic) UITextField *yesName;

@property (strong, nonatomic) UIButton *save;
@property (strong, nonatomic) PFImageView *picture;
@property (strong, nonatomic) UIView *customeView;

@property (strong, nonatomic) PFFile *picFile;
@end

@implementation discussionView



- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadView];
    //set textfield delegate
    //self.name.delegate = self;
    //self.noName.delegate = self;
    //self.noNumber.delegate = self;
    //self.yesName.delegate = self;
    //self.yesNumber.delegate = self;
    
    
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    self.picture = [[PFImageView alloc] initWithFrame:CGRectZero];
    self.picture.layer.masksToBounds = YES;
    self.picture.translatesAutoresizingMaskIntoConstraints = NO;
    self.picture.userInteractionEnabled = YES;
    self.picture.clipsToBounds = YES;
    
    if (self.group[PF_GROUPS_PICTURE]==nil) {
        UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
        self.picture.image = def_image;
    } else {
        self.picture.file = self.group[PF_GROUPS_PICTURE];
        [self.picture loadInBackground];
    }
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(actionPhoto:)];
    
    tapGesture1.numberOfTapsRequired = 1;
    [self.picture addGestureRecognizer:tapGesture1];
    [self.view addSubview:self.picture];
    
    
    _name = [[UITextField alloc] initWithFrame:CGRectZero];
    self.name.translatesAutoresizingMaskIntoConstraints = NO;
    self.name.text = self.group[PF_GROUPS_NAME];
    self.name.layer.masksToBounds = YES;
    self.name.layer.borderWidth = 1.0f;
    [self.view addSubview:self.name];
    
    _detail = [[UITextView alloc] initWithFrame:CGRectZero];
    self.detail.translatesAutoresizingMaskIntoConstraints = NO;
    self.detail.text = self.group[PF_GROUPS_DESCRIPTION]; //@"Let's Vote and join the discussion!";
    self.detail.layer.masksToBounds = YES;
    self.detail.layer.borderWidth = 1.0f;
    [self.view addSubview:self.detail];
    
    _yesName = [[UITextField alloc] initWithFrame:CGRectZero];
    self.yesName.translatesAutoresizingMaskIntoConstraints = NO;
    self.yesName.text = self.group[PF_GROUPS_UP_NAME];
    self.yesName.layer.masksToBounds = YES;
    self.yesName.layer.borderWidth = 1.0f;
    [self.view addSubview:self.yesName];
    
    _yesNumber = [[UITextField alloc] initWithFrame:CGRectZero];
    self.yesNumber.translatesAutoresizingMaskIntoConstraints = NO;
    self.yesNumber.text = [self.group[PF_GROUPS_UP] stringValue];
    self.yesNumber.layer.masksToBounds = YES;
    self.yesNumber.layer.borderWidth = 1.0f;
    [self.view addSubview:self.yesNumber];
    
    _noName = [[UITextField alloc] initWithFrame:CGRectZero];
    self.noName.translatesAutoresizingMaskIntoConstraints = NO;
    self.noName.text = self.group[PF_GROUPS_DOWN_NAME];
    self.noName.layer.masksToBounds = YES;
    self.noName.layer.borderWidth = 1.0f;
    [self.view addSubview:self.noName];
    
    _noNumber = [[UITextField alloc] initWithFrame:CGRectZero];
    self.noNumber.translatesAutoresizingMaskIntoConstraints = NO;
    self.noNumber.text = [self.group[PF_GROUPS_DOWN] stringValue];
    self.noNumber.layer.masksToBounds = YES;
    self.noNumber.layer.borderWidth = 1.0f;
    [self.view addSubview:self.noNumber];
    
    _save = [[UIButton alloc] initWithFrame:CGRectZero];
    self.save.translatesAutoresizingMaskIntoConstraints = NO;
    self.save.layer.masksToBounds= YES;
    self.save.layer.borderWidth = 1.0f;
    self.save.backgroundColor = [UIColor whiteColor];
    [self.save setTitle:@"Save" forState:UIControlStateNormal];
    [self.save setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:self.save];

    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.save
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.save
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.save
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:50]];

    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:80]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:80]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
    
    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.detail
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.detail
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.3
                                                           constant:0]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.detail
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.yesNumber
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.yesName
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noNumber
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noName
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    

    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.yesName
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.noName
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.yesNumber
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.noNumber
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    
    NSDictionary *viewsDictionary = @{@"nameView":self.name, @"detailView":self.detail, @"yesVote":self.yesNumber, @"noVote":self.noNumber, @"yesName":self.yesName, @"noName":self.noName, @"save":self.save, @"picture":self.picture};
    
    NSArray *constraint_POS_V_picture = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10@999-[picture]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_V_name = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[picture]-10@998-[nameView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];

    NSArray *constraint_POS_V_detail = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameView]-10@997-[detailView]"
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
    
    NSArray *constraint_POS_V_yesName = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesVote]-10@994-[yesName]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_V_noName = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noVote]-10@993-[noName]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_H_Vote = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20@992-[yesVote]-20@991-[noVote]-20@990-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_H_Name = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20@989-[yesName]-20@988-[noName]-20@987-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *constraint_POS_V_save = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesName]-10@986-[save]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    [self.view addConstraints:constraint_POS_V_picture];
    [self.view addConstraints:constraint_POS_V_name];
    [self.view addConstraints:constraint_POS_V_detail];
    [self.view addConstraints:constraint_POS_V_yesVote];
    [self.view addConstraints:constraint_POS_V_noVote];
    [self.view addConstraints:constraint_POS_V_yesName];
    [self.view addConstraints:constraint_POS_V_noName];
    [self.view addConstraints:constraint_POS_H_Vote];
    [self.view addConstraints:constraint_POS_H_Name];
    [self.view addConstraints:constraint_POS_V_save];
    
    

    [self.save addTarget:self action:@selector(saveDiscussion:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.customeView = [[UIView alloc] initWithFrame:applicationFrame];
    self.customeView.backgroundColor = [UIColor whiteColor];
    self.view = self.customeView;
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveDiscussion:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"save discussion");
    if (self.name.hasText)
    {
        self.group[PF_GROUPS_NAME] = self.name.text;
        self.group[PF_GROUPS_DESCRIPTION] = self.detail.text;
        NSNumber *upNumber = [NSNumber numberWithInt:[self.yesNumber.text intValue]];
        NSNumber *downNumber = [NSNumber numberWithInt:[self.noNumber.text intValue]];
        [self.group setObject:downNumber forKey:PF_GROUPS_DOWN];
        [self.group setObject:upNumber forKey:PF_GROUPS_UP];
        self.group[PF_GROUPS_DOWN_NAME] = self.noName.text;
        self.group[PF_GROUPS_UP_NAME] = self.yesName.text;
        [self.group setObject:[NSNumber numberWithInteger:0] forKey:PF_GROUPS_NUM_CHAT];
        if (self.picFile) {
            [self.group setObject:self.picFile forKey:PF_GROUPS_PICTURE];
            NSLog(@"setup group info");
        }
        [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
                 [ProgressHUD showSuccess:@"Discussion Saved."];
             }
             else [ProgressHUD showError:@"Network error."];
             
         }];
    }
    else [ProgressHUD showError:@"Name field must be set."];
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImage *picture = ResizeImage(image, 280, 280);
    //UIImage *thumbnail = ResizeImage(image, 60, 60);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.picture.image = picture;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];
    self.picFile = filePicture;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    //PFUser *user = [PFUser currentUser];
    //self.group[PF_GROUPS_PICTURE] = filePicture;

    //---------------------------------------------------------------------------------------------------------------------------------------------
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    ShouldStartPhotoLibrary(self, YES);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.view endEditing:YES];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
