//
//  contactDetailsVC.m
//  app
//
//  Created by kiddjacky on 5/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "contactDetailsVC.h"
#import <Parse/Parse.h>

#import <ParseUI/ParseUI.h>

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
@end


@implementation contactDetailsVC

-(void)viewDidLoad {
    [super viewDidLoad];
  [self loadView];
    
    _chat = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.chat setTitle:@"Chat" forState:UIControlStateNormal];
    [self.chat setBackgroundColor:[UIColor greenColor]];
    self.chat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.chatContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chatContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.chatContainerView addSubview:self.chat];
    [self.view addSubview:self.chatContainerView];
    
    NSDictionary *viewsDictionary = @{@"chat_view":self.chatContainerView};
    
    NSArray *constraint_POS_V_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[chat_view]-100-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    NSArray *constraint_POS_H_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[chat_view]-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    [self.view addConstraints:constraint_POS_V_chat];
    [self.view addConstraints:constraint_POS_H_chat];
    
    
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
@end
