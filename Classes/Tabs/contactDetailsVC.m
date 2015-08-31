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
#import "detailsImageView.h"

#import "contactDetailCell.h"

@interface contactDetailsVC ()
@property UIButton *chat;
@property UILabel *userFullName;
@property UILabel *age;
@property UILabel *interest;
@property UILabel *selfDescription;


@property UIView *labelContainerView;
@property UILabel *label;

@property PFImageView *imageUser;

@property NSMutableArray *info;
@property NSMutableArray *cellTitle;
@property PFUser *target;
@property (nonatomic, strong) contactDetailCell *prototypeCell;

@end


@implementation contactDetailsVC

-(void)viewDidLoad {
    [super viewDidLoad];
    self.imageUser = [[PFImageView alloc] init];
    [self loadView];
    [self loadUser];
    self.info = [[NSMutableArray alloc] init];
    self.cellTitle= [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView registerNib:[UINib nibWithNibName:@"contactDetailCell" bundle:nil] forCellReuseIdentifier:@"contactDetailCell"];
    self.prototypeCell  = [self.tableView dequeueReusableCellWithIdentifier:@"contactDetailCell"];
    
    _chat = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chat.layer.cornerRadius = 10;
    self.chat.clipsToBounds = YES;
    [self.chat setTitle:@"Chat" forState:UIControlStateNormal];
    [self.chat setBackgroundColor:[UIColor blueColor]];
    self.chat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
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
    if (self.target == nil)
    {
        NSLog(@"self target nil");
        
    }
    else {
             NSString *discoverId = StartPrivateChat([PFUser currentUser], self.target);
             //---------------------------------------------------------------------------------------------------------------------------------------------
             ChatView *chatView = [[ChatView alloc] initWith:discoverId];
             chatView.hidesBottomBarWhenPushed = YES;
             [self.navigationController pushViewController:chatView animated:YES];
    }
}


- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"debug = %@", self.contact.userName);
    
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:self.contact.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             NSLog(@"debug 2 = %@ objects count = %lu" , self.contact.userName, (unsigned long)[objects count]);
             self.target = [objects firstObject];

             self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
             NSLog(@"corner radius =  %f", self.imageUser.layer.cornerRadius);
             if (self.target[PF_USER_PICTURE]) {
             [self.imageUser setFile:self.target[PF_USER_PICTURE]];
             [self.imageUser loadInBackground];
             }
             else {
                 UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
                 self.imageUser.image = def_image;
             }
         }
     }];
    
}

- (void) onTap: (UITapGestureRecognizer*) tgr
{
    detailsImageView *destinationImageView = [[detailsImageView alloc] init];
    
    //    destinationImageView.mImg = [UIImage imageNamed:@"tab_discovers_2"];
    destinationImageView.mImg = self.imageUser.image;
    destinationImageView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:destinationImageView animated:NO];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return number of rows
    NSInteger row = 0;

    if (![self.contact.userFullName isEqualToString:@""] && !(self.contact.userFullName == nil)) {
        NSLog(@"user full name is %@", self.contact.userFullName);
        row = row + 1;
        NSString *title = @"Name";
        //NSString *full_name = [NSString stringWithFormat:@"Name          %@", self.contact.userFullName ];
        [self.info addObject:self.contact.userFullName];
        [self.cellTitle addObject:title];
    }
    if (![self.contact.address isEqualToString:@""] && !(self.contact.address == nil)) {
        NSLog(@"age is %@", self.contact.address);
        row = row + 1;
        //NSString *address = [NSString stringWithFormat:@"Meet At             %@", self.contact.address ];
        [self.info addObject:self.contact.address];
        NSString *title = @"Meet At";
        [self.cellTitle addObject:title];
    }
    if (![self.contact.sex isEqualToString:@""] && !(self.contact.sex == nil)) {
        row = row + 1;
                NSLog(@"sex is %@", self.contact.sex);
        //NSString *sex = [NSString stringWithFormat:@"Sex               %@", self.contact.sex ];
        [self.info addObject:self.contact.sex];
        [self.cellTitle addObject:@"Sex"];
    }
    if (![self.contact.interest isEqualToString:@""] && !(self.contact.interest == nil)) {
                NSLog(@"interest is %@", self.contact.interest);
        row = row + 1;
        //NSString *interest = [NSString stringWithFormat:@"Interest         %@", self.contact.interest ];
        [self.info addObject:self.contact.interest];
        [self.cellTitle addObject:@"Interest"];
    
    }
    
    if (![self.contact.selfDescription isEqualToString:@""] && !(self.contact.selfDescription == nil)) {
        NSLog(@"SD is %@", self.contact.selfDescription);
        row = row + 1;
           // NSString *self_description = [NSString stringWithFormat:@"Description   %@", self.contact.selfDescription ];
        [self.info addObject:self.contact.selfDescription];
        [self.cellTitle addObject:@"Signature"];
    
    }
    NSLog(@"row is %ld", (long)row);
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    contactDetailCell *cell = (contactDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"contactDetailCell" forIndexPath:indexPath];
    //contactDetailCell *cell = [[contactDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactDetailCell"];
    if (cell == nil) {
        //NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"contactDetailCell" owner:self options:nil];
        //cell = [nib objectAtIndex:0];
        cell = [[contactDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactDetailCell"];
    }
    NSLog(@"assign cell");
    cell.content.text = [self.info objectAtIndex:indexPath.row];
    cell.title.text = [self.cellTitle objectAtIndex:indexPath.row];

    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(contactDetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.content.text = [self.info objectAtIndex:indexPath.row];
    //cell.title.text = @"title";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //contactDetailCell *cell = (contactDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
    contactDetailCell *cell = self.prototypeCell;
    NSString *cellText = [self.info objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];

    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:cellText
     attributes:@
     {
     NSFontAttributeName: cellFont
     }];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(cell.content.frame.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height + 30;
    
    //CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"h=%f", size.height + 1);
    //return 1  + size.height;
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
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    //sectionHeaderView.backgroundColor = [UIColor cyanColor];
    
    self.imageUser.layer.masksToBounds = YES;
    self.imageUser.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    self.imageUser.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageUser.userInteractionEnabled = YES;
    self.imageUser.clipsToBounds = YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(onTap:)];
    
    tapGesture1.numberOfTapsRequired = 1;
    //[tapGesture1 setDelegate:self];
    [self.imageUser addGestureRecognizer:tapGesture1];
    
    [sectionHeaderView addSubview:self.imageUser];
    
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageUser
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:sectionHeaderView
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                     multiplier:0
                                                                                       constant:80.0]];
    
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageUser
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:sectionHeaderView
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                     multiplier:0
                                                                                       constant:80.0]];
    
    // Center horizontally
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageUser
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:sectionHeaderView
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1
                                                                                       constant:0.0]];
    
    // Center horizontally
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageUser
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
    return 100;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    
    //self.chatContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    self.chat.translatesAutoresizingMaskIntoConstraints = NO;
    
    //[self.chatContainerView addSubview:self.chat];
    [sectionFooterView addSubview:self.chat];
    
    NSDictionary *viewsDictionary = @{@"chat_view":self.chat};
    /*
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
    
    */
    NSArray *constraint_POS_H_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[chat_view]-50-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    
    NSArray *constraint_POS_V_chat = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[chat_view]-30-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];

    [sectionFooterView addConstraints:constraint_POS_H_chat];

    [sectionFooterView addConstraints:constraint_POS_V_chat];
    
    return sectionFooterView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}


@end
