//
//  BlueViewController.h
//  Find
//
//  Created by barara on 15/8/20.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlueViewController : UIViewController <CBCentralManagerDelegate,UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) NSMutableArray *arrayBLE;

@property (nonatomic, strong) UITableView *tableView;

@end
