//
//  Feedback.m
//  app
//
//  Created by kiddjacky on 12/5/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "Feedback.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"


@interface Feedback ()
@property (strong, nonatomic) UILabel *feedbackTitle;
@property (strong, nonatomic) UITextView *feedbackText;
@end

@implementation Feedback
@synthesize feedbackText;
@synthesize feedbackTitle;
@synthesize feedbackType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                              style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedback)];
 
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.feedbackTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.feedbackTitle.translatesAutoresizingMaskIntoConstraints = NO;
    self.feedbackTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.feedbackTitle.numberOfLines = 0;
    self.feedbackTitle.textAlignment =  NSTextAlignmentCenter;
    //self.feedbackTitle.textColor = [UIColor whiteColor];
    //self.feedbackTitle.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    //self.topic.backgroundColor = [UIColor redColor];
    //self.topic.text = @"test";
    [self.view addSubview:self.feedbackTitle];
    
    self.feedbackText = [[UITextView alloc] initWithFrame:CGRectZero];
    self.feedbackText.translatesAutoresizingMaskIntoConstraints = NO;
    self.feedbackText.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.feedbackText];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackTitle
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackTitle
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackText
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackText
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:200]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackText
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    
    NSDictionary *viewsDictionary = @{@"titleView":self.feedbackTitle, @"textView":self.feedbackText};
    
    
    NSArray *constraint_POS_V_name = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15@999-[titleView]-15-[textView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    [self.view addConstraints:constraint_POS_V_name];
    
    
    if ([self.feedbackType intValue]==0) {
       self.feedbackTitle.text = @"Please write down your feedback for BlueWhale Chat, and Thank you very much for your caring!";
    }
    else {
       self.feedbackTitle.text = @"Please report anything that violation our EULA or any abusive user's information, we will follow up with you! Thank you very much!";
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.view endEditing:YES];
}

-(void)sendFeedback {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if([self.feedbackType intValue]== 0) {
        params[@"feedback"] = self.feedbackText.text;
        [PFCloud callFunctionInBackground:@"userFeedback" withParameters:params];
        
    } else {
        params[@"report"] = self.feedbackText.text;
        [PFCloud callFunctionInBackground:@"userReport_setting" withParameters:params];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
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
