//
//  detailsView.m
//  app
//
//  Created by kiddjacky on 4/28/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "detailsView.h"
#import <MapKit/MapKit.h>
#import "DiscoverUser.h"

#import <Parse/Parse.h>

#import <ParseUI/ParseUI.h>
#import <QuartzCore/QuartzCore.h>

#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "ChatView.h"
#import "Contacts.h"
#import "CurrentUser.h"
#import "DatabaseAvailability.h"

@interface detailsView ()
@property MKMapView *mapView;
@property UIView *mapContainerView;
@property UIView *pokeContainerView;
@property UIView *chatContainerView;
@property UIView *imageContainerView;
@property UIView *labelContainerView;
@property UIButton *poke;
@property UIButton *chat;
@property PFImageView *imageUser;
@property UILabel *label;
@property UILabel *subLabel;
@property UIView *subLabelContainerView;

@end


@implementation detailsView

@synthesize location;

-(void)viewDidLoad {
    [super viewDidLoad];
    self.imageUser = [[PFImageView alloc] init];
    [self loadView];
    [self loadUser];
    
    


    //self.imageUser.layer.cornerRadius = 20;
    self.imageUser.layer.masksToBounds = YES;
//    [self.imageUser setBackgroundColor:[UIColor grayColor]];
    self.imageUser.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.imageContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageContainerView addSubview:self.imageUser];
    [self.view addSubview:self.imageContainerView];

    self.label = [[UILabel alloc] init];
    //   [self.label setBackgroundColor:[UIColor redColor]];
    self.label.text = self.discoverUser.userFullName;
    [self.label setFont:[UIFont fontWithName:@"System" size:30]];
    NSLog(@"text label =  %@", self.label.text);
    self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.labelContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.labelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.labelContainerView addSubview:self.label];
    [self.view addSubview:self.labelContainerView];
    
    //sub label
    self.subLabel = [[UILabel alloc] init];
    //   [self.label setBackgroundColor:[UIColor redColor]];
    //self.subLabel.text = self.discoverUser.description;
    [self.subLabel setFont:[UIFont fontWithName:@"System" size:20]];
    NSLog(@"sub label =  %@", self.subLabel.text);
    self.subLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.subLabelContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.subLabelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.subLabelContainerView addSubview:self.subLabel];
    [self.view addSubview:self.subLabelContainerView];

    
    
    //self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    _poke = [UIButton buttonWithType:UIButtonTypeCustom];
    self.poke.layer.cornerRadius = 10;
    self.poke.clipsToBounds = YES;
    [self.poke setTitle:@"Add" forState:UIControlStateNormal];
   [self.poke setBackgroundColor:[UIColor blueColor]];

    self.poke.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    _chat = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chat.layer.cornerRadius = 10;
    self.chat.clipsToBounds = YES;
    [self.chat setTitle:@"Chat" forState:UIControlStateNormal];
    [self.chat setBackgroundColor:[UIColor blueColor]];
    self.chat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.chatContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chatContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pokeContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pokeContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.chatContainerView addSubview:self.chat];
    [self.pokeContainerView addSubview:self.poke];
    
    [self.view addSubview:self.chatContainerView];
    [self.view addSubview:self.pokeContainerView];
    

    
    self.mapContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mapContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _mapView = [[MKMapView alloc] initWithFrame:self.mapContainerView.frame];
    //self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.mapContainerView addSubview:self.mapView];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 1000, 1000);
    [self.mapView setRegion:region animated:NO];
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = location.coordinate;
    [self.mapView addAnnotation:pa];
    //self.mapView.layer.cornerRadius = 5;
    //self.mapView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.mapContainerView];
    
    // Width constraint, full of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.5
                                                           constant:0]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0.0]];
    /*
    // Center vertically
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    */
    
    NSDictionary *viewsDictionary = @{@"mapView":self.mapContainerView, @"poke_view":self.pokeContainerView, @"chat_view":self.chatContainerView, @"imageView":self.imageContainerView, @"labelView":self.labelContainerView, @"subLabelView":self.subLabelContainerView};
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:80.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:80.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
 
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:100]];
 
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.subLabelContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:30]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.subLabelContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:200]];

    NSArray *constraint_POS_V_image = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[imageView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_H_image = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[imageView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_V_label = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[labelView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

    NSArray *constraint_POS_H_label = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-20-[labelView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_V_subLabel = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[labelView]-10-[subLabelView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *constraint_POS_H_subLabel = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-20-[subLabelView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView]-20-[mapView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
  
    NSArray *constraint_POS_V_button1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mapView]-20-[poke_view]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
 
    NSArray *constraint_POS_V_button2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mapView]-20-[chat_view]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_H_button1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[poke_view]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_POS_H_button2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[poke_view]-20-[chat_view]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    NSArray *constraint_POS_H_button3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[chat_view]-20-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pokeContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.1
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.1
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.pokeContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    /*NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[mapView]-10-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    */
    //[self.view addConstraints:constraint_POS_H];
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_V_image];
    [self.view addConstraints:constraint_POS_H_image];
    [self.view addConstraints:constraint_POS_V_label];
    [self.view addConstraints:constraint_POS_H_label];
    [self.view addConstraints:constraint_POS_V_subLabel];
    [self.view addConstraints:constraint_POS_H_subLabel];
    [self.view addConstraints:constraint_POS_H_button1];
    [self.view addConstraints:constraint_POS_H_button2];
    [self.view addConstraints:constraint_POS_H_button3];
    [self.view addConstraints:constraint_POS_V_button1];
    [self.view addConstraints:constraint_POS_V_button2];
    
    [self.chat addTarget:self action:@selector(actionChat) forControlEvents:UIControlEventTouchUpInside];
    [self.poke addTarget:self action:@selector(actionAdd) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    
}

-(void)actionAdd {
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    NSLog(@"discover user to be added is %@",self.discoverUser.userName);
    [query whereKey:PF_USER_USERNAME equalTo:self.discoverUser.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             NSLog(@"add discover user as contact!");
             PFUser *user = [objects firstObject];
             NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contacts"];
             request.predicate = [NSPredicate predicateWithFormat:@"userName = %@", user[PF_USER_USERNAME]];
             NSError *error;
             NSArray *matches = [self.context executeFetchRequest:request error:&error];
             Contacts *contact = nil;
             //CurrentUser *currentUser = nil;
             
             if (error) {
                 NSLog(@"request error!");
             }
             else if ([matches count]>=1) {
                     //they are already friend?
                     NSLog(@"is this user in the contact list?");
                     contact = [matches firstObject];
                     NSLog(@"the name of contact is %@", user.username);
                 
             }
             else {

                 contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts"
                                                                    inManagedObjectContext:self.context];
                 contact.userName = user.username;
                 contact.userFullName  = user[PF_USER_FULLNAME];
                 contact.sex = user[PF_USER_SEX];
                 contact.age = user[PF_USER_AGE];
                 contact.interest = user[PF_USER_INTEREST];
                 contact.selfDescription = user[PF_USER_SELF_DESCRIPTION];
                 //contact.thumbnail = user[PF_USER_THUMBNAIL];
                 /*
                 PFFile *contactThumbnail = user[PF_USER_THUMBNAIL];
                 [contactThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

                     if(!error) {
                         contact.thumbnail = data;
                         [self save_and_post];
                     }
                 }];
                  */
                 //[self save_and_post];

                 
                 
                 //add contact to current user contact list
                 PFUser *user = [PFUser currentUser];
                 NSLog(@"original contact list is %@", user[PF_USER_CONTACTS]);
                 
                 NSMutableArray *contactList = [[NSMutableArray alloc] init];
                 [contactList addObject:contact.userName];
                 [contactList addObjectsFromArray:user[PF_USER_CONTACTS]];
                 NSLog(@"now contact list is %@", contactList);
                 user[PF_USER_CONTACTS] = contactList;
                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error == nil)
                      {
                          [ProgressHUD showSuccess:@"Add Contact!"];
                      }
                      else [ProgressHUD showError:@"Network error."];
                  }];
             }
             
         }
     }];

}

-(void) save_and_post
{
    NSError *error=nil;
    
    
    
    if (![self.context save:&error]) {
        NSLog(@"Couldn't save %@", [error localizedDescription]);
    }
    
    NSLog(@"Added!");
    //setup notification to other view controller that the context is avaiable.
    NSDictionary *userInfo = self.context ? @{DatabaseAvailabilityContext : self.context } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
}

-(void)actionChat
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:self.discoverUser.userName];
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
    NSLog(@"debug = %@", self.discoverUser.userName);
    

    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:self.discoverUser.userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             NSLog(@"debug 2 = %@ objects count = %lu" , self.discoverUser.userName, (unsigned long)[objects count]);
             PFUser *user = [objects firstObject];
             //CreateMessageItem([PFUser currentUser], discoverId, discover[PF_GROUPS_NAME]);
             self.subLabel.text = user[PF_USER_SELF_DESCRIPTION];
    self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
                 NSLog(@"corner radius =  %f", self.imageUser.layer.cornerRadius);
             [self.imageUser setFile:user[PF_USER_PICTURE]];
            [self.imageUser loadInBackground];
         }
     }];
    
}


@end
