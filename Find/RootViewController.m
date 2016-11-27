//
//  RootViewController.m
//  Find
//
//  Created by barara on 15/8/4.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "RootViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "WebViewController.h"
#import "TwoViewController.h"
#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "RecordViewController.h"
#import "BluetoothViewController.h"
#import "BlueViewController.h"
#import "MusicViewController.h"
#import "BeaconViewController.h"

#include <sys/socket.h> // Per msqr
//#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#define BEACONUUID @"DFA3EF9F-4C31-B4CC-35DC-9295E4C942D8"//iBeacon的uuid可以换成自己设备的uuid

@interface RootViewController () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    
    self.locationmanager.delegate = self;
    self.locationmanager.activityType = CLActivityTypeFitness;
    self.locationmanager.distanceFilter = kCLDistanceFilterNone;
    self.locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationmanager.pausesLocationUpdatesAutomatically = NO;
    
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许，即永久获取位置权限
    
    self.beacon1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"media"];//初始化监测的iBeacon信息
    self.beacon1.notifyEntryStateOnDisplay = YES;//在屏幕点亮的时候（锁屏状态下按下 home 键，或者因为收到推送点亮等）进行一次扫描
    
    //[self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
    [self.locationmanager startMonitoringForRegion:self.beacon1];//开始
    [self.locationmanager startRangingBeaconsInRegion:self.beacon1];
    [self.locationmanager requestStateForRegion:self.beacon1];
    
    [self.locationmanager startUpdatingLocation];
    
    NSLog(@"SSID = %@",[self getDeviceSSID]);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(60, 50, 200, 100);
    [btn setTitle:@"Jump to WebView" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(60, 100, 200, 100);
    [btn1 setTitle:@"Jump to 二维码" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(60, 150, 200, 100);
    [btn2 setTitle:@"Jump to 信息" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(60, 200, 200, 100);
    [btn3 setTitle:@"Jump to 录音" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(btn3Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.frame = CGRectMake(60, 250, 200, 100);
    [btn4 setTitle:@"Jump to 蓝牙1" forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(btn4Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
    
    UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn5.frame = CGRectMake(60, 300, 200, 100);
    [btn5 setTitle:@"Jump to music" forState:UIControlStateNormal];
    [btn5 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn5 addTarget:self action:@selector(btn5Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn5];
    
    UIButton *btn6 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn6.frame = CGRectMake(60, 350, 200, 100);
    [btn6 setTitle:@"Jump to iBeacon" forState:UIControlStateNormal];
    [btn6 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn6 addTarget:self action:@selector(btn6Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn6];
    
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"locationString:%@",locationString);
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter  *dateformatter2=[[NSDateFormatter alloc] init];
     [dateformatter2 setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *string = [NSString stringWithFormat:@"%@",currentDate];
    NSString *  locationString2=[dateformatter2 stringFromDate:currentDate];
    NSLog(@"time = %@,str = %@",locationString2,string);
}

- (void)takePhoto
{
    
}

- (void)btn6Click
{
    BeaconViewController *bvc = [[BeaconViewController alloc] init];
    [self.navigationController pushViewController:bvc animated:YES];
}

- (void)btn5Click
{
    MusicViewController *mvc = [[MusicViewController alloc] init];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)btn4Click
{
    BluetoothViewController *bt = [[BluetoothViewController alloc] init];
    [self.navigationController pushViewController:bt animated:YES];
}

- (void)btn3Click
{
    RecordViewController *rvc = [[RecordViewController alloc] init];
    [self.navigationController pushViewController:rvc animated:YES];
}

- (void)btn2Click
{
    NSString *str = [self macaddress];
    NSLog(@"mac = %@",str);
    
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
        }
    }
    
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    NSString*text =[NSString stringWithFormat:@"%@ %@",appName,versionNum];
    
    NSLog(@"dic = %@，text = %@",infoDict,text);
    
    //手机序列号
    //NSString* identifierNumber = [[UIDevice currentDevice] uniqueIdentifier];
    //NSLog(@"手机序列号: %@",identifierNumber);
    //手机别名： 用户定义的名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    //设备名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备名称: %@",deviceName );
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSLog(@"手机型号: %@",phoneModel );
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"国际化区域名称: %@",localPhoneModel );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"当前应用名称：%@",appCurName);
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    
    UIDevice* curDev = [UIDevice currentDevice];
    NSLog(@"\tUUID        : %@", curDev.identifierForVendor.UUIDString);
    // 设备名称
    NSLog(@"\tname        : %@", curDev.name);
    // 设备模式
    NSLog(@"\tmodel       : %@", curDev.model);
    // 设备本地模式
    NSLog(@"\tlocalize    : %@", curDev.localizedModel);
    // 系统名称
    NSLog(@"\tos name     : %@", curDev.systemName);
    // 系统版本号
    NSLog(@"\tos version  : %@", curDev.systemVersion);
    
    //手机型号。
    
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = (char*)malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    NSLog(@"platform = %@",platform);
    
    
    
}

- (void)btn1Click
{
    TwoViewController *tvc = [[TwoViewController alloc] init];
    [self.navigationController pushViewController:tvc animated:YES];
}

- (void)btnClick
{
    WebViewController *web = [[WebViewController alloc] init];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)readFile
{
    
    NSString *str = @"http://192.168.0.192/me.mobileconfig";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    
}

- (NSString *)macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *)getDeviceSSID
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [[dctySSID objectForKey:@"SSID"] lowercaseString];
    
    return ssid;
    
}

- (void)setUI
{
    _tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-49)];
    _tv.delegate = self;
    [self.view addSubview:_tv];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
