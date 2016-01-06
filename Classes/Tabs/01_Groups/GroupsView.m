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
#import <QuartzCore/QuartzCore.h>

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"
#import "AppDelegate.h"

#import "GroupsView.h"
#import "ChatView.h"
#import "DatabaseAvailability.h"
#import "discussionCell.h"
//#import "discussionView.h"
#import "feedbackCell.h"
#import "WeiXinActivity.h"
#import "discussionTVC.h"
#import "discussionCellWithoutPicture.h"
#import "report.h"


//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsView()
{
	NSMutableArray *groups;
    discussionCell *prototypeCell;
    NSMutableArray *up;
    NSMutableArray *down;
    NSMutableArray *upList;
    NSMutableArray *downList;
    NSMutableArray *join;
    NSMutableArray *vote; //0 means didn't vote, 1 means yes, 2 means no
    NSInteger selection;
    NSMutableArray *buttonName;
}


//@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupsView


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"discussion"]];
		self.tabBarItem.title = @"Discussions";
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Discussions";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self  action:@selector(actionNew)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	//self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsSelection = NO;
    //self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[discussionCell class] forCellReuseIdentifier:@"discussionCell"];
    //[self.tableView registerNib:[UINib nibWithNibName:@"discussionCell"  bundle:nil] forCellReuseIdentifier:@"discussionCellWithoutPicture"];
    [self.tableView registerClass:[discussionCellWithoutPicture class] forCellReuseIdentifier:@"discussionCellWithoutPicture"];
    [self.tableView registerClass:[feedbackCell class] forCellReuseIdentifier:@"feedbackCell"];
    //[self.tableView registerNib:[UINib nibWithNibName:@"discussionCell" bundle:nil] forCellReuseIdentifier:@"discussionCell"];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groups = [[NSMutableArray alloc] init];
    up = [[NSMutableArray alloc] init];
    down = [[NSMutableArray alloc] init];
    join = [[NSMutableArray alloc] init];
    vote = [[NSMutableArray alloc] init];
    buttonName = [[NSMutableArray alloc] initWithArray:@[@"Featured", @"What's Hot", @"Local", @"My Post"]];
    
    
    selection = 0;
    
    //for horizontal scroller menu
    //[self createScrollMenu];
    [self createSegment];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.10 green:0.77 blue:1.00 alpha:1.0];
    
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:@"locationUpdate" object:nil];
}

-(void)updateLocation
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    CLLocation *myLocation = app.currentLocation;
    self.currentLocation = myLocation;
    NSLog(@"location now is %@", self.currentLocation);
}

//for horizontal scroller menu
/*
- (void)createScrollMenu
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    int x = 0;
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2 + x), 0, 100, 40)];
        [button addTarget:self action:@selector(newView:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:buttonName[i] forState:UIControlStateNormal];
        button.tag = i;
        [scrollView addSubview:button];
        
        x += button.frame.size.width;
    }
    
    scrollView.contentSize = CGSizeMake((self.view.frame.size.width + x), scrollView.frame.size.height);
    //scrollView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:scrollView];
}

-(void)newView:(UIButton *)sender
{
    if (sender.userInteractionEnabled == YES) {
        for (UIView *button in sender.superview.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.userInteractionEnabled = YES;
            }
        }
        selection = sender.tag;
        sender.userInteractionEnabled = NO;
        [self loadGroups];
    }
    
}
*/

-(void)createSegment
{
    self.sg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Featured", @"Hot", @"Local", @"My Post", nil]];
    NSLog(@"width is %f", self.view.frame.size.width);
    
    self.sg.frame = CGRectMake(30, 0, self.view.frame.size.width-60, 30);
    self.sg.selectedSegmentIndex = 0;
    
    
    [self.sg addTarget:self action:@selector(selectView:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.sg];
}

- (void)selectView:(id)sender {
        NSLog(@"self viewSelect is %@", self.viewSelect);
        //get index position for the selected control
        NSInteger selectedIndex = [sender selectedSegmentIndex];
        if (selectedIndex == 0) {
            selection = 0;
            [self loadGroups];
        }
        else if (selectedIndex == 1) {
            selection = 1;
            [self loadGroups];
        }
        else if (selectedIndex == 2) {
            selection = 2;
            [self loadGroups];
        }
        else {
            selection = 3;
            [self loadGroups];
        }

}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
    //[self createSegment];
    self.sg.frame = CGRectMake(30, 0, self.view.frame.size.width-60, 30);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
        NSLog(@"start to load group");
        if ([[PFUser currentUser][PF_USER_IS_BLACK_LIST] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            LoginUser(self);
        } else {
        //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
		[self loadGroups];
        }
	}
	else LoginUser(self);
}

//reload group after new cell is created.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Backend actions
- (void)reloadData
{
    // Reload table data
    [self loadGroups];
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroups
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFUser *user = [PFUser currentUser];
    NSMutableArray *blockList = user[PF_USER_BLOCKED_TOPICS];
    if (!blockList) {
        blockList = [[NSMutableArray alloc] init];
    }
    NSLog(@"blocked list in discussion view is %@, selection is %ld", user[PF_USER_BLOCKED_TOPICS], (long)selection);
	PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
    
    if (selection == 0) {
        [query whereKey:PF_GROUPS_FEATURE equalTo:[NSNumber numberWithInt:1]];
    }
    else if (selection == 2) {
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude
                                                   longitude:self.currentLocation.coordinate.longitude];
        NSLog(@"location is %@", point);
        // get the query of local post
        [query whereKey:PF_GROUPS_LOCATION
           nearGeoPoint:point
       withinKilometers:10];
    }
    else if (selection == 3) {
        [query whereKey:PF_GROUPS_CREATER equalTo:[PFUser currentUser]];
    }
    if (selection == 1) {
        [query orderByAscending:@"total"];
        [query setLimit:20];
    }
    else {
        [query orderByAscending:@"createdAt"];
        [query setLimit:100];
    }
    //[query whereKey:PF_GROUPS_IS_PUBLIC notEqualTo:[NSNumber numberWithInt:0]];
    [query whereKey:@"objectId" notContainedIn:blockList];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[groups removeAllObjects];
            NSArray* reversedArray = [[objects reverseObjectEnumerator] allObjects];
			[groups addObjectsFromArray:reversedArray];
            [up removeAllObjects];
            [down removeAllObjects];
            [join removeAllObjects];
            [vote removeAllObjects];
            [up addObjectsFromArray:[reversedArray valueForKey:PF_GROUPS_UP]];
            [down addObjectsFromArray:[reversedArray valueForKey:PF_GROUPS_DOWN]];
            [join addObjectsFromArray:[reversedArray valueForKey:PF_GROUPS_NUM_CHAT]];
            
            NSLog(@"groups is %@, pf user is %@", groups, [PFUser currentUser]);
            
            PFUser *user = [PFUser currentUser];
            NSString *userName = user[PF_USER_USERNAME];
            NSInteger size = [objects count];
            for (int i=0; i<size; i++) {
                [vote addObject:[NSNumber numberWithInt:0]];
            }
            
            for (int i=0; i<size; i++) {
                if (groups[i][PF_GROUPS_UP_LIST]) {
                    if ([groups[i][PF_GROUPS_UP_LIST] containsObject:userName]) {
                        vote[i] = [NSNumber numberWithInt:1];
                        NSLog(@"the user vote yes on this group %d",i);
                    }
                    else {
                        NSLog(@"user has not vote yes in this group yet %d", i);
                    }
                }
                if (groups[i][PF_GROUPS_DOWN_LIST]) {
                    if ([groups[i][PF_GROUPS_DOWN_LIST] containsObject:userName]) {
                        vote[i] = [NSNumber numberWithInt:2];
                        NSLog(@"the user vote no on this group %d",i);
                    }
                    else {
                        NSLog(@"user has not vote no in this group yet %d", i);
                    }
                }
            }
            
			[self.tableView reloadData];

		}
		else [ProgressHUD showError:@"Network error."];
	}];
    
    
}



#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNew
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    discussionTVC *dv = [[discussionTVC alloc] initWithNibName:@"discussionTVCell" bundle:nil];
    dv.hidesBottomBarWhenPushed = YES;
    
    PFObject *object  = [PFObject objectWithClassName:PF_GROUPS_CLASS_NAME];
    object[PF_GROUPS_NAME] = @"Topic";
    object[PF_GROUPS_DESCRIPTION] = @"Let's join the discussion!";
    [object setObject:[NSNumber numberWithInteger:0] forKey:PF_GROUPS_DOWN];
    [object setObject:[NSNumber numberWithInteger:0] forKey:PF_GROUPS_UP];
    [object setObject:[NSNumber numberWithInteger:0] forKey:PF_GROUPS_NUM_CHAT];
    object[PF_GROUPS_DOWN_NAME] = @"No";
    object[PF_GROUPS_UP_NAME] = @"Yes";
    dv.group = object;
    dv.currentLocation = self.currentLocation;
    
    [self.navigationController pushViewController:dv animated:YES];
    /*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a name for your group" message:nil delegate:self
										  cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
     */
}

#pragma mark - UIAlertViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != alertView.cancelButtonIndex)
	{
		UITextField *textField = [alertView textFieldAtIndex:0];
		if ([textField.text length] != 0)
		{
			PFObject *object = [PFObject objectWithClassName:PF_GROUPS_CLASS_NAME];
			object[PF_GROUPS_NAME] = textField.text;
			[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				if (error == nil)
				{
					[self loadGroups];
				}
				else [ProgressHUD showError:@"Network error."];
			}];
		}
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
    /*
    if (section == 0) {
       return [groups count];
    }
    else {
        return 1;
    }*/
    
    return (section==0) ? [groups count] : 1;
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.section == 1) {
        feedbackCell *cell = (feedbackCell *)[tableView dequeueReusableCellWithIdentifier:@"feedbackCell"];
        if (cell == nil) cell = (feedbackCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"feedbackCell"];
        //discussionCell *cell = (discussionCell *)[tableView dequeueReusableCellWithIdentifier:@"discussionCell"];
        //if (cell == nil) cell = (discussionCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discussionCell"];
        //PFObject *group = groups[0];
        //cell.group = group;
        //cell.topic.text = group[PF_GROUPS_NAME];
        //cell.topicDescription.text = group[PF_GROUPS_DESCRIPTION];
        [cell.join addTarget:self action:@selector(actionFeedback:) forControlEvents:UIControlEventTouchUpInside];
        [cell.share addTarget:self action:@selector(actionShareFeedback:) forControlEvents:UIControlEventTouchUpInside];
        
        if (indexPath.row == 1) {
            cell.topic.text = @"Report any abusive behaviors or users";
            cell.topicDescription.text = @"Please report any offensive content or any abusive users from the service";
            [cell.join setTitle:@"Report"   forState:UIControlStateNormal  ];
        }
        
        return  cell;
    }
    else {
        PFObject *group = groups[indexPath.row];
        if (group[PF_GROUPS_PICTURE]) {
            discussionCell *cell = (discussionCell *)[tableView dequeueReusableCellWithIdentifier:@"discussionCell"];
            if (cell == nil) {
                cell = (discussionCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discussionCell"];
                [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateNormal];
                [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateDisabled];
                [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateNormal];
                [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateDisabled];
                
            }

            if (group[PF_GROUPS_NAME] != nil) {
                cell.topic.text = group[PF_GROUPS_NAME];
            }
            if (group[PF_GROUPS_DESCRIPTION] != nil) {
                cell.topicDescription.text = group[PF_GROUPS_DESCRIPTION];
                cell.topicDescription.textColor = [UIColor lightGrayColor];
            }
            //cell.status.text = [NSString stringWithFormat:@"YES %@ VS NO %@", group[PF_GROUPS_UP], group[PF_GROUPS_DOWN]];
            cell.group = group;
            [cell.join setTag:[indexPath row]];
            [cell.up setTag:[indexPath row]];
            [cell.down setTag:[indexPath row]];
            [cell.share setTag:[indexPath row]];
            [cell.report setTag:[indexPath row]];
    
            [cell.join addTarget:self action:@selector(actionChat:) forControlEvents:UIControlEventTouchUpInside];
            [cell.up addTarget:self action:@selector(actionUp:) forControlEvents:UIControlEventTouchUpInside];
            [cell.down addTarget:self action:@selector(actionDown:) forControlEvents:UIControlEventTouchUpInside];
            [cell.share addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
            [cell.report addTarget:self action:@selector(actionReport:) forControlEvents:UIControlEventTouchUpInside];
    
            if (up[indexPath.row]==nil) {
                [cell.up setTitle:@"Yes 0" forState:UIControlStateNormal];
                up[indexPath.row] = @"0";
            } else {
                if (group[PF_GROUPS_UP_NAME] != nil) {
                    NSLog(@"Yes name should be %@", group[PF_GROUPS_UP_NAME]);
                    [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateNormal];
                    [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateDisabled];
                }
            }
    
            if (down[indexPath.row]==nil) {
                [cell.down setTitle:@"No 0" forState:UIControlStateNormal];
                down[indexPath.row] = @"0";
            } else {
                if (group[PF_GROUPS_DOWN_NAME] != nil) {
                    [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateNormal];
                    [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateDisabled];
                }
            }
    
            if (join[indexPath.row]==nil) {
                [cell.join setTitle:@"Join" forState:UIControlStateNormal];
                join[indexPath.row] = @"0";
            } else {
                //[cell.join setTitle:[NSString stringWithFormat:@"JOIN %@", join[indexPath.row]] forState:UIControlStateNormal];
                [cell.join setTitle:@"Join" forState:UIControlStateNormal];
            }
    
            [cell bindData:group];

    
            if([vote[indexPath.row] integerValue]==0) {
                cell.up.userInteractionEnabled = YES;
                cell.down.userInteractionEnabled = YES;
            } else if ([vote[indexPath.row] integerValue]==1) {
                cell.up.userInteractionEnabled = NO;
                cell.down.userInteractionEnabled = YES;
                cell.up.highlighted = YES;
                cell.down.highlighted = NO;
            } else if  ([vote[indexPath.row] integerValue]==2) {
                cell.up.userInteractionEnabled = YES;
                cell.down.userInteractionEnabled = NO;
                cell.down.highlighted = YES;
                cell.up.highlighted = NO;
            }

            return cell;
        }
        else {
            discussionCellWithoutPicture *cell = (discussionCellWithoutPicture *)[tableView dequeueReusableCellWithIdentifier:@"discussionCellWithoutPicture"];
            if (cell == nil)
            {cell = (discussionCellWithoutPicture *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discussionCellWithoutPicture"];
                [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateNormal];
                [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateDisabled];
                [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateNormal];
                [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateDisabled];
            }
            
            if (group[PF_GROUPS_NAME] != nil) {
                cell.topic.text = group[PF_GROUPS_NAME];
            }
            if (group[PF_GROUPS_DESCRIPTION] != nil) {
                cell.topicDescription.text = group[PF_GROUPS_DESCRIPTION];
                cell.topicDescription.textColor = [UIColor lightGrayColor];
            }
            //cell.status.text = [NSString stringWithFormat:@"YES %@ VS NO %@", group[PF_GROUPS_UP], group[PF_GROUPS_DOWN]];
            cell.group = group;
            [cell.join setTag:[indexPath row]];
            [cell.up setTag:[indexPath row]];
            [cell.down setTag:[indexPath row]];
            [cell.share setTag:[indexPath row]];
            [cell.report setTag:[indexPath row]];
            
            [cell.join addTarget:self action:@selector(actionChat:) forControlEvents:UIControlEventTouchUpInside];
            [cell.up addTarget:self action:@selector(actionUp:) forControlEvents:UIControlEventTouchUpInside];
            [cell.down addTarget:self action:@selector(actionDown:) forControlEvents:UIControlEventTouchUpInside];
            [cell.share addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
            [cell.report addTarget:self action:@selector(actionReport:) forControlEvents:UIControlEventTouchUpInside];
            
            
            if (up[indexPath.row]==nil) {
                [cell.up setTitle:@"Yes 0" forState:UIControlStateNormal];
                up[indexPath.row] = @"0";
            } else {
                if (group[PF_GROUPS_UP_NAME] != nil) {
                    [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateNormal];
                    [cell.up setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_UP_NAME], up[indexPath.row]] forState:UIControlStateDisabled];
                     NSLog(@"YES NAME IS %@", group[PF_GROUPS_UP_NAME]);
                }
            }
            
            if (down[indexPath.row]==nil) {
                [cell.down setTitle:@"No 0" forState:UIControlStateNormal];
                down[indexPath.row] = @"0";
            } else {
                if (group[PF_GROUPS_DOWN_NAME] != nil) {
                    [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateNormal];
                    [cell.down setTitle:[NSString stringWithFormat:@"%@ %@", group[PF_GROUPS_DOWN_NAME], down[indexPath.row]] forState:UIControlStateDisabled];
                    NSLog(@"NO NAME IS %@", group[PF_GROUPS_DOWN_NAME]);
                }
            }
            
            if (join[indexPath.row]==nil) {
                [cell.join setTitle:@"Join" forState:UIControlStateNormal];
                join[indexPath.row] = @"0";
            } else {
                //[cell.join setTitle:[NSString stringWithFormat:@"JOIN %@", join[indexPath.row]] forState:UIControlStateNormal];
                [cell.join setTitle:@"Join" forState:UIControlStateNormal];
            }
            
            if ([vote[indexPath.row] integerValue]==1) {
                cell.up.userInteractionEnabled = NO;
                cell.down.userInteractionEnabled = YES;
                cell.up.highlighted = YES;
                cell.down.highlighted = NO;
            } else if  ([vote[indexPath.row] integerValue]==2) {
                cell.up.userInteractionEnabled = YES;
                cell.down.userInteractionEnabled = NO;
                cell.down.highlighted = YES;
                cell.up.highlighted = NO;
            } else {
                cell.up.userInteractionEnabled = YES;
                cell.down.userInteractionEnabled = YES;
            }
            
            return cell;
        }
    }
}


#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    if (indexPath.section == 0) {
	PFObject *group = groups[indexPath.row];
    
    discussionTVC *dv = [[discussionTVC alloc] initWithNibName:nil bundle:nil];
    dv.hidesBottomBarWhenPushed = YES;
    dv.group = group;
    NSLog(@"push to edit mode");
    [self.navigationController pushViewController:dv animated:YES];
    }
    /*
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CreateMessageItem([PFUser currentUser], groupId, group[PF_GROUPS_NAME]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
    */
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
    //discussionCell *cell = prototypeCell;
    PFObject *group = groups[indexPath.row];
        CGFloat height = 0;
    NSString *cellTextT = group[PF_GROUPS_NAME];
    UIFont *cellFontT = [UIFont fontWithName:@"Helvetica" size:20.0];

        NSAttributedString *attributedTextT =
        [[NSAttributedString alloc]
         initWithString:cellTextT
         attributes:@
         {
         NSFontAttributeName: cellFontT
         }];
        CGRect rect0 = [attributedTextT boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                     context:nil];
        height = rect0.size.height;
          //      NSLog(@"height with topic is %f", height);
        
    if(group[PF_GROUPS_DESCRIPTION] != nil) {
        NSString *cellText = group[PF_GROUPS_DESCRIPTION];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0];
        NSAttributedString *attributedTextD =
            [[NSAttributedString alloc] initWithString:cellText
                                            attributes:@{
                                                         NSFontAttributeName: cellFont
                                                         }];
        CGRect rect1 = [attributedTextD boundingRectWithSize:CGSizeMake(280.0, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
            height = height + rect1.size.height;
        //NSLog(@"height with details is %f", height);
    }

    if (group[PF_GROUPS_PICTURE]==nil) {
        height = height + 120;
    }
    else {
        height = height + 450;
    }
        return height;
    }
    else {
        return 200;
    }
    //CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"h=%f", size.height + 1);
    //return 1  + size.height;
}


/*

//delete group post
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.section == 0) {
    PFObject *group = groups[indexPath.row];
    PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
    [query whereKey:@"objectId" equalTo:group.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error) {
            NSLog(@"find group to be deleted");
            [group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (error == nil)
                 {
                     [self loadGroups];
                     [ProgressHUD showSuccess:@"Delete Group discussion!"];
                 }
                 else [ProgressHUD showError:@"Network error."];
             }];
        }
    }];
    }
}

*/



//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionReport:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    NSLog(@"flag group to report");
    [group incrementKey:PF_GROUPS_FLAG_NUMBER byAmount:[NSNumber numberWithInt:1]];
    report *reportView = [[report alloc] init];
    reportView.group = group;
    reportView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reportView animated:YES];
}

-(void)actionFeedback:(UIButton *)sender
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:@"admin@bluewhalechat.com"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] != 0)
         {
             PFUser *user1 = [PFUser currentUser];
             PFUser *user2 = [objects firstObject];
             NSString *groupId = StartPrivateChat(user1, user2);
             ChatView *chatView = [[ChatView alloc] initWith:groupId];
             chatView.hidesBottomBarWhenPushed = YES;
             [self.navigationController pushViewController:chatView animated:YES];
         }
         else {
             [ProgressHUD showError:@"Admin error."];
         }
     }];

}

-(void)actionChat:(UIButton *)sender
{
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    NSString *groupId = group.objectId;
    NSLog(@"in action Chat");
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CreateMessageItem([PFUser currentUser], groupId, group[PF_GROUPS_NAME]);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.hidesBottomBarWhenPushed = YES;
        NSLog(@"in action Chat, before push");
    [self.navigationController pushViewController:chatView animated:YES];
        NSLog(@"in action Chat, after push");
}

-(void)actionUp:(UIButton *)sender
{
    NSLog(@"add one vote to up");
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    NSInteger agree = [[group objectForKey:PF_GROUPS_UP] intValue];
    [group incrementKey:PF_GROUPS_UP byAmount:[NSNumber numberWithInt:1]];
    [up setObject:[NSNumber numberWithInteger:(agree + 1)] atIndexedSubscript:row  ];
    NSLog(@"up is now %@", up[row]);
    [self.tableView reloadData];
    sender.userInteractionEnabled = NO;
    if([vote[row] integerValue]==2) {
        NSInteger disagree = [[group objectForKey:PF_GROUPS_DOWN] intValue];
        [group setObject:[NSNumber numberWithInteger:(disagree-1)] forKey:PF_GROUPS_DOWN];
        [down setObject:[NSNumber numberWithInteger:(disagree-1)] atIndexedSubscript:row  ];
        [group[PF_GROUPS_DOWN_LIST] removeObject:[PFUser currentUser][PF_USER_USERNAME]];
        NSLog(@"down now is %@", down[row]);
    }
    vote[row] = [NSNumber numberWithInt:1];
    if (group[PF_GROUPS_UP_LIST]) {
        if (![group[PF_GROUPS_UP_LIST] containsObject:[PFUser currentUser][PF_USER_USERNAME]]){
        [group[PF_GROUPS_UP_LIST] addObject:[PFUser currentUser][PF_USER_USERNAME]];
        }
    }
    else {
        group[PF_GROUPS_UP_LIST] = [[NSMutableArray alloc] init];
        if (![group[PF_GROUPS_UP_LIST] containsObject:[PFUser currentUser][PF_USER_USERNAME]]){
        [group[PF_GROUPS_UP_LIST] addObject:[PFUser currentUser][PF_USER_USERNAME]];
        }
    }
    NSLog(@"vote is now %@", vote[row]);
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             //[self loadGroups];
            NSLog(@"group now is %@",group);
         }
         else [ProgressHUD showError:@"Network error."];
     }];
    
}

-(void)actionDown:(UIButton *)sender
{
    NSLog(@"add one vote to down");
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    NSInteger disagree = [[group objectForKey:PF_GROUPS_DOWN] intValue];
    [group incrementKey:PF_GROUPS_DOWN byAmount:[NSNumber numberWithInt:1]];
    [down setObject:[NSNumber numberWithInteger:(disagree+1)] atIndexedSubscript:row  ];
    NSLog(@"down now is %@", down[row]);
    [self.tableView reloadData];
    sender.userInteractionEnabled = NO;
    if([vote[row] integerValue]==1) {
        NSInteger agree = [[group objectForKey:PF_GROUPS_UP] intValue];
        [group setObject:[NSNumber numberWithInteger:(agree-1)] forKey:PF_GROUPS_UP];
        [up setObject:[NSNumber numberWithInteger:(agree - 1)] atIndexedSubscript:row  ];
        [group[PF_GROUPS_UP_LIST] removeObject:[PFUser currentUser][PF_USER_USERNAME]];
        NSLog(@"up is now %@", up[row]);
    }
    vote[row] = [NSNumber numberWithInt:2];
    NSLog(@"vote is now %@", vote[row]);
    if (group[PF_GROUPS_DOWN_LIST]) {
        if (![group[PF_GROUPS_DOWN_LIST] containsObject:[PFUser currentUser][PF_USER_USERNAME]]){
        [group[PF_GROUPS_DOWN_LIST] addObject:[PFUser currentUser][PF_USER_USERNAME]];
        }
    }
    else {
        group[PF_GROUPS_DOWN_LIST] = [[NSMutableArray alloc] init];
        if (![group[PF_GROUPS_DOWN_LIST] containsObject:[PFUser currentUser][PF_USER_USERNAME]]){
        [group[PF_GROUPS_DOWN_LIST] addObject:[PFUser currentUser][PF_USER_USERNAME]];
        }
    }

    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             //[self loadGroups];
             NSLog(@"group now is %@",group);
         }
         else [ProgressHUD showError:@"Network error."];
     }];
}

-(void)actionShare:(UIButton *)sender
{
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    
    NSString *text = group[PF_GROUPS_NAME];
    NSString *details = group[PF_GROUPS_DESCRIPTION];
    NSString *promote = @"Download BlueWhale Chat at APP store now to join this discussion! #BlueWhale";

    if (group[PF_GROUPS_PICTURE]==nil) {
        UIImage *image = [UIImage imageNamed:@"logo-120x120.gif"];
        WeiXinActivity *weiXinActivity = [[WeiXinActivity alloc] init];
        weiXinActivity.message = promote;
        NSArray *applicationActivities = @[weiXinActivity];
        UIActivityViewController *controller =
        [[UIActivityViewController alloc]
         initWithActivityItems:@[text, image, details, promote]
         applicationActivities:applicationActivities];
        controller.excludedActivityTypes = @[
                                            UIActivityTypeAddToReadingList,
                                            UIActivityTypeAirDrop,
                                            UIActivityTypePrint,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypeSaveToCameraRoll
                                            ];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [group[PF_GROUPS_PICTURE] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
               UIImage *image = [UIImage imageWithData:data];
                // image can now be set on a UIImageView
                WeiXinActivity *weiXinActivity = [[WeiXinActivity alloc] init];
                weiXinActivity.message = promote;
                NSArray *applicationActivities = @[weiXinActivity];
                UIActivityViewController *controller =
                [[UIActivityViewController alloc]
                 initWithActivityItems:@[text, image, details, promote]
                 applicationActivities:applicationActivities];
                controller.excludedActivityTypes = @[
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypeAirDrop,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll
                                                     ];
                
                [self presentViewController:controller animated:YES completion:nil];
            }
        }];
    }
}


-(void)actionShareFeedback:(UIButton *)sender
{
    
    NSString *text = @"I am using Blue Whale Chat to meet new people around my life and strat intresting discussion! Join us! Download the app BlueWhale at APP store now! #BlueWhale";
    //UIImage *image = [UIImage imageNamed:@"roadfire-icon-square-200"];

    UIImage *image;

    image = [UIImage imageNamed:@"logo-120x120.gif"];

    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, image]
     applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
}



@end
