//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "camera.h"
#import "images.h"
#import "pushnotification.h"
#import "utilities.h"

#import "ProfileView.h"
#import "DatabaseAvailability.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ProfileView() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellSex;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellInterest;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSelfDescription;

@property (strong, nonatomic) NSArray *sexArray;


@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;
@property (strong, nonatomic) IBOutlet UITextField *fieldSex;
@property (strong, nonatomic) IBOutlet UITextField *fieldInterest;
@property (strong, nonatomic) IBOutlet UITextField *fieldSelfDescription;
@property (strong, nonatomic) IBOutlet UITextField *fieldDate;


@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ProfileView

@synthesize viewHeader, imageUser;
@synthesize cellName, cellButton, cellSex, cellDate, cellInterest, cellSelfDescription;
@synthesize fieldName, fieldDate, fieldInterest, fieldSelfDescription, fieldSex;


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_profile"]];
		self.tabBarItem.title = @"Profile";
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self
																			action:@selector(actionLogout)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width / 2;
	imageUser.layer.masksToBounds = YES;
    
    //setup sex picker
    UIPickerView *sexPicker = [[UIPickerView alloc] init];
    //[sexPicker numberOfRowsInComponent:1];
    [sexPicker setDataSource:self];
    [sexPicker setDelegate:self];
    sexPicker.showsSelectionIndicator = YES;
    [fieldSex setInputView:sexPicker];
    self.sexArray = [[NSArray alloc] initWithObjects:@"Male",@"Female",@"Unknown",nil];
    
    //setup date picker
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(updateDateField:) forControlEvents:UIControlEventValueChanged];
    [fieldDate setInputView:datePicker];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
        [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
		[self loadUser];
	}
	else LoginUser(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Picker view
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.sexArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", (long)row);
    switch (row) {
        case 0:
            self.fieldSex.text = @"Male";
            break;
        case 1:
            self.fieldSex.text = @"Female";
            break;
        case 2:
            self.fieldSex.text = @"Unknown";
            break;
            
        default:
            break;
    }
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];

	[imageUser setFile:user[PF_USER_PICTURE]];
	[imageUser loadInBackground];

	fieldName.text = user[PF_USER_FULLNAME];
    fieldSex.text = user[PF_USER_SEX];
    fieldDate.text = user[PF_USER_BIRTHDAY];
    fieldInterest.text = user[PF_USER_INTEREST];
    fieldSelfDescription.text = user[PF_USER_SELF_DESCRIPTION];
 }

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *fullname = fieldName.text;
    NSString *sex = fieldSex.text;
    NSString *interest = fieldInterest.text;
    NSString *selfDescription = fieldSelfDescription.text;
    NSString *birthday = fieldDate.text;
	if ([fullname length] != 0)
	{
		PFUser *user = [PFUser currentUser];
		user[PF_USER_FULLNAME] = fullname;
		user[PF_USER_FULLNAME_LOWER] = [fullname lowercaseString];
        user[PF_USER_SEX] = sex;
        user[PF_USER_INTEREST] = interest;
        user[PF_USER_SELF_DESCRIPTION] = selfDescription;
        user[PF_USER_BIRTHDAY] = birthday;
		[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error == nil)
			{
				[ProgressHUD showSuccess:@"Saved."];
			}
			else [ProgressHUD showError:@"Network error."];
		}];
	}
	else [ProgressHUD showError:@"Name field must be set."];
}


#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.image = [UIImage imageNamed:@"profile_blank"];
	fieldName.text = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Log out", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		[PFUser logOut];
		ParsePushUserResign();
		PostNotification(NOTIFICATION_USER_LOGGED_OUT);
		[self actionCleanup];
        [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
		LoginUser(self);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ShouldStartPhotoLibrary(self, YES);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSave:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissKeyboard];
	[self saveUser];
}


-(void)updateDateField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)self.fieldDate.inputView;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yyyy";
    self.fieldDate.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:picker.date]];
}
#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *picture = ResizeImage(image, 280, 280);
	UIImage *thumbnail = ResizeImage(image, 60, 60);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.image = picture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
	[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	user[PF_USER_PICTURE] = filePicture;
	user[PF_USER_THUMBNAIL] = fileThumbnail;
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 6;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.section == 0) return cellName;
    if (indexPath.section == 1) return cellSex;
	if (indexPath.section == 2) return cellDate;
    if (indexPath.section == 3) return cellInterest;
    if (indexPath.section == 4) return cellSelfDescription;
    if (indexPath.section == 5) return cellButton;
	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = NSLocalizedString(@"Name", @"user Name");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Sex", @"sex");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Birthday", @"birthday");
            break;
        case 3:
            sectionName = NSLocalizedString(@"Interest", @"interest");
            break;
        case 4:
            sectionName = NSLocalizedString(@"Self Description", @"selfDescription");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

@end
