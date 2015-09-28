//
//  WeiXinActivity.h
//  app
//
//  Created by kiddjacky on 9/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface WeiXinActivity : UIActivity
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) WXMediaMessage *modifiedMessage;
@end
