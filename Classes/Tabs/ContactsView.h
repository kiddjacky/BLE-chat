//
//  ContactsView.h
//  app
//
//  Created by kiddjacky on 5/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface ContactsView : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
