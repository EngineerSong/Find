//
//  BLEInfo.h
//  Find
//
//  Created by barara on 15/8/20.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEInfo : NSObject


@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) NSNumber *rssi;



@end
