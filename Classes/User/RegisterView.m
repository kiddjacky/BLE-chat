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
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "pushnotification.h"

#import "RegisterView.h"
#import "DatabaseAvailability.h"
#import "utilities.h"
#import "AppDelegate.h"
#import "DiscoverUser.h"
#import "CurrentUser.h"
#import "Contacts.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RegisterView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RegisterView

@synthesize cellName, cellPassword, cellEmail, cellButton;
@synthesize fieldName, fieldPassword, fieldEmail;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Register";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	[fieldName becomeFirstResponder];
    if (!self.managedObjectContext) [self useDocument];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegister:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name		= fieldName.text;
	NSString *password	= fieldPassword.text;
	NSString *email		= [fieldEmail.text lowercaseString];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([name length] == 0)		{ [ProgressHUD showError:@"Name must be set."]; return; }
	if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }
	if ([email length] == 0)	{ [ProgressHUD showError:@"Email must be set."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[ProgressHUD show:@"Please wait..." Interaction:NO];

	PFUser *user = [PFUser user];
	user.username = email;
	user.password = password;
	user.email = email;
	user[PF_USER_EMAILCOPY] = email;
	user[PF_USER_FULLNAME] = name;
	user[PF_USER_FULLNAME_LOWER] = [name lowercaseString];
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			ParsePushUserAssign();
			[ProgressHUD showSuccess:@"Succeed."];
            //NSManagedObjectContext *context=((AppDelegate *) [UIApplication sharedApplication].delegate).DiscoverDatabaseContext;
            [self loadUserDatabase:user.username fromContext:self.managedObjectContext];
            //post notification
            //setup notification to other view controller that the context is avaiable.

        
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
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
	if (indexPath.row == 0) return cellName;
	if (indexPath.row == 1) return cellPassword;
	if (indexPath.row == 2) return cellEmail;
	if (indexPath.row == 3) return cellButton;
	return nil;
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldName)
	{
		[fieldPassword becomeFirstResponder];
	}
	if (textField == fieldPassword)
	{
		[fieldEmail becomeFirstResponder];
	}
	if (textField == fieldEmail)
	{
		[self actionRegister:nil];
	}
	return YES;
}

-(void) loadUserDatabase:(NSString *)userName fromContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentUser"];
    request.predicate = nil;
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //delete all existing database
    //[request release];
    for(NSManagedObject *user in matches) {
        [context deleteObject:user];
    }
    /* don't remove discover user
    NSFetchRequest *dis_request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
    request.predicate = nil;
    NSError *dis_error;
    NSArray *dis_matches = [context executeFetchRequest:dis_request error:&dis_error];
    
    //[request release];
    for(NSManagedObject *user in dis_matches) {
        [context deleteObject:user];
    }
    */
    NSFetchRequest *con_request = [NSFetchRequest fetchRequestWithEntityName:@"Contacts"];
    request.predicate = nil;
    NSError *con_error;
    NSArray *con_matches = [context executeFetchRequest:con_request error:&con_error];
    
    //[request release];
    for(NSManagedObject *user in con_matches) {
        [context deleteObject:user];
    }
    
    
    NSError *saveError = nil;
    [context save:&saveError];
    
    //load new database
    CurrentUser *current_user = nil;
    NSLog(@"setup the current user after login");
    PFUser *user = [PFUser currentUser];
    NSLog(@"setup setp1 load currentUser %@", user.username);
    current_user = [NSEntityDescription
                    insertNewObjectForEntityForName:@"CurrentUser"
                    inManagedObjectContext:self.managedObjectContext];
    
    current_user.userName = user[PF_USER_USERNAME];
    NSLog(@"loaded1");
    current_user.userFullName = user[PF_USER_FULLNAME];
    NSLog(@"loaded2");
    current_user.sex = user[PF_USER_SEX];
    NSLog(@"loaded3");
    current_user.birthday = user[PF_USER_BIRTHDAY];
    NSLog(@"loaded4");
    current_user.interest = user[PF_USER_INTEREST];
    NSLog(@"loaded5");
    current_user.selfDescription = user[PF_USER_SELF_DESCRIPTION];
    current_user.contactList = user[PF_USER_CONTACTS];
    NSLog(@"user name is %@, contact list is %@", current_user.userName, current_user.contactList);

    
    NSDictionary *userInfo = self.managedObjectContext ? @{DatabaseAvailabilityContext : self.managedObjectContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
}


#pragma mark - UIManagedDocument
- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"BLE_Document"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  //[self refresh];
                  NSLog(@"create uidocument");
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                NSLog(@"open uidocument");
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
        NSLog(@"just use ui document");
    }
}

@end
