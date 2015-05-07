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

@end


@implementation detailsView

@synthesize location;

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIButton *poke_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:poke_button];
    [poke_button setTitle:@"Poke" forState:UIControlStateNormal];
    [poke_button sizeToFit];
    poke_button.center = CGPointMake(100,300);
    
    UIButton *chat_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:chat_button];
    [chat_button setTitle:@"Chat" forState:UIControlStateNormal];
    [chat_button sizeToFit];
    chat_button.center = CGPointMake(300,300);
    
    //MKAnnotationView *map_view = [[MKAnnotationView alloc] init];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(20, 20, 200, 200)];
    [self.view addSubview:self.mapView];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 1000, 1000);
    [self.mapView setRegion:region animated:NO];
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = location.coordinate;
    [self.mapView addAnnotation:pa];
    
    /*
    NSDictionary *viewsDictionary = @{@"mapView":self.mapView};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[mapView]-50-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[mapView]-10-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    [self.view addConstraints:constraint_POS_H];
    [self.view addConstraints:constraint_POS_V];
    */
}




@end
