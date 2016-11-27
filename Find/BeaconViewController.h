//
//  BeaconViewController.h
//  Find
//
//  Created by barara on 15/10/28.
//  Copyright © 2015年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface BeaconViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *beaconArr;//存放扫描到的iBeacon

@property (strong, nonatomic) CLBeaconRegion *beacon1;//被扫描的iBeacon
//@property (strong, nonatomic) CLBeaconRegion *beacon2;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@property (strong, nonatomic) UITableView *tableView;

//@property (strong, nonatomic) UITextView *tv;

@end
