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

@property PFImageView *imageUser;
@property UIView *imageContainerView;
@property NSMutableArray *info;
//@property UITableView *contactDetailsTV;
//@property UIView *tableContainerView;

@end


@implementation contactDetailsVC
/*
- (id)initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundleName
{
    self = [super initWithNibName:nibName bundle:bundleName];
    if (self)
    {
        self.contactDetailsTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.contactDetailsTV.dataSource = self;
        self.contactDetailsTV.delegate = self;
        [self.view addSubview:self.contactDetailsTV];
        NSLog(@"add subview contact details TV");
    }
    
    return self;
}*/

-(void)viewDidLoad {
    [super viewDidLoad];
    self.imageUser = [[PFImageView alloc] init];
    [self loadView];
    [self loadUser];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    

    
    
    _chat = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chat.layer.cornerRadius = 10;
    self.chat.clipsToBounds = YES;
    [self.chat setTitle:@"Chat" forState:UIControlStateNormal];
    [self.chat setBackgroundColor:[UIColor blueColor]];
    self.chat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    

    //[self.view addConstraints:constraint_POS_V_label];
    //[self.view addConstraints:constraint_POS_H_label];
    //[self.view addConstraints:constraint_POS_V_image];
    //[self.view addConstraints:constraint_POS_H_image];
    
    
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
             //self.subLabel.text = user[PF_USER_SELF_DESCRIPTION];
             self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
             NSLog(@"corner radius =  %f", self.imageUser.layer.cornerRadius);
             [self.imageUser setFile:user[PF_USER_PICTURE]];
             [self.imageUser loadInBackground];
         }
     }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return number of rows
    NSInteger row = 1;
    self.info = [[NSMutableArray alloc] init];
    if (self.contact.age) {
        NSLog(@"age is %@", self.contact.age);
        row = row + 1;
            NSString *age = [NSString stringWithFormat:@"Age                %@", self.contact.age ];
        [self.info addObject:age];
    }
    if (![self.contact.sex isEqualToString:@""] && !(self.contact.sex == nil)) {
        row = row + 1;
                NSLog(@"sex is %@", self.contact.sex);
            NSString *sex = [NSString stringWithFormat:@"Sex               %@", self.contact.sex ];
        [self.info addObject:sex];
    }
    if (![self.contact.interest isEqualToString:@""] && !(self.contact.interest == nil)) {
                NSLog(@"interest is %@", self.contact.interest);
        row = row + 1;
            NSString *interest = [NSString stringWithFormat:@"Interest         %@", self.contact.interest ];
        [self.info addObject:interest];
    
    }
    
    if (![self.contact.selfDescription isEqualToString:@""] && !(self.contact.selfDescription == nil)) {
        NSLog(@"SD is %@", self.contact.selfDescription);
        row = row + 1;
            NSString *self_description = [NSString stringWithFormat:@"Description   %@", self.contact.selfDescription ];
        [self.info addObject:self_description];
    
    }
    NSLog(@"row is %d", row);
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //need to update contact info here

    NSString *full_name = [NSString stringWithFormat:@"Name          %@", self.contact.userFullName ];

    if(indexPath.row==0) cell.textLabel.text = full_name;
    if(indexPath.row==1) cell.textLabel.text = [self.info objectAtIndex:0];
    if(indexPath.row==2) cell.textLabel.text = [self.info objectAtIndex:1];
    if(indexPath.row==3) cell.textLabel.text = [self.info objectAtIndex:2];
    if(indexPath.row==4) cell.textLabel.text = [self.info objectAtIndex:3];
    
}

-(NSMutableAttributedString *)changeColor:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@"    "];
    NSRange greenRange = [string rangeOfString:[components objectAtIndex:0]];
    NSRange redRange = [string rangeOfString:[components objectAtIndex:1]];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString beginEditing];
    [attrString addAttribute: NSForegroundColorAttributeName
                       value:[UIColor greenColor]
                       range:greenRange];
    
    [attrString addAttribute: NSForegroundColorAttributeName
                       value:[UIColor redColor]
                       range:redRange];
    
    [attrString endEditing];
    
    return attrString;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    //sectionHeaderView.backgroundColor = [UIColor cyanColor];
    
    self.imageUser.layer.masksToBounds = YES;
    //    [self.imageUser setBackgroundColor:[UIColor grayColor]];
    self.imageUser.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.imageContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageContainerView addSubview:self.imageUser];
    
    [sectionHeaderView addSubview:self.imageContainerView];
    
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:sectionHeaderView
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                     multiplier:0
                                                                                       constant:80.0]];
    
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:sectionHeaderView
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                     multiplier:0
                                                                                       constant:80.0]];
    
    // Center horizontally
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:sectionHeaderView
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1
                                                                                       constant:0.0]];
    
    // Center horizontally
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:sectionHeaderView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0.0]];
    
    return sectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.view.frame.size.height/4;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.chatContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chatContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.chatContainerView addSubview:self.chat];
    [sectionFooterView addSubview:self.chatContainerView];
    
    NSDictionary *viewsDictionary = @{@"chat_view":self.chatContainerView};
    
    [sectionFooterView addConstraint:[NSLayoutConstraint constraintWithItem:self.chatContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:sectionFooterView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.4
                                                           constant:0.0]];
    
    [sectionFooterView addConstraint:[NSLayoutConstraint constraintWithItem:self.chatContainerView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:sectionFooterView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0.0]];
    
    
    NSArray *constraint_POS_H_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[chat_view]-50-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    

    [sectionFooterView addConstraints:constraint_POS_H_chat];
    
    return sectionFooterView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.view.frame.size.height/4;
}


@end
