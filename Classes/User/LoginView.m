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
/*
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
}
*/
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
            //NSManagedObjectContext *context=((AppDelegate *) [UIApplication sharedApplication].delegate).DiscoverDatabaseContext;
            [self loadUserDatabase:user.username fromContext:self.managedObjectContext];
            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //self.managedObjectContext = appDelegate.DiscoverDatabaseContext;
            //[self loadUserDatabase];
            //post notification
            //setup notification to other view controller that the context is avaiable.

            [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
            NSLog(@"dismiss login");
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

-(void) loadUserDatabase:(NSString *)userName fromContext:(NSManagedObjectContext *)context
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
    
    /*dont remove discover user
    NSFetchRequest *dis_request = [NSFetchRequest fetchRequestWithEntityName:@"DiscoverUser"];
    request.predicate = nil;
    NSError *dis_error;
    NSArray *dis_matches = [self.managedObjectContext executeFetchRequest:dis_request error:&dis_error];
    
    //[request release];
    for(NSManagedObject *user in dis_matches) {
        [self.managedObjectContext deleteObject:user];
    }
    */
    
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
                        NSLog(@"loaded6");
             //current_user.thumbnail = user[PF_USER_THUMBNAIL];
    NSLog(@"loaded7");
             current_user.contactList = user[PF_USER_CONTACTS];
                NSLog(@"loaded8");
             NSLog(@"user name is %@, contact list is %@", current_user.userName, current_user.contactList);
    
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
                          //contact.thumbnail = user[PF_USER_THUMBNAIL];
                          NSLog(@"finished load contact!");
                          NSDictionary *userInfo = self.managedObjectContext ? @{DatabaseAvailabilityContext : self.managedObjectContext } : nil;
                          [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
                      }
                  }];
                 
             }

    NSLog(@"finished load user!");
    
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
