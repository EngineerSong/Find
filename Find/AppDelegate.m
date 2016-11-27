//
//  AppDelegate.m
//  Find
//
//  Created by barara on 15/7/23.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

#define kUUID @"DFA3EF9F-4C31-B4CC-35DC-9295E4C942D8"//iBeacon的uuid可以换成自己设备的uuid

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSDate *)getCustomDateWithHour:(NSInteger)hour and:(NSInteger)min
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:min];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // This location manager will be used to notify the user of region state transitions.
    
    NSDate *date9 = [self getCustomDateWithHour:14 and:30];
    NSDate *date17 = [self getCustomDateWithHour:14 and:33];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date9]==NSOrderedDescending && [currentDate compare:date17]==NSOrderedAscending)
    {
        NSLog(@"时间在限定区域之间");
    }else{
        NSLog(@"时间不在限定区域之间");
    }
    
    //开启通知
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];//注册本地推送
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    RootViewController *vc = [[RootViewController alloc] init];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nc;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    
    
    
    
    //开启通知
    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    // 推送声音
//    //notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.soundName = @"beep.m4r";
//    
//    if(state == CLRegionStateInside)
//    {
//        notification.alertBody = @"You're inside the region";
//    }
//    else if(state == CLRegionStateOutside)
//    {
//        notification.alertBody = @"You're outside the region";
//    }
//    else
//    {
//        return;
//    }
//    
////    UIApplication *app = [UIApplication sharedApplication];
////    [app scheduleLocalNotification:notification];
//    
//    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
//    // If its not, iOS will display the notification to the user.
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    
    
    
    
}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    NSLog(@"有iBeacon进入监测范围了");
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"有iBeacon进入监测范围了";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    //[self.locationmanager startRangingBeaconsInRegion:self.beacon1];//开始RegionBeacons
    //[self.locationmanager startRangingBeaconsInRegion:self.beacon2];//开始RegionBeacons
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSLog(@"离开nobeacon区域了。。。");
    
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"离开iBeacon监测范围了";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
