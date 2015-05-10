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

@interface detailsView ()
@property MKMapView *mapView;
@property UIView *mapContainerView;
@property UIView *pokeContainerView;
@property UIView *chatContainerView;
@property UIButton *poke;
@property UIButton *chat;

@end


@implementation detailsView

@synthesize location;

-(void)viewDidLoad {
    [super viewDidLoad];
    [self loadView];
    
    //self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    _poke = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.poke setTitle:@"Poke" forState:UIControlStateNormal];
    [self.poke setBackgroundColor:[UIColor greenColor]];
    self.poke.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    _chat = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.chat setTitle:@"Chat" forState:UIControlStateNormal];
    [self.chat setBackgroundColor:[UIColor greenColor]];
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
    
    // Width constraint, half of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    /*
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.5
                                                           constant:0]];
    */
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapContainerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
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
    
    NSDictionary *viewsDictionary = @{@"mapView":self.mapContainerView, @"poke_view":self.pokeContainerView, @"chat_view":self.chatContainerView};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[mapView]-100-|"
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
    /*
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[mapView]-10-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    */
    //[self.view addConstraints:constraint_POS_H];
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H_button1];
    [self.view addConstraints:constraint_POS_H_button2];
    [self.view addConstraints:constraint_POS_H_button3];
    [self.view addConstraints:constraint_POS_V_button1];
    [self.view addConstraints:constraint_POS_V_button2];
    
    
}

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    
}



@end
