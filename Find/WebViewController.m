//
//  WebViewController.m
//  Find
//
//  Created by barara on 15/7/24.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "WebViewController.h"
#import "AsyncSocket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import "NSString+Hashing.h"

@interface WebViewController () <UIWebViewDelegate,AsyncSocketDelegate>

{
    UITextField *_urlField;
    UIWebView *_webView;
    
    CFSocketRef _socket;
    
    
    NSMutableArray *_mArray;
    //服务端
    AsyncSocket *_serverSocket;
    
    NSThread *_thread;
    
    UILabel *_label;
}

@end

@implementation WebViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setWebView];
    
    [self thread];
    
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
    button0.frame = CGRectMake(0, self.view.frame.size.height-30, 60, 30);
    [button0 setTitle:@"百度" forState:UIControlStateNormal];
    [button0 setBackgroundColor:[UIColor blueColor]];
    [button0 addTarget:self action:@selector(baiduClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button0];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(80, self.view.frame.size.height-30, 100, 30)];
    _label.backgroundColor = [UIColor blueColor];
    _label.textColor = [UIColor whiteColor];
    [self.view addSubview:_label];
    
}

- (void)thread
{
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(func1) object:nil];
    _thread.name = @"线程1";
    [_thread start];
}

- (void)asyncSocket1
{
    _mArray = [[NSMutableArray alloc] init];
    //服务端
    _serverSocket = [[AsyncSocket alloc] initWithDelegate:self];
    
    //监听有没有客户端
    [_serverSocket acceptOnPort:9527 error:nil];
}

//监听到客户端连接
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [_mArray addObject:newSocket];
    //监听客户端发送消息
    [newSocket readDataWithTimeout:-1 tag:0];
}

//当监听到客户端发送了消息
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //消息显示到textView上  sock.connectedHost客户端地址
    //_textView.text = [NSString stringWithFormat:@"%@%@:%@\n",_textView.text,sock.connectedHost,str];
    
    NSLog(@"str = %@,addr = %@",str,sock.connectedHost);
    
    //继续监听客户端发送消息
    [sock readDataWithTimeout:-1 tag:0];
}

//连接成功
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"连接成功");
}

- (void)func1
{
    //        1
    //SOCK_STREAM
    int err;
    int fd=socket(AF_INET, SOCK_DGRAM, 0);
    BOOL success=(fd!=-1);
    //        1
    //   2
    if (success) {
        
        _label.text = @"开启服务...";
        
        NSLog(@"socket success");
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len=sizeof(addr);
        addr.sin_family=AF_INET;
        //            =======================================================================
        addr.sin_port=htons(9527);
        //        ============================================================================
        addr.sin_addr.s_addr=INADDR_ANY;
        err=bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
        success=(err==0);
    }
    //   2
    //        ============================================================================
    if (success) {
        
        _label.text = @"开始监听...";
        
        NSLog(@"bind(绑定) success");
        err=listen(fd, 5);//开始监听
        success=(err==0);
    }
    //    ============================================================================
    //3
    if (success) {
        NSLog(@"listen success");
        while (true) {
            struct sockaddr_in peeraddr;
            int peerfd;
            socklen_t addrLen;
            addrLen=sizeof(peeraddr);
            NSLog(@"prepare accept");
            peerfd=accept(fd, (struct sockaddr *)&peeraddr, &addrLen);
            success=(peerfd!=-1);
            
            NSLog(@"peerfd = %d",peerfd);
            
            
            
            
            //    ============================================================================
            if (success) {
                
                
                
                //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //                    //线程中进行同步请求
                NSLog(@"accept success,remote address:%s,port:%d",inet_ntoa(peeraddr.sin_addr),ntohs(peeraddr.sin_port));
                
                NSLog(@"peerfd = %d",peerfd);
                
                char buf[1024];
                
                memset(buf, 0, sizeof(buf));
                
                ssize_t count;
                size_t len=sizeof(buf);
                //do {
                count=recv(peerfd, buf, len, 0);
                
                NSLog(@"buf = %s",buf);
                
                NSString* str1 = [NSString stringWithFormat:@"hyjt%s",buf];
                
                NSLog(@"str1 = %@,count = %zd",str1,count);
                
                NSString *str2 = [str1 MD5Hash];
                
                NSLog(@"str2 = %@",str2);
                
                NSString *str3 = [str2 lowercaseString];
                
                NSLog(@"str3 = %@",str3);
                
                const char * aaa =[str3 UTF8String];
                
                send(peerfd, aaa, strlen(aaa), 0);
                
                //} while (count != -1);
                
                //主线程
                //[self performSelectorOnMainThread:@selector(主线程方法) withObject:nil waitUntilDone:NO];
                //                    dispatch_async(dispatch_get_main_queue(), ^{
                //
                //                    });
                //});
                
                
                
            }
            //    ============================================================================
            close(peerfd);
        }
    }
    //3
}

- (void)baiduClick
{
    
    NSThread* thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(func2) object:nil];
    thread2.name = @"线程2";
    [thread2 start];
    
}

- (void)func2
{
    NSString *str = @"http://www.baidu.com/";
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];

}

- (void)setWebView
{
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    NSArray *array = @[@"后退",@"前进",@"刷新",@"停止",@"转到",@"主页"];
    for (int i = 0; i<array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        button.frame = CGRectMake(i*(self.view.frame.size.width/array.count), 20+64, self.view.frame.size.width/array.count, 20);
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    _urlField = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 40)];
    _urlField.tag = 200;
    _urlField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_urlField];
    
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40+64, self.view.frame.size.width, self.view.frame.size.height-40-64-30)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    [self zhuye];
    
}

- (void)zhuye
{
    NSThread* thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(func3) object:nil];
    thread3.name = @"线程3";
    [thread3 start];
}

- (void)func3
{
    NSString *str = @"http://www.qq.com/";
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)buttonClick:(UIButton *)button
{
    
    [_urlField resignFirstResponder];
    
    //@"后退",@"前进",@"刷新",@"停止",@"转到",@"主页"
    //后退
    if (button.tag == 0) {
        [_webView goBack];
    }
    //前进
    if (button.tag == 1) {
        [_webView goForward];
    }
    //刷新
    if (button.tag == 2) {
        [_webView reload];
    }
    //停止
    if (button.tag == 3) {
        [_webView stopLoading];
    }
    //转到
    if (button.tag == 4) {
        //判断是否有http前缀
        if (![_urlField.text hasPrefix:@"http"]) {
            _urlField.text = [NSString stringWithFormat:@"http://%@",_urlField.text];
        }
        NSURL *url = [NSURL URLWithString:_urlField.text];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
    //主页
    if (button.tag == 5) {
        NSString *str = @"http://www.qq.com/";
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
    
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_urlField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"*********");
    
    //shutdown(AF_INET, SOCK_STREAM);
    
//    if (_thread) {
//        [_thread cancel];
//    }
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
