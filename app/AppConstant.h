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

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DEFAULT_TAB							1

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		MESSAGE_INVITE						@"Check out BlueWhale Chat. You can download at APP store or here: "

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class
//-----------------------------------------------------------------------
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
#define     PF_USER_SEX                         @"sex"                  //  String
#define     PF_USER_AGE                         @"age"                  //  Number
#define     PF_USER_BIRTHDAY                    @"birthday"             //  String
#define     PF_USER_INTEREST                    @"interest"             //  String
#define     PF_USER_SELF_DESCRIPTION            @"selfDescription"      //  String
#define     PF_USER_CONTACTS                    @"contacts"             //  Array of contact names
#define     PF_USER_BLOCKED_USERS               @"blockedUsers"         //  Array of blocked users
#define     PF_USER_VOTE                        @"votes"                //  Array of votes
//-----------------------------------------------------------------------
#define		PF_CHAT_CLASS_NAME					@"Chat"					//	Class name
#define		PF_CHAT_USER						@"user"					//	Pointer to User Class
#define		PF_CHAT_GROUPID						@"groupId"				//	String
#define		PF_CHAT_TEXT						@"text"					//	String
#define		PF_CHAT_PICTURE						@"picture"				//	File
#define		PF_CHAT_VIDEO						@"video"				//	File
#define		PF_CHAT_CREATEDAT					@"createdAt"			//	Date
//-----------------------------------------------------------------------
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String
#define     PF_GROUPS_UP                        @"up"                   //  Number
#define     PF_GROUPS_DOWN                      @"down"                 //  Number
#define     PF_GROUPS_UP_NAME                   @"upName"               //  String
#define     PF_GROUPS_DOWN_NAME                 @"downName"             //  String
#define		PF_GROUPS_CREATER                   @"creater"				//  Pointer to User Class
#define		PF_GROUPS_CREATE_TIME               @"createTime"			//  Date
#define     PF_GROUPS_LATITUDE                  @"latitude"             //  String
#define     PF_GROUPS_LONGITUDE                 @"longitude"            //  String
#define		PF_GROUPS_DESCRIPTION				@"description"			//	String
#define     PF_GROUPS_PICTURE                   @"picture"              //  File
#define     PF_GROUPS_NUM_CHAT                  @"numChat"              //  Number
#define     PF_GROUPS_IS_PUBLIC                 @"is_public"            //  BOOL
#define     PF_GROUPS_FLAG_NUMBER               @"flag_number"          //  Number
//-----------------------------------------------------------------------
#define		PF_MESSAGES_CLASS_NAME				@"Messages"				//	Class name
#define		PF_MESSAGES_USER					@"user"					//	Pointer to User Class
#define		PF_MESSAGES_GROUPID					@"groupId"				//	String
#define		PF_MESSAGES_DESCRIPTION				@"description"			//	String
#define		PF_MESSAGES_LASTUSER				@"lastUser"				//	Pointer to User Class
#define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_MESSAGES_COUNTER					@"counter"				//	Number
#define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"		//	Date
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
