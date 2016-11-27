//
//  AppDelegate.h
//  Find
//
//  Created by barara on 15/7/23.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationManager;


@end

