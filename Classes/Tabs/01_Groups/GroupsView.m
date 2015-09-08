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

#import "GroupsView.h"
#import "ChatView.h"
#import "DatabaseAvailability.h"
#import "discussionCell.h"
#import "discussionView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsView()
{
	NSMutableArray *groups;
    discussionCell *prototypeCell;
    NSMutableArray *up;
    NSMutableArray *down;
    NSMutableArray *join;
    NSMutableArray *vote; //0 means didn't vote, 1 means yes, 2 means no
}
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
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_groups"]];
		self.tabBarItem.title = @"Groups";
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Groups";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self  action:@selector(actionNew)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[discussionCell class] forCellReuseIdentifier:@"discussionCell"];
    
    //[self.tableView registerNib:[UINib nibWithNibName:@"discussionCell" bundle:nil] forCellReuseIdentifier:@"discussionCell"];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groups = [[NSMutableArray alloc] init];
    up = [[NSMutableArray alloc] init];
    down = [[NSMutableArray alloc] init];
    join = [[NSMutableArray alloc] init];
    vote = [[NSMutableArray alloc] init];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
        //[[NSNotificationCenter defaultCenter] postNotificationName:PFUSER_READY object:nil];
		[self loadGroups];
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroups
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[groups removeAllObjects];
			[groups addObjectsFromArray:objects];
            [up removeAllObjects];
            [down removeAllObjects];
            [join removeAllObjects];
            [vote removeAllObjects];
            [up addObjectsFromArray:[objects valueForKey:PF_GROUPS_UP]];
            [down addObjectsFromArray:[objects valueForKey:PF_GROUPS_DOWN]];
            [join addObjectsFromArray:[objects valueForKey:PF_GROUPS_NUM_CHAT]];
            NSInteger size = [objects count];
            for (int i=0; i<size; i++) {
                [vote addObject:[NSNumber numberWithInt:0]];
            }
			[self.tableView reloadData];
            NSLog(@"groups is %@, up is %@, down is %@, join is %@, vote is %@", groups, up, down, join, vote);
		}
		else [ProgressHUD showError:@"Network error."];
	}];
    
    
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNew
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    discussionView *dv = [[discussionView alloc] initWithNibName:nil bundle:nil];
    dv.hidesBottomBarWhenPushed = YES;
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
	return [groups count];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	discussionCell *cell = (discussionCell *)[tableView dequeueReusableCellWithIdentifier:@"discussionCell"];
	if (cell == nil) cell = (discussionCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"discussionCell"];

	PFObject *group = groups[indexPath.row];
	cell.topic.text = group[PF_GROUPS_NAME];
    cell.topicDescription.text = group[PF_GROUPS_DESCRIPTION];
    //cell.status.text = [NSString stringWithFormat:@"YES %@ VS NO %@", group[PF_GROUPS_UP], group[PF_GROUPS_DOWN]];
    cell.group = group;
    [cell.join setTag:[indexPath row]];
    [cell.up setTag:[indexPath row]];
    [cell.down setTag:[indexPath row]];
    
    [cell.join addTarget:self action:@selector(actionChat:) forControlEvents:UIControlEventTouchUpInside];
    [cell.up addTarget:self action:@selector(actionUp:) forControlEvents:UIControlEventTouchUpInside];
    [cell.down addTarget:self action:@selector(actionDown:) forControlEvents:UIControlEventTouchUpInside];
    
    if([vote[indexPath.row] integerValue]==0) {
        cell.up.userInteractionEnabled = YES;
        cell.down.userInteractionEnabled = YES;
    } else if ([vote[indexPath.row] integerValue]==1) {
        cell.up.userInteractionEnabled = NO;
        cell.down.userInteractionEnabled = YES;
    } else if  ([vote[indexPath.row] integerValue]==2) {
        cell.up.userInteractionEnabled = YES;
        cell.down.userInteractionEnabled = NO;
    }
    
    if (up[indexPath.row]==nil) {
        [cell.up setTitle:@"YES 0" forState:UIControlStateNormal];
        up[indexPath.row] = @"0";
    } else {
        [cell.up setTitle:[NSString stringWithFormat:@"YES %@", up[indexPath.row]] forState:UIControlStateNormal];
    }
    
    if (down[indexPath.row]==nil) {
        [cell.down setTitle:@"NO 0" forState:UIControlStateNormal];
        down[indexPath.row] = @"0";
    } else {
        [cell.down setTitle:[NSString stringWithFormat:@"NO %@", down[indexPath.row]] forState:UIControlStateNormal];
    }
    
    if (join[indexPath.row]==nil) {
        [cell.join setTitle:@"JOIN" forState:UIControlStateNormal];
        join[indexPath.row] = @"0";
    } else {
        //[cell.join setTitle:[NSString stringWithFormat:@"JOIN %@", join[indexPath.row]] forState:UIControlStateNormal];
        [cell.join setTitle:@"JOIN" forState:UIControlStateNormal];
    }
    
    if (group[PF_GROUPS_PICTURE]==nil) {
        UIImage *def_image = [UIImage imageNamed:@"tab_discovers_2"];
        cell.image.image = def_image;
    } else {
        //[cell bindData:group];
        cell.image.file = group[PF_GROUPS_PICTURE];
        [cell.image loadInBackground];
        //cell.image.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    /*
	if (cell.detailTextLabel.text == nil) cell.detailTextLabel.text = @" ";
	cell.detailTextLabel.textColor = [UIColor lightGrayColor];

	PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
	[query whereKey:PF_CHAT_GROUPID equalTo:group.objectId];
	[query orderByDescending:PF_CHAT_CREATEDAT];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if ([objects count] != 0)
		{
			PFObject *chat = [objects firstObject];
			NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:chat.createdAt];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d messages (%@)", (int) [objects count], TimeElapsed(seconds)];
		}
		else cell.detailTextLabel.text = @"No message";
	}];
     */

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    /*
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *group = groups[indexPath.row];
	NSString *groupId = group.objectId;
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

    discussionCell *cell = prototypeCell;
    PFObject *group = groups[indexPath.row];
    NSString *cellText = group[PF_GROUPS_NAME];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:cellText
     attributes:@
     {
     NSFontAttributeName: cellFont
     }];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(cell.topicDescription.frame.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height + 400;
    
    //CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"h=%f", size.height + 1);
    //return 1  + size.height;
}

-(void)actionChat:(UIButton *)sender
{
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    NSString *groupId = group.objectId;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CreateMessageItem([PFUser currentUser], groupId, group[PF_GROUPS_NAME]);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}

-(void)actionUp:(UIButton *)sender
{
    NSLog(@"add one vote to up");
    NSInteger row = [sender tag];
    PFObject *group = groups[row];
    NSInteger agree = [[group objectForKey:PF_GROUPS_UP] intValue];
    [group setObject:[NSNumber numberWithInteger:(agree+1)] forKey:PF_GROUPS_UP];
    [up setObject:[NSNumber numberWithInteger:(agree + 1)] atIndexedSubscript:row  ];
    NSLog(@"up is now %@", up[row]);
    [self.tableView reloadData];
    sender.userInteractionEnabled = NO;
    if([vote[row] integerValue]==2) {
        NSInteger disagree = [[group objectForKey:PF_GROUPS_DOWN] intValue];
        [group setObject:[NSNumber numberWithInteger:(disagree-1)] forKey:PF_GROUPS_DOWN];
        [down setObject:[NSNumber numberWithInteger:(disagree-1)] atIndexedSubscript:row  ];
        NSLog(@"down now is %@", down[row]);
    }
    vote[row] = [NSNumber numberWithInt:1];
    NSLog(@"vote is now %@", vote[row]);
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             //[self loadGroups];
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
    [group setObject:[NSNumber numberWithInteger:(disagree+1)] forKey:PF_GROUPS_DOWN];
    [down setObject:[NSNumber numberWithInteger:(disagree+1)] atIndexedSubscript:row  ];
    NSLog(@"down now is %@", down[row]);
    [self.tableView reloadData];
    sender.userInteractionEnabled = NO;
    if([vote[row] integerValue]==1) {
        NSInteger agree = [[group objectForKey:PF_GROUPS_UP] intValue];
        [group setObject:[NSNumber numberWithInteger:(agree-1)] forKey:PF_GROUPS_UP];
        [up setObject:[NSNumber numberWithInteger:(agree - 1)] atIndexedSubscript:row  ];
        NSLog(@"up is now %@", up[row]);
    }
    vote[row] = [NSNumber numberWithInt:2];
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



@end
