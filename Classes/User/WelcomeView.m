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

#import "AFNetworking.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "images.h"
#import "pushnotification.h"

#import "WelcomeView.h"
#import "LoginView.h"
#import "RegisterView.h"
#import "DataBaseAvailability.h"
#import "DiscoverUser.h"
#import "CurrentUser.h"
#import "Contacts.h"
#import "utilities.h"
#import "AppDelegate.h"

@implementation WelcomeView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Welcome";
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"iphone5-background.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];

    if (!self.managedObjectContext) [self useDocument];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegister:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RegisterView *registerView = [[RegisterView alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
	[self.navigationController pushViewController:registerView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LoginView *loginView = [[LoginView alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
	[self.navigationController pushViewController:loginView animated:YES];
}

#pragma mark - Facebook login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionFacebook:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:@"Signing in..." Interaction:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
    [self clearDatabase];
	[PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
	{
		if (user != nil)
		{
			if (user[PF_USER_FACEBOOKID] == nil)
			{
				[self requestFacebook:user];
			}
            else {
                NSLog(@"no fb request");
                [self userLoggedIn:user];
            }
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)requestFacebook:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FBRequest *request = [FBRequest requestForMe];
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	{
		if (error == nil)
		{
			NSDictionary *userData = (NSDictionary *)result;
			[self processFacebook:user UserData:userData];
		}
		else
		{
			[PFUser logOut];
			[ProgressHUD showError:@"Failed to fetch Facebook user data."];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"process facebook data!");
	NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFImageResponseSerializer serializer];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		UIImage *image = (UIImage *)responseObject;
		//-----------------------------------------------------------------------------------------------------------------------------------------
		UIImage *picture = ResizeImage(image, 280, 280);
		UIImage *thumbnail = ResizeImage(image, 60, 60);
		//-----------------------------------------------------------------------------------------------------------------------------------------
		PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
		[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Network error."];
		}];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
		[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Network error."];
		}];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		user[PF_USER_EMAILCOPY] = userData[@"email"];
		user[PF_USER_FULLNAME] = userData[@"name"];
		user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
		user[PF_USER_FACEBOOKID] = userData[@"id"];
		user[PF_USER_PICTURE] = filePicture;
		user[PF_USER_THUMBNAIL] = fileThumbnail;
		[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error == nil)
			{
				[self userLoggedIn:user];
			}
			else
			{
				[PFUser logOut];
				[ProgressHUD showError:error.userInfo[@"error"]];
			}
		}];
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		[PFUser logOut];
		[ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSOperationQueue mainQueue] addOperation:operation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)userLoggedIn:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ParsePushUserAssign();
    [self LoadContact];
	[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
    NSLog(@"dismiss facebook login");
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)LoadContact {
    PFUser *user = [PFUser currentUser];
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
                 //contact.pfUser = user;
                 contact.userName = user.username;
                 contact.userFullName = user[PF_USER_FULLNAME];
                 contact.sex = user[PF_USER_SEX];
                 contact.age = user[PF_USER_AGE];
                 contact.interest = user[PF_USER_INTEREST];
                 contact.selfDescription = user[PF_USER_SELF_DESCRIPTION];
                 //contact.thumbnail = user[PF_USER_THUMBNAIL];
                 NSLog(@"finished load contact!");
                 
                 if (![self.managedObjectContext save:&error]) {
                     NSLog(@"Couldn't save %@", [error localizedDescription]);
                 }
                
                 NSDictionary *userInfo = self.managedObjectContext ? @{DatabaseAvailabilityContext : self.managedObjectContext } : nil;
                 [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
             }
         }];
    }
}

-(void)clearDatabase
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
    
    NSDictionary *userInfo = self.managedObjectContext ? @{DatabaseAvailabilityContext : self.managedObjectContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification object:self userInfo:userInfo];
    NSLog(@"clear all contacts!");
     
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
                  NSLog(@"create welcome uidocument");
                  //[self clearDatabase];
                //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                NSLog(@"open welcome uidocument");
                //[self clearDatabase];
                //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
        NSLog(@"just use welcome uidocument");
        //[self clearDatabase];
        //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_LOGOUT object:nil];
    }
}

@end
