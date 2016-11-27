//
//  BluetoothCell.h
//  Find
//
//  Created by barara on 15/8/17.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BluetoothCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *UUIDLabel;
@property (nonatomic, strong) IBOutlet UILabel *RSSILabel;



@end
