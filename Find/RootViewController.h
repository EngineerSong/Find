//
//  RootViewController.h
//  Find
//
//  Created by barara on 15/8/4.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface RootViewController : UIViewController

@property (nonatomic, strong) UITableView *tv;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (strong, nonatomic) CLLocationManager * locationmanager;
@property (strong, nonatomic) CLBeaconRegion *beacon1;//被扫描的iBeacon

@end
