//
//  TwoGoViewController.m
//  Find
//
//  Created by barara on 15/8/4.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "TwoGoViewController.h"

@interface TwoGoViewController () <UIWebViewDelegate>

{
    UIWebView *_webView;
}


@end

@implementation TwoGoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSString *str = _url;
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    
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
