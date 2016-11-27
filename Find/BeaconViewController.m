//
//  BeaconViewController.m
//  Find
//
//  Created by barara on 15/10/28.
//  Copyright © 2015年 Jay. All rights reserved.
//

#import "BeaconViewController.h"
#import <AVFoundation/AVFoundation.h>

#define BEACONUUID @"DFA3EF9F-4C31-B4CC-35DC-9295E4C942D8"//iBeacon的uuid可以换成自己设备的uuid
//#define BEACONUUID @"C9B74F0B-E85A-435C-A6D0-45A9E60E4E58"//iBeacon的uuid可以换成自己设备的uuid
//#define BEACONUUID1 @"E2C56DB5-DFFB-48D2-B060-207693345194"//iBeacon的uuid可以换成自己设备的uuid
//#define BEACONUUID2 @"E2C56DB5-DFFB-48D2-B060-2076932e77f4"//iBeacon的uuid可以换成自己设备的uuid
//#define BEACONUUID3 @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"//iBeacon的uuid可以换成自己设备的uuid

@interface BeaconViewController () <UITextViewDelegate,AVAudioPlayerDelegate>

{
    UITextView *_textView;
    AVAudioPlayer *_player;
    int _num;
}

@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = YES;
    
    _num = 0;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60)];
    _textView.font = [UIFont fontWithName:@"Arial" size:18.0];
    _textView.backgroundColor = [UIColor blackColor];
    _textView.textColor = [UIColor whiteColor];
    _textView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0);
    _textView.scrollEnabled = YES;
    //_textView.selectable = YES;//选择复制功能
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    _textView.delegate = self;
    _textView.editable = NO;//禁止编辑
    [self.view addSubview:_textView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-60)];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    self.beaconArr = [[NSArray alloc] init];
    
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    
    self.locationmanager.delegate = self;
    self.locationmanager.pausesLocationUpdatesAutomatically = NO;
    
    self.beacon1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"media"];//初始化监测的iBeacon信息
    self.beacon1.notifyEntryStateOnDisplay = YES;//在屏幕点亮的时候（锁屏状态下按下 home 键，或者因为收到推送点亮等）进行一次扫描
    
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
    [self.locationmanager startMonitoringForRegion:self.beacon1];//开始MonitoringiBeacon
    [self.locationmanager startRangingBeaconsInRegion:self.beacon1];//开始RegionBeacons
    //[self.locationmanager startUpdatingLocation];
    //[self.locationmanager requestStateForRegion:self.beacon1];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        NSLog(@"开始MonitoringiBeacon");
        _textView.text = @"开始MonitoringiBeacon\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
        
        //[self.locationmanager startMonitoringForRegion:self.beacon1];//开始MonitoringiBeacon
        //[self.locationmanager startMonitoringForRegion:self.beacon2];//开始MonitoringiBeacon
        //[self.locationmanager startUpdatingLocation];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Did start monitoring for region: %@", region.identifier);
}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
        
    NSLog(@"有iBeacon进入监测范围了");
    _textView.text = @"有iBeacon进入监测范围了\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
    //[self.locationmanager startRangingBeaconsInRegion:self.beacon1];//开始RegionBeacons
    //[self.locationmanager startRangingBeaconsInRegion:self.beacon2];//开始RegionBeacons
        
}

//找到iBeacon后扫描它的信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    NSLog(@"扫描iBeacon的信息");
    _textView.text = @"扫描iBeacon的信息\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
    //如果存在不是我们要监测的iBeacon那就停止扫描他
    
//    if (![[region.proximityUUID UUIDString] isEqualToString:BEACONUUID]){
//    
//        [self.locationmanager stopMonitoringForRegion:region];
//    
//        [self.locationmanager stopRangingBeaconsInRegion:region];
//    
//    }
    
    _num ++;
    
    if (beacons.count && _num == 2) {
        //NSString *path = [NSString stringWithFormat:@"%@/Documents/a.pcm",NSHomeDirectory()];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"Beat It" ofType:@"mp3"];
//        NSURL *url = [NSURL fileURLWithPath:path];
//        //NSLog(@"%@",path);
//        
//        //播放声音
//        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//        _player.delegate = self;
//        _player.volume = 1.0;
//        [_player prepareToPlay];
//        [_player play];
    }
    
    //打印所有iBeacon的信息
    
    for (CLBeacon* beacon in beacons) {
        
        NSLog(@"rssi is :%ld",beacon.rssi);
        
        NSLog(@"beacon.proximity %ld",beacon.proximity);
        
        NSLog(@"beacon.uuid: %@",beacon.proximityUUID);
        
        NSLog(@"beacon.accuracy: %f",beacon.accuracy);
        
        int a = [beacon.major intValue];
        NSString *aStr = [NSString stringWithFormat:@"%04x",a];
        
        NSLog(@"16进制的minor 为 %@",aStr);
    }
    
    self.beaconArr = beacons;
    
    [self.tableView reloadData];
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.beaconArr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *ident = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
        
    }
    
    CLBeacon *beacon = [self.beaconArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [beacon.proximityUUID UUIDString];
    
    NSString *str;
    
    switch (beacon.proximity) {
            
        case CLProximityNear:
            
            str = @"近";
            
            break;
            
        case CLProximityImmediate:
            
            str = @"超近";
            
            break;
            
        case CLProximityFar:
            
            str = @"远";
            
            break;
            
        case CLProximityUnknown:
            
            str = @"不见了";
            
            break;
            
        default:
            
            break;
            
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %ld %@ %@",str,beacon.rssi,beacon.major,beacon.minor];
    
    return cell;
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSLog(@"离开nobeacon区域了。。。");
    
//    if ([region isKindOfClass:[CLBeaconRegion class]]) {
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.alertBody = @"Are you forgetting something?";
//        notification.soundName = @"Default";
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//    }
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // always update UI
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
