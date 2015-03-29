//
//  ViewController.m
//  APISWebView
//
//  Created by 植田 洋次 on 2015/03/27.
//  Copyright (c) 2015年 Yoji Ueda. All rights reserved.
//

#import "ViewController.h"

static NSString *const kStartUrlStringUserDefaults = @"kStartUrlStringUserDefaults";
static NSString *const kDefaultStartUrl = @"http://www.appiaries.com/";

@interface ViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButtonItem;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)forwardButtonAction:(id)sender;
- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)settingButtonAction:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.backButtonItem.enabled = NO;
    self.forwardButtonItem.enabled = NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishedLoadWebView:webView];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self finishedLoadWebView:webView];
}

-(void)finishedLoadWebView:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (webView.canGoBack) {
        self.backButtonItem.enabled = YES;
    } else {
        self.backButtonItem.enabled = NO;
    }
    if (webView.canGoForward) {
        self.forwardButtonItem.enabled = YES;
    } else {
        self.forwardButtonItem.enabled = NO;
    }
}

#pragma mark - Actions
- (IBAction)backButtonAction:(id)sender {
    [self.webView goBack];
}

- (IBAction)forwardButtonAction:(id)sender {
    [self.webView goForward];
}

- (IBAction)refreshButtonAction:(id)sender {
    [self.webView reload];
}

- (IBAction)settingButtonAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Starting URL setting"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alert textFieldAtIndex:0];
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    textField.text = [ud objectForKey:kStartUrlStringUserDefaults];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //表示するURLの保存処理
        NSString *urlString = [[alertView textFieldAtIndex:0]text] ? :@"";
        [self saveUrl:urlString];
        //URLをロードする
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    }
}

#pragma mark - Private method
-(void)loadWebView
{
    //表示するURL
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [ud objectForKey:kStartUrlStringUserDefaults];
    if (urlString == nil) {
        //初期値はアピアリーズのHP
        urlString = kDefaultStartUrl;
        [self saveUrl:urlString];
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

-(void)saveUrl:(NSString*)urlString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:urlString forKey:kStartUrlStringUserDefaults];
    [userDefaults synchronize];
}

@end
