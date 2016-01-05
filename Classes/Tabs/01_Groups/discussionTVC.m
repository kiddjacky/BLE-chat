//
//  discussionTVC.m
//  app
//
//  Created by kiddjacky on 10/7/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "discussionTVC.h"
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "camera.h"
#import "images.h"
#import "pushnotification.h"
#import "utilities.h"
#import "AppDelegate.h"

@interface discussionTVC ()

@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *yesName;
@property (strong, nonatomic) IBOutlet UITextField *noName;

@property (strong, nonatomic) IBOutlet UITextView *detail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellYes;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellNo;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDescription;

//@property (strong, nonatomic) UIButton *save;
@property (strong, nonatomic) PFImageView *picture;
@property (strong, nonatomic) UIView *customeView;



@property (strong, nonatomic) PFFile *picFile;
@end

@implementation discussionTVC

@synthesize cellName, cellDescription, cellNo, cellYes;
@synthesize noName, yesName, name, detail;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Create Discussion";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStylePlain target:self action:@selector(saveDiscussion)];
    self.tableView.allowsSelection = NO;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    detail.layer.borderColor = borderColor.CGColor;
    detail.layer.borderWidth = 1.0;
    detail.layer.cornerRadius = 5.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:@"locationUpdate" object:nil];
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[PFUser currentUser][PF_USER_IS_BLACK_LIST] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [ProgressHUD showError:@"This user ID has been suspended."];
            LoginUser(self);
        } else {
            NSString *rule = @"You should NOT post content on BlueWhale that harms the feed or the BuleWhale community, including pornogarphy, bully topic. Do Not post other people's private information.";
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"Rule" message:rule delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alter addButtonWithTitle:@"Agree"];
            [alter show];
        }
    }];
    

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];

}

-(void)updateLocation
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    CLLocation *myLocation = app.currentLocation;
    self.currentLocation = myLocation;
    NSLog(@"post location now is %@", self.currentLocation);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked Cancel");
        [self handleBack];
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"You have clicked Agree");
    }
}

- (void) handleBack
{
    // pop to root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
    
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

#define MAXTOPICLENGTH 20
#define MAXNOLENGTH 10
#define MAXYESLENGTH 10
#define MAXLENGTH 100

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    if (textField == name) {
        return newLength <= MAXTOPICLENGTH || returnKey;
    }
    else if (textField == yesName) {
        return newLength <= MAXYESLENGTH || returnKey;
    }
    else if (textField == noName) {
        return newLength <= MAXNOLENGTH || returnKey;
    }
    else {
        return newLength <= MAXLENGTH || returnKey;
    }
}


#pragma mark - Table view data source
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 4;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.row == 0) {
        NSLog(@"in to cell Name");
        return cellName;
    }
    else if (indexPath.row == 1) {
                NSLog(@"in to cell yes");
        return cellYes;
    }
    else if (indexPath.row == 2) {
                NSLog(@"in to cell No");
        return cellNo;
    }
    else if (indexPath.row == 3) {
                NSLog(@"in to cell description");
        return cellDescription;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.textLabel.text = @"no data";
        return cell;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    //sectionHeaderView.backgroundColor = [UIColor cyanColor];
    
    self.picture = [[PFImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2-40), 10, 80, 80)];
    self.picture.layer.cornerRadius = self.picture.frame.size.width/2;
    self.picture.layer.masksToBounds = YES;
    //self.picture.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    //self.picture.translatesAutoresizingMaskIntoConstraints = NO;
    self.picture.userInteractionEnabled = YES;
    self.picture.clipsToBounds = YES;
    self.picture.image = [UIImage imageNamed:@"plus"];

    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(actionPhoto:)];
    
    tapGesture1.numberOfTapsRequired = 1;
    //[tapGesture1 setDelegate:self];
    [self.picture addGestureRecognizer:tapGesture1];
    
    [sectionHeaderView addSubview:self.picture];
    
    /*
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:sectionHeaderView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0
                                                                   constant:80.0]];
    
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:sectionHeaderView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:80.0]];
     */
    
    // Center horizontally
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:sectionHeaderView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0.0]];
    
    // Center horizontally
    [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 100.0f;
    }
    else {
        return 40.0f;
    }
}

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


#pragma save
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveDiscussion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"save discussion");
    if (self.name.hasText)
    {
        if ((![self.noName.text isEqualToString:@""]) && (![self.yesName.text isEqualToString:@""])) {
            
        self.group[PF_GROUPS_NAME] = self.name.text;
        self.group[PF_GROUPS_DESCRIPTION] = self.detail.text;
        //NSNumber *upNumber = [NSNumber numberWithInt:[self.yesNumber.text intValue]];
        //NSNumber *downNumber = [NSNumber numberWithInt:[self.noNumber.text intValue]];
        NSNumber *upNumber = [NSNumber numberWithInteger:0];
        NSNumber *downNumber = [NSNumber numberWithInteger:0];
        [self.group setObject:downNumber forKey:PF_GROUPS_DOWN];
        [self.group setObject:upNumber forKey:PF_GROUPS_UP];
        self.group[PF_GROUPS_DOWN_NAME] = self.noName.text;
        self.group[PF_GROUPS_UP_NAME] = self.yesName.text;
        self.group[PF_GROUPS_CREATER] = [PFUser currentUser];
        self.group[PF_GROUPS_CREATE_TIME] = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        NSArray *empty_array = [[NSArray alloc] init];
        self.group[PF_GROUPS_UP_LIST] = empty_array;
        self.group[PF_GROUPS_DOWN_LIST] = empty_array;
        self.group[PF_USER_BLOCKED_TOPICS] = empty_array;
        self.group[PF_GROUPS_FEATURE] = [NSNumber numberWithInteger:0];
        
        PFGeoPoint *postLocation = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude
                                                             longitude:self.currentLocation.coordinate.longitude];
            
            self.group[PF_GROUPS_LOCATION] = postLocation;
            
            
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
                 [self handleBack];
             }
             else [ProgressHUD showError:@"Network error."];
             
         }];
        }
        else [ProgressHUD showError:@"Choice left and right field must be set."];
    }
    else [ProgressHUD showError:@"Name field must be set."];
}


@end
