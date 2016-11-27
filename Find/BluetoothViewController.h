//
//  BluetoothViewController.h
//  Find
//
//  Created by barara on 15/8/11.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface BluetoothViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) CBCentralManager *cbCentralMgr;
@property (nonatomic, strong) NSMutableArray *peripheraArray;
@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *perArray;

@property (nonatomic, strong) UITableView *tableView;

@end
