//
//  BluetoothModel.h
//  Find
//
//  Created by barara on 15/8/17.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothModel : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *UUID;
@property (nonatomic, strong) NSNumber *RSSI;



@end
