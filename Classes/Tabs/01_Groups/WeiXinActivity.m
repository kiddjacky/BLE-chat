//
//  WeiXinActivity.m
//  app
//
//  Created by kiddjacky on 9/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "WeiXinActivity.h"
#import "WXApi.h"

@implementation WeiXinActivity

- (NSString *)activityType {
    return @"WeiXinActivity";
}

- (NSString *)activityTitle {
    return @"微信";
}

- (UIImage *)activityImage {
    //NSString *imageName = IS_IOS7_ORLATER ? @"weixin_icon_ios7" : @"weixin_icon";
    NSString *imageName = @"weixin_icon_ios7_1.png";
    
    return [UIImage imageNamed:imageName];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (UIViewController *)activityViewController {
    /**
     * DESCRIPTION:
     * Returns the view controller to present to the user.
     * Subclasses that provide additional UI using a view controller can override this method to return that view controller. If this method returns a valid object, the system presents the returned view controller modally instead of calling the performActivity method.
     * Your custom view controller should provide a view with your custom UI and should handle any user interactions inside those views. Upon completing the activity, do not dismiss the view controller yourself. Instead, call the activityDidFinish: method and let the system dismiss it for you.
     */
    return nil;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"in prepare");
    self.modifiedMessage = [WXMediaMessage message];
    if (activityItems != nil) {
        self.modifiedMessage.title = activityItems[0];
        self.modifiedMessage.description = activityItems[2];
        self.modifiedMessage.title = @"Some Title";
        self.modifiedMessage.description = @"Amazing Sunset";
    } else {
        self.modifiedMessage.title = @"Some Title";
        self.modifiedMessage.description = @"Amazing Sunset";
    }
    //[message setThumbImage:[UIImage imageNamed:@"res1thumb.png"]];
    WXImageObject *ext = [WXImageObject object];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res1"ofType:@"jpg"];
    //ext.imageData = [NSData dataWithContentsOfFile:filePath];
    if (activityItems[1] != nil) {
        NSLog(@"in image");
        ext.imageData = UIImagePNGRepresentation(activityItems[1]);
    } else {
        NSLog(@"no data!");
        ext.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"logo-120x120.gif"]);
    }
    self.modifiedMessage.mediaObject = ext;
    NSLog(@"finish prepare");
}

-(void)performActivity {
    [self sendWeiXinMessage];
    
}

- (void)sendWeiXinMessage
{
    [self activityDidFinish:YES];
    if ([WXApi isWXAppInstalled]) {
    //if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        SendMessageToWXReq *message = [[SendMessageToWXReq alloc] init];
        message.message = self.modifiedMessage;
        message.bText = NO;
        message.text = [NSString stringWithFormat:@"%@, %@", self.modifiedMessage.title, self.modifiedMessage.description];
        message.scene = WXSceneTimeline;
        [WXApi sendReq:message];
        NSLog(@"send weixin");
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You haven't installed Wechat" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
