//
//  contactDetailsVC.m
//  app
//
//  Created by kiddjacky on 5/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "contactDetailsVC.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import <ParseUI/ParseUI.h>
#import "DiscoverUser.h"

#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "ChatView.h"
#import "Contacts.h"

@interface contactDetailsVC ()
@property UIButton *chat;
@property UILabel *userFullName;
@property UILabel *age;
@property UILabel *interest;
@property UILabel *selfDescription;

@property UIView *chatContainerView;
@property UIView *labelContainerView;
@property UILabel *label;
@end


@implementation contactDetailsVC

-(void)viewDidLoad {
    [super viewDidLoad];
    [self loadView];
    [self loadUser];
    
    self.label = [[UILabel alloc] init];
//  [self.label setBackgroundColor:[UIColor redColor]];
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 10;
    NSString *full_name = [NSString stringWithFormat:@"Full name = %@", self.contact.userFullName ];
    NSString *age = [NSString stringWithFormat:@"Age = %@", self.contact.age ];
    NSString *sex = [NSString stringWithFormat:@"Sex = %@", self.contact.sex ];
    NSString *interest = [NSString stringWithFormat:@"interest = %@", self.contact.interest ];
    NSString *self_description = [NSString stringWithFormat:@"self description = %@", self.contact.selfDescription ];

    self.label.text = [NSString stringWithFormat:@"%@ \r %@ \r %@ \r %@ \r %@", full_name, age, sex, interest, self_description];
    [self.label setFont:[UIFont fontWithName:@"System" size:30]];
    NSLog(@"text label =  %@", self.label.text);
    self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.label sizeToFit];
    self.labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.labelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.labelContainerView setBackgroundColor:[UIColor blueColor]];
    [self.labelContainerView addSubview:self.label];
    [self.view addSubview:self.labelContainerView];

    
    _chat = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chat.layer.cornerRadius = 10;
    self.chat.clipsToBounds = YES;
    [self.chat setTitle:@"Chat" forState:UIControlStateNormal];
    [self.chat setBackgroundColor:[UIColor blueColor]];
    self.chat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.chatContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chatContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.chatContainerView addSubview:self.chat];
    [self.view addSubview:self.chatContainerView];
    
    NSDictionary *viewsDictionary = @{@"chat_view":self.chatContainerView, @"labelView":self.labelContainerView};
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.1
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.1
                                                           constant:0.0]];


    
    NSArray *constraint_POS_V_label = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[labelView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_H_label = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[labelView]-50-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
 
    
    
    NSArray *constraint_POS_V_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chat_view]-50-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_H_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[chat_view]-50-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    [self.view addConstraints:constraint_POS_V_chat];
    [self.view addConstraints:constraint_POS_H_chat];
    [self.view addConstraints:constraint_POS_V_label];
    [self.view addConstraints:constraint_POS_H_label];
    
    
    [self.chat addTarget:self action:@selector(actionChat) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    
}

-(void)actionChat
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:self.contact.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             PFUser *user = [objects firstObject];
             //CreateMessageItem([PFUser currentUser], discoverId, discover[PF_GROUPS_NAME]);
             NSString *discoverId = StartPrivateChat([PFUser currentUser], user);
             //---------------------------------------------------------------------------------------------------------------------------------------------
             ChatView *chatView = [[ChatView alloc] initWith:discoverId];
             chatView.hidesBottomBarWhenPushed = YES;
             [self.navigationController pushViewController:chatView animated:YES];
         }
     }];
    
    //NSString *discoverId = discover.objectId;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
}



- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    
    //    PFUser *user = [PFUser currentUser];
    
    
    //    self.label.text = user[PF_USER_FULLNAME];
    NSLog(@"debug = %@", self.contact.userName);
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:self.contact.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             NSLog(@"debug 2 = %@ objects count = %lu" , self.contact.userName, (unsigned long)[objects count]);
             PFUser *user = [objects firstObject];
             //CreateMessageItem([PFUser currentUser], discoverId, discover[PF_GROUPS_NAME]);
//             self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
//             [self.imageUser setFile:user[PF_USER_PICTURE]];
//             [self.imageUser loadInBackground];
         }
     }];
    
}


@end
