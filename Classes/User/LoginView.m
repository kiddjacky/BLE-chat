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

#import "LoginView.h"
#import "DataBaseAvailability.h"
#import "utilities.h"
#import "AppDelegate.h"
#import "DiscoverUser.h"
#import "CurrentUser.h"
#import "Contacts.h"


//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface LoginView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation LoginView

@synthesize cellEmail, cellPassword, cellButton;
@synthesize fieldEmail, fieldPassword;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Login";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	[fieldEmail becomeFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *email = [fieldEmail.text lowercaseString];
	NSString *password = fieldPassword.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([email length] == 0)	{ [ProgressHUD showError:@"Email must be set."]; return; }
	if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[ProgressHUD show:@"Signing in..." Interaction:NO];
	[PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error)
	{
		if (user != nil)
		{
			ParsePushUserAssign();
			[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.managedObjectContext = appDelegate.DiscoverDatabaseContext;
            [self loadUserDatabase];
            //post notification
            //setup notification to other view controller that the context is avaiable.
            NSDictionary *userInfo = self.managedObjectContext ? @{DatabaseAvailabilityContext : self.managedObjectContext } : nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
            
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
	return 3;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.row == 0) return cellEmail;
	if (indexPath.row == 1) return cellPassword;
	if (indexPath.row == 2) return cellButton;
	return nil;
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldEmail)
	{
		[fieldPassword becomeFirstResponder];
	}
	if (textField == fieldPassword)
	{
		[self actionLogin:nil];
	}
	return YES;
}

-(void) loadUserDatabase
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentUser"];
    request.predicate = nil;
    NSError *error;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //delete all existing database
    //[request release];
    for(NSManagedObject *user in matches) {
        [self.managedObjectContext deleteObject:user];
    }
    
    NSFetchRequest *dis_request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
    request.predicate = nil;
    NSError *dis_error;
    NSArray *dis_matches = [self.managedObjectContext executeFetchRequest:dis_request error:&dis_error];
    
    //[request release];
    for(NSManagedObject *user in dis_matches) {
        [self.managedObjectContext deleteObject:user];
    }
    
    NSFetchRequest *con_request = [NSFetchRequest fetchRequestWithEntityName:@"Contacts"];
    request.predicate = nil;
    NSError *con_error;
    NSArray *con_matches = [self.managedObjectContext executeFetchRequest:con_request error:&con_error];
    
    //[request release];
    for(NSManagedObject *user in con_matches) {
        [self.managedObjectContext deleteObject:user];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
    //load new database
    CurrentUser *current_user = nil;
             NSLog(@"setup the current user after login");
             PFUser *user = [PFUser currentUser];
             NSLog(@"setup setp1 load currentUser %@", user.username);
             current_user = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"CurrentUser"
                                          inManagedObjectContext:self.managedObjectContext];
             current_user.userName = user[PF_USER_USERNAME];
             current_user.userFullName = user[PF_USER_FULLNAME];
             current_user.sex = user[PF_USER_SEX];
             current_user.birthday = user[PF_USER_BIRTHDAY];
             current_user.interest = user[PF_USER_INTEREST];
             current_user.selfDescription = user[PF_USER_SELF_DESCRIPTION];
             current_user.thumbnail = user[PF_USER_THUMBNAIL];
             //current_user.contactList = user[PF_USER_CONTACTS];
             
             //NSLog(@"user name is %@, contact list is %@", current_user.userName, current_user.contactList);
             
             //load contacts
             for (NSString * contact_name in user[PF_USER_CONTACTS]) {
                 NSLog(@"setup the contact %@", contact_name);
                 PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
                 [query whereKey:PF_USER_USERNAME equalTo:contact_name];
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                  {
                      if ([objects count] != 0)
                      {
                          PFUser *user = [objects firstObject];
                          Contacts *contact = [NSEntityDescription
                                               insertNewObjectForEntityForName:@"Contacts"
                                               inManagedObjectContext:self.managedObjectContext];
                          contact.userName = user.username;
                          contact.userFullName = user[PF_USER_FULLNAME];
                          contact.sex = user[PF_USER_SEX];
                          contact.age = user[PF_USER_AGE];
                          contact.interest = user[PF_USER_INTEREST];
                          contact.selfDescription = user[PF_USER_SELF_DESCRIPTION];
                          contact.thumbnail = user[PF_USER_THUMBNAIL];
                          //SAVE CONTEXT
                          NSError *contactSaveError = nil;
                          [self.managedObjectContext save:&contactSaveError];
                      }
                  }];
                 
             }
             //load discovers
             //loadDiscover function
             
             //SAVE CONTEXT
             NSError *contactSaveError = nil;
             [self.managedObjectContext save:&contactSaveError];
             
    
}


@end
