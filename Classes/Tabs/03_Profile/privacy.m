//
//  privacy.m
//  app
//
//  Created by kiddjacky on 10/23/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "privacy.h"

@interface privacy ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation privacy

@synthesize webView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"privacy.html"];
    NSURLRequest *documentsRequest = [NSURLRequest requestWithURL:
                                      [NSURL fileURLWithPath:path]] ;
    NSLog(@"webview request is ready");
    [webView loadRequest:documentsRequest];*/
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"]];

    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webView.scalesPageToFit = YES;
    webView.scrollView.scrollEnabled = YES;
    webView.scrollView.bounces =YES;
    webView.scrollView.alwaysBounceHorizontal = YES;
    webView.scrollView.alwaysBounceVertical = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
