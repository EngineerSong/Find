//
//  BluetoothViewController.m
//  Find
//
//  Created by barara on 15/8/11.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "BluetoothViewController.h"
#import "BluetoothModel.h"
#import "BluetoothCell.h"
#import <Foundation/Foundation.h>

#define serviceUUID          @"F8F0"
#define characteristicUUID12  @"F8FC"
#define characteristicUUID13  @"F8FD"

#define CRC16_CCITT			0x1021
#define SEED_CRC16		CRC16_CCITT

@interface BluetoothViewController () <UITextViewDelegate>

{
    //CBCentralManager* _manager;
    //NSMutableData* _data;
    CBPeripheral* _peripheral;
    NSString *kCharacteristicUUID;
    BOOL *_isExist;
    
    NSMutableString *_getUUID;
    CBPeripheral *_getPeripheral;
    
    CBCharacteristic *_character12;
    CBCharacteristic *_character13;
    
    UITextField *_tf;
    
    UILabel *_label;
    
    NSThread *_thread;
    
    UITextView *_textView;
    
    int _a;
    int _b;
    
    int _m;
    int _n;
    
    int _isShutDown;
    
    int _record;
    
    int _isFirst;
    
    int _isConnectAgain;
    
    int _isStartWrite;
    
    int _indexInt;
    
    Byte _dataArr[20];
    
    NSFileManager *_fileManage;
    NSFileHandle *_fileHandle;
    
    UITapGestureRecognizer *_tap;
}

@end

UInt16 Get_CRC16_Check_Sum( unsigned char *ptr, UInt16 length )
{
    unsigned char * data_buf=ptr;
    UInt16 data_length=length;
    UInt16 crc_value=0x00;
    UInt16 data_tpm=0;
    
    UInt16 i=0;
    UInt16 k=0;
    
    for( i=0; i<data_length; i++ )
    {
        data_tpm^=(data_buf[i]<<8);
        
        for( k=0; k<8; k++ )
        {
            if(((data_tpm^crc_value)&0x8000)==0x8000)
            {
                crc_value<<=1;
                crc_value^=SEED_CRC16;
            }
            else
            {
                crc_value<<=1;
            }
            
            data_tpm<<=1;
        }
    }
    
    return (UInt16)crc_value;
}

@implementation BluetoothViewController

- (void)tapp
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isConnectAgain = 0;
    
    _isFirst = 0;
    
    _record = 1;
    
    _isStartWrite = 0;
    
    _indexInt = 0;
    
    _dataArr[0] = 0x00;
    _dataArr[1] = 0x00;
    
    _dataArr[2] = 0x00;
    _dataArr[3] = 0x01;
    _dataArr[4] = 0x02;
    _dataArr[5] = 0x03;
    _dataArr[6] = 0x04;
    _dataArr[7] = 0x05;
    _dataArr[8] = 0x06;
    _dataArr[9] = 0x07;
    _dataArr[10] = 0x08;
    _dataArr[11] = 0x09;
    _dataArr[12] = 0x0A;
    _dataArr[13] = 0x0B;
    _dataArr[14] = 0x0C;
    _dataArr[15] = 0x0D;
    _dataArr[16] = 0x0E;
    _dataArr[17] = 0x0F;
    
    UInt16 getCrc16 = Get_CRC16_Check_Sum(_dataArr, 18);
    NSString *str = [NSString stringWithFormat:@"%x",getCrc16];
    NSLog(@"getCrc16 = %hu,str = %@",getCrc16,str);
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    Byte *getCrcByte = (Byte *)[data bytes];
//    NSLog(@"getCrcByte = %x %x",getCrcByte[0]&0xff,getCrcByte[1]&0xff);
    
    _dataArr[18] = getCrc16 >> 8;
    _dataArr[19] = getCrc16;
    
    NSLog(@"arr18 = %x, arr19 = %x",_dataArr[18]&0xff,_dataArr[19]&0xff);
    
    UIDevice* curDev = [UIDevice currentDevice];
    NSLog(@"\tUUID        : %@", curDev.identifierForVendor.UUIDString);
    kCharacteristicUUID = [NSString stringWithString:curDev.identifierForVendor.UUIDString];
    NSLog(@"uuid = %@",kCharacteristicUUID);
    
    //创建一个中央
    self.cbCentralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.cbCentralMgr.delegate = self;
    self.peripheraArray = [NSMutableArray array];
    
    _dataArray = [NSMutableArray array];
    _perArray = [NSMutableArray array];
    
//    _tap = [[UITapGestureRecognizer alloc] init];
//    [_tap addTarget:self action:@selector(tapp)];
//    [self.view addGestureRecognizer:_tap];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100-60)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    [self.view addSubview:_tableView];
    
    _tf = [[UITextField alloc] initWithFrame:CGRectMake(10, 10+64, self.view.frame.size.width-100, 40)];
    _tf.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_tf];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.frame.size.width-80, 10+64, 70, 40);
    [btn setTitle:@"send" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//    _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 60+64, self.view.frame.size.width-100, 40)];
//    _label.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:_label];
    
    UIButton *btnRemove = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRemove.frame = CGRectMake(10, 60+64, self.view.frame.size.width-100, 40);
    [btnRemove setTitle:@"清除文件数据" forState:UIControlStateNormal];
    [btnRemove setBackgroundColor:[UIColor blueColor]];
    [btnRemove addTarget:self action:@selector(btnRemove) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRemove];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(self.view.frame.size.width-80, 60+64, 70, 40);
    [btn2 setTitle:@"stop" forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor blueColor]];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60)];
    _textView.font = [UIFont fontWithName:@"Arial" size:18.0];
    _textView.backgroundColor = [UIColor blackColor];
    _textView.textColor = [UIColor whiteColor];
    _textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _textView.scrollEnabled = YES;
    //_textView.selectable = YES;//选择复制功能
    //_textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    _textView.delegate = self;
    _textView.editable = NO;//禁止编辑
    [self.view addSubview:_textView];
}

- (void)btnRemove
{
    NSString *path = [NSString stringWithFormat:@"%@",NSHomeDirectory()];
    [_fileManage removeItemAtPath:[path stringByAppendingString:@"/timeFile.txt"] error:nil];
    
    NSString *pathNew = [NSString stringWithFormat:@"%@/timeFile.txt",NSHomeDirectory()];
    [_fileManage createFileAtPath:pathNew contents:nil attributes:nil];
    
    NSLog(@"文件数据已清除");
    
    _textView.text = @"文件数据已清除\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
}

- (void)btn2Click
{
    
    _isShutDown = 1;
    
    _isStartWrite = 0;
    
    if (_getPeripheral) {
        [_cbCentralMgr cancelPeripheralConnection:_getPeripheral];
    }
    
    [_perArray removeAllObjects];
    
    [self.tableView reloadData];
    
    [self.cbCentralMgr scanForPeripheralsWithServices:nil options:_dic];
    
    _isFirst = 0;
    
}

//点击发送按钮
- (void)btnClick
{
    
    _isFirst = 1;
    _isShutDown = 0;
        
    _textView.text = @"数据发送中...\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
    Byte startWriteByte[1];
    startWriteByte[0] = 0x10;
    NSData * myData = [NSData dataWithBytes:startWriteByte length:1];
    if (_getPeripheral && _character12) {
        [_getPeripheral writeValue:myData forCharacteristic:_character12 type:CBCharacteristicWriteWithResponse];
    }
    
}

//- (void)btnClick
//{
////    [_getPeripheral writeValue:[_tf.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_character type:CBCharacteristicWriteWithResponse];
////    
////    //NSLog(@"data = %@",[_tf.text dataUsingEncoding:NSUTF8StringEncoding]);
////    
////    _tf.text = @"";
//    
//    
//    if (_character) {
//        _textView.text = @"数据发送中...\n";
//        if (_textView.text.length > 100) {
//            _textView.text = @"";
//        }
//    }
//    
//    _isOpen = NO;
//    
//    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(func1) object:nil];
//    _thread.name = @"线程1";
//    [_thread start];
//    
//    
//}
//
//- (void)func1
//{
//    
//    //Byte dataArr[20];
//    
//    for ( int i = _a; i < 256; i++) {
//        for ( int j = 0; j <256; j++) {
//            _dataArr[2] = i;
//            _dataArr[3] = j;
//            
//            NSData * myData = [NSData dataWithBytes:_dataArr length:20];
//            
//            if (_isOpen == YES) {
//                
//                NSLog(@"小伙子停下来");
//                
//                //[NSThread exit];
//                
//                return;
//            }
//            
//            if (_getPeripheral && _character) {
//                [_getPeripheral writeValue:myData forCharacteristic:_character type:CBCharacteristicWriteWithResponse];
//            }
//            
//            //sleep(0.0025);
//        }
//    }
//    NSLog(@"全部数据发送完成");
//    //[NSThread exit];
//    
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _perArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BluetoothCell *cell = [tableView dequeueReusableCellWithIdentifier:@"qqq"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BluetoothCell" owner:self options:nil] lastObject];
    }
    
    BluetoothModel *bm = self.perArray[indexPath.row];
    cell.nameLabel.text = bm.name;
    cell.UUIDLabel.text = bm.UUID;
    cell.RSSILabel.text = [NSString stringWithFormat:@"%@",bm.RSSI];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_cbCentralMgr stopScan];
    BluetoothModel *bm = _perArray[indexPath.row];
    _getUUID = [[NSMutableString alloc] initWithString:bm.UUID];
    _getPeripheral = bm.peripheral;
    NSLog(@"per = %@",_getPeripheral);
    
    //开始连接周边
    [_cbCentralMgr connectPeripheral:_getPeripheral options:nil];
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙未打开");
        return;
    }
    //开始寻找所有的服务
    _dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.cbCentralMgr scanForPeripheralsWithServices:nil options:_dic];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (_peripheral != peripheral) {
        _peripheral = peripheral;
    }
    
    NSString *UUID = [peripheral.identifier UUIDString];
    //NSString *UUID1 = CFBridgingRelease(CFUUIDCreateString(NULL, _peripheral.UUID));
    NSLog(@"name:%@,UUID: %@,RSSI:%@",_peripheral.name,UUID,RSSI);
    
    BluetoothModel *bm = [[BluetoothModel alloc] init];
    bm.peripheral = _peripheral;
    bm.name = _peripheral.name;
    bm.UUID = UUID;
    bm.RSSI = RSSI;
    if (_perArray.count == 0) {
        [_perArray addObject:bm];
    }else{
        for (BluetoothModel *bm in _perArray) {
            if ([bm.UUID isEqualToString:UUID]) {
                bm.RSSI = RSSI;
                _isExist = 1;
            }
        }
        if (_isExist == 0) {
            [_perArray addObject:bm];
        }
        _isExist = 0;
    }
    
    NSLog(@"perArray = %@",_perArray);
    [self.tableView reloadData];
    
}

//连接周边成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    _getPeripheral.delegate = self;
    //连接周边服务
    
    _textView.text = @"连接周边成功\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
    NSLog(@"getUUID = %@",_getUUID);
    
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:_getUUID]]];
    
    [_getPeripheral discoverServices:nil];
    
}

//连接周边失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败");
    
    _textView.text = @"连接周边失败\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
}

//连接周边服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"错误的服务");
        
        _textView.text = @"服务错误\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
        
        return;
    }
    
    //遍历服务
    for (CBService* service in peripheral.services) {
        NSLog(@"遍历中：serviceUUID为%@",service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]]) {
            
            _textView.text = @"找到目标服务\n";
            if (_textView.text.length > 100) {
                _textView.text = @"";
            }
            
            //连接特征
            //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
            
            [peripheral discoverCharacteristics:nil forService:service];
            
        }
        //[service.peripheral discoverCharacteristics:nil forService:service];
        
    }
    
}

//发现特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"连接特征失败");
        
        _textView.text = @"连接特征失败\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
        
        return;
    }
    
    //遍历特征
    //if ([service.UUID isEqual:[CBUUID UUIDWithString:_getUUID]]) {
        for (CBCharacteristic* characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID12]]) {
            
                _textView.text = @"找到特征12\n";
                if (_textView.text.length > 100) {
                    _textView.text = @"";
                }
            
            //[peripheral readValueForCharacteristic:characteristic];
            
            NSLog(@"character12 = %@",characteristic);
                
                _character12 = characteristic;
            
                //开始监听特征
                //[peripheral readValueForCharacteristic:characteristic];
                
            }
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID13]]){
                
                _textView.text = @"找到特征13\n";
                if (_textView.text.length > 100) {
                    _textView.text = @"";
                }
                
                _character13 = characteristic;
                
            }
        }
    //}
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"发送失败");
        _textView.text = @"发送失败\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
        return;
    }
    
    //NSLog(@"发送成功");
//    if (characteristic == _character13) {
//        //[_getPeripheral readValueForCharacteristic:_character12];
//        
//        _indexInt++;
//        
//        //            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验正确\n",_indexInt];
//        //            if (_textView.text.length > 100) {
//        //                _textView.text = @"";
//        //            }
//        
//        if (![_tf.text isEqual:@""]) {
//            if (_indexInt >= [_tf.text intValue]) {
//                
//                _textView.text = @"数据发送结束\n";
//                if (_textView.text.length > 100) {
//                    _textView.text = @"";
//                }
//                
//                Byte endByte[1];
//                endByte[0] = 0x11;
//                NSData *data = [NSData dataWithBytes:endByte length:1];
//                [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithResponse];
//                
//                return;
//            }
//        }else{
//            if (_indexInt >= 7500) {
//                
//                _textView.text = @"数据发送结束\n";
//                if (_textView.text.length > 100) {
//                    _textView.text = @"";
//                }
//                
//                Byte endByte[1];
//                endByte[0] = 0x11;
//                NSData *data = [NSData dataWithBytes:endByte length:1];
//                [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithResponse];
//                
//                return;
//            }
//        }
//        
//        if (_dataArr[1] == 0xff) {
//            _dataArr[0] = _dataArr[0] + 1;
//            _dataArr[1] = 0x00;
//        }else {
//            _dataArr[1] = _dataArr[1] + 1;
//        }
//        
//        if (_dataArr[2] >= 0xF0) {
//            
//            _dataArr[2] = 0x00;
//            _dataArr[3] = 0x01;
//            _dataArr[4] = 0x02;
//            _dataArr[5] = 0x03;
//            _dataArr[6] = 0x04;
//            _dataArr[7] = 0x05;
//            _dataArr[8] = 0x06;
//            _dataArr[9] = 0x07;
//            _dataArr[10] = 0x08;
//            _dataArr[11] = 0x09;
//            _dataArr[12] = 0x0A;
//            _dataArr[13] = 0x0B;
//            _dataArr[14] = 0x0C;
//            _dataArr[15] = 0x0D;
//            _dataArr[16] = 0x0E;
//            _dataArr[17] = 0x0F;
//            
//        }else{
//            for (int i = 2; i < 18; i ++) {
//                _dataArr[i] = _dataArr[i] + 16;
//            }
//        }
//        
//        UInt16 getCrc16 = Get_CRC16_Check_Sum(_dataArr, 18);
//        _dataArr[18] = getCrc16 >> 8;
//        _dataArr[19] = getCrc16;
//        
//        NSMutableString *muSendStr = [[NSMutableString alloc] init];
//        
//        for (int i = 0; i < 20; i++) {
//            
//            NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
//            
//            [muSendStr appendString:str];
//            
//        }
//        
//        NSLog(@"sendStr = %@",muSendStr);
//        
//        NSData *data = [NSData dataWithBytes:_dataArr length:20];
//        [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithResponse];
//    }
    
    if (characteristic == _character12 && _indexInt == 0) {
        [NSThread sleepForTimeInterval:2.0];   //设置进程停止2秒
        [_getPeripheral readValueForCharacteristic:_character12];
    }
    
//    NSData * myData = [NSData dataWithBytes:_dataArr length:20];
//    if (_getPeripheral && _character) {
//        [_getPeripheral writeValue:myData forCharacteristic:_character type:CBCharacteristicWriteWithResponse];
//    }
}

//收到新值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSString* str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", str);
//    
//    _label.text = str;
    Byte *testByte = (Byte *)[characteristic.value bytes];
    
    NSMutableString *muStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [characteristic.value length]; i++) {
        
        NSString *str = [NSString stringWithFormat:@" %x",testByte[i]&0xff];
        
        [muStr appendString:str];
        
    }
    
    NSLog(@"responseStr = %@",muStr);
    
    if (_isStartWrite == 1 && characteristic == _character12) {
        if (testByte[0] == 0x30) {
            
            _indexInt ++;
            
            [self writeWithoutResponseAndRead];
            
//            _indexInt++;
//            
////            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验正确\n",_indexInt];
////            if (_textView.text.length > 100) {
////                _textView.text = @"";
////            }
//            
//            if (![_tf.text isEqual:@""]) {
//                if (_indexInt >= [_tf.text intValue]) {
//                    
//                    _textView.text = @"数据发送结束\n";
//                    if (_textView.text.length > 100) {
//                        _textView.text = @"";
//                    }
//                    
//                    Byte endByte[1];
//                    endByte[0] = 0x11;
//                    NSData *data = [NSData dataWithBytes:endByte length:1];
//                    [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithResponse];
//                    
//                    return;
//                }
//            }else{
//                if (_indexInt >= 7500) {
//                    
//                    _textView.text = @"数据发送结束\n";
//                    if (_textView.text.length > 100) {
//                        _textView.text = @"";
//                    }
//                    
//                    Byte endByte[1];
//                    endByte[0] = 0x11;
//                    NSData *data = [NSData dataWithBytes:endByte length:1];
//                    [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithResponse];
//                    
//                    return;
//                }
//            }
//            
//            if (_dataArr[1] == 0xff) {
//                _dataArr[0] = _dataArr[0] + 1;
//                _dataArr[1] = 0x00;
//            }else {
//                _dataArr[1] = _dataArr[1] + 1;
//            }
//            
//            if (_dataArr[2] >= 0xF0) {
//                
//                _dataArr[2] = 0x00;
//                _dataArr[3] = 0x01;
//                _dataArr[4] = 0x02;
//                _dataArr[5] = 0x03;
//                _dataArr[6] = 0x04;
//                _dataArr[7] = 0x05;
//                _dataArr[8] = 0x06;
//                _dataArr[9] = 0x07;
//                _dataArr[10] = 0x08;
//                _dataArr[11] = 0x09;
//                _dataArr[12] = 0x0A;
//                _dataArr[13] = 0x0B;
//                _dataArr[14] = 0x0C;
//                _dataArr[15] = 0x0D;
//                _dataArr[16] = 0x0E;
//                _dataArr[17] = 0x0F;
//                
//            }else{
//                for (int i = 2; i < 18; i ++) {
//                    _dataArr[i] = _dataArr[i] + 16;
//                }
//            }
//            
//            UInt16 getCrc16 = Get_CRC16_Check_Sum(_dataArr, 18);
//            _dataArr[18] = getCrc16 >> 8;
//            _dataArr[19] = getCrc16;
//            
//            NSMutableString *muSendStr = [[NSMutableString alloc] init];
//            
//            for (int i = 0; i < 20; i++) {
//                
//                NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
//                
//                [muSendStr appendString:str];
//                
//            }
//            
//            NSLog(@"sendStr = %@",muSendStr);
//            
//            NSData *data = [NSData dataWithBytes:_dataArr length:20];
//            [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithResponse];
        }else{
            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验错误\n",_indexInt+1];
            if (_textView.text.length > 100) {
                _textView.text = @"";
            }
            
            NSMutableString *muSendStr = [[NSMutableString alloc] init];
            
            for (int i = 0; i < 20; i++) {
                
                NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
                
                [muSendStr appendString:str];
                
            }
            
            NSLog(@"sendStr = %@",muSendStr);
            
            NSData *data = [NSData dataWithBytes:_dataArr length:20];
            [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithoutResponse];
            
            [NSThread sleepForTimeInterval:0.05];   //设置进程停止2秒
            
            [_getPeripheral readValueForCharacteristic:_character12];
        }
    }
    
    if (_isStartWrite == 0 && characteristic == _character12 && testByte[0] != 0x20 && testByte[0] != 0x21 && testByte[0] != 0x30 && testByte[0] != 0x31) {
        _textView.text = @"特征12为未知数据\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
        return;
    }
    
    if (_isStartWrite == 0 && characteristic == _character12 && testByte[0] == 0x20) {
        _textView.text = @"从机已准备好接收数据\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
        
        _isStartWrite = 1;
        
        _indexInt = 0;
        
        
        [self writeWithoutResponseAndRead];
        
//        for (int i = 0; i < 7501; i ++) {
//            
//            if (i == 0) {
//                NSData *data = [NSData dataWithBytes:_dataArr length:20];
//                [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithoutResponse];
//            }else{
////                    if (_isStartWrite == 1 && characteristic == _character12) {
////                        if (testByte[0] == 0x30) {
//                
//                            _indexInt++;
//                
//                //            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验正确\n",_indexInt];
//                //            if (_textView.text.length > 100) {
//                //                _textView.text = @"";
//                //            }
//                
//                            if (![_tf.text isEqual:@""]) {
//                                if (_indexInt >= [_tf.text intValue]) {
//                
//                                    _textView.text = @"数据发送结束\n";
//                                    if (_textView.text.length > 100) {
//                                        _textView.text = @"";
//                                    }
//                
//                                    Byte endByte[1];
//                                    endByte[0] = 0x11;
//                                    NSData *data = [NSData dataWithBytes:endByte length:1];
//                                    [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithoutResponse];
//                
//                                    return;
//                                }
//                            }else{
//                                if (_indexInt >= 7500) {
//                
//                                    _textView.text = @"数据发送结束\n";
//                                    if (_textView.text.length > 100) {
//                                        _textView.text = @"";
//                                    }
//                
//                                    Byte endByte[1];
//                                    endByte[0] = 0x11;
//                                    NSData *data = [NSData dataWithBytes:endByte length:1];
//                                    [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithoutResponse];
//                
//                                    return;
//                                }
//                            }
//                
//                            if (_dataArr[1] == 0xff) {
//                                _dataArr[0] = _dataArr[0] + 1;
//                                _dataArr[1] = 0x00;
//                            }else {
//                                _dataArr[1] = _dataArr[1] + 1;
//                            }
//                
//                            if (_dataArr[2] >= 0xF0) {
//                
//                                _dataArr[2] = 0x00;
//                                _dataArr[3] = 0x01;
//                                _dataArr[4] = 0x02;
//                                _dataArr[5] = 0x03;
//                                _dataArr[6] = 0x04;
//                                _dataArr[7] = 0x05;
//                                _dataArr[8] = 0x06;
//                                _dataArr[9] = 0x07;
//                                _dataArr[10] = 0x08;
//                                _dataArr[11] = 0x09;
//                                _dataArr[12] = 0x0A;
//                                _dataArr[13] = 0x0B;
//                                _dataArr[14] = 0x0C;
//                                _dataArr[15] = 0x0D;
//                                _dataArr[16] = 0x0E;
//                                _dataArr[17] = 0x0F;
//                
//                            }else{
//                                for (int i = 2; i < 18; i ++) {
//                                    _dataArr[i] = _dataArr[i] + 16;
//                                }
//                            }
//                
//                            UInt16 getCrc16 = Get_CRC16_Check_Sum(_dataArr, 18);
//                            _dataArr[18] = getCrc16 >> 8;
//                            _dataArr[19] = getCrc16;
//                
//                            NSMutableString *muSendStr = [[NSMutableString alloc] init];
//                
//                            for (int i = 0; i < 20; i++) {
//                
//                                NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
//                                
//                                [muSendStr appendString:str];
//                                
//                            }
//                            
//                            NSLog(@"sendStr = %@",muSendStr);
//                            
//                            NSData *data = [NSData dataWithBytes:_dataArr length:20];
//                            [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithoutResponse];
////                        }else{
////                            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验错误\n",_indexInt+1];
////                            if (_textView.text.length > 100) {
////                                _textView.text = @"";
////                            }
////                            
////                            NSMutableString *muSendStr = [[NSMutableString alloc] init];
////                            
////                            for (int i = 0; i < 20; i++) {
////                                
////                                NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
////                                
////                                [muSendStr appendString:str];
////                                
////                            }
////                            
////                            NSLog(@"sendStr = %@",muSendStr);
////                            
////                            NSData *data = [NSData dataWithBytes:_dataArr length:20];
////                            [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithResponse];
////                        }
////                    }
//
//            }
//            
//        }
        
//        NSData *data = [NSData dataWithBytes:_dataArr length:20];
//        [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithResponse];
    }
    
    if (_isStartWrite == 0 && characteristic == _character12 && testByte[0] == 0x21) {
        _textView.text = @"从机未准备好接收数据\n";
        if (_textView.text.length > 100) {
            _textView.text = @"";
        }
    }
//    if (_isFirst == 0) {
//        return;
//    }
//    
//    if (_isShutDown == 1) {
//        return;
//    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    _isConnectAgain = 1;
    
    _isStartWrite = 0;
    
    _textView.text = @"蓝牙断开\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
    if (_isShutDown == 1) {
        return;
    }
    
    _textView.text = @"蓝牙正在重连...\n";
    if (_textView.text.length > 100) {
        _textView.text = @"";
    }
    
    [_cbCentralMgr connectPeripheral:_getPeripheral options:nil];
    
//    sleep(5);
//    
//    NSData * myData = [NSData dataWithBytes:_dataArr length:20];
//    if (_getPeripheral && _character) {
//        [_getPeripheral writeValue:myData forCharacteristic:_character type:CBCharacteristicWriteWithResponse];
//    }
}

- (void)writeWithoutResponseAndRead
{
    if (_indexInt == 0) {
        NSData *data = [NSData dataWithBytes:_dataArr length:20];
        [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithResponse];
        
        [NSThread sleepForTimeInterval:0.05];   //设置进程停止2秒
        
        //sleep(2);
        
        [_getPeripheral readValueForCharacteristic:_character12];
    }else{
        //                    if (_isStartWrite == 1 && characteristic == _character12) {
        //                        if (testByte[0] == 0x30) {
        
        //_indexInt++;
        
        //            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验正确\n",_indexInt];
        //            if (_textView.text.length > 100) {
        //                _textView.text = @"";
        //            }
        
        if (![_tf.text isEqual:@""]) {
            if (_indexInt >= [_tf.text intValue]) {
                
                _textView.text = @"数据发送结束\n";
                if (_textView.text.length > 100) {
                    _textView.text = @"";
                }
                
                Byte endByte[1];
                endByte[0] = 0x11;
                NSData *data = [NSData dataWithBytes:endByte length:1];
                [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithoutResponse];
                
                return;
            }
        }else{
            if (_indexInt >= 7500) {
                
                _textView.text = @"数据发送结束\n";
                if (_textView.text.length > 100) {
                    _textView.text = @"";
                }
                
                Byte endByte[1];
                endByte[0] = 0x11;
                NSData *data = [NSData dataWithBytes:endByte length:1];
                [_getPeripheral writeValue:data forCharacteristic:_character12 type:CBCharacteristicWriteWithoutResponse];
                
                return;
            }
        }
        
        if (_dataArr[1] == 0xff) {
            _dataArr[0] = _dataArr[0] + 1;
            _dataArr[1] = 0x00;
        }else {
            _dataArr[1] = _dataArr[1] + 1;
        }
        
        if (_dataArr[2] >= 0xF0) {
            
            _dataArr[2] = 0x00;
            _dataArr[3] = 0x01;
            _dataArr[4] = 0x02;
            _dataArr[5] = 0x03;
            _dataArr[6] = 0x04;
            _dataArr[7] = 0x05;
            _dataArr[8] = 0x06;
            _dataArr[9] = 0x07;
            _dataArr[10] = 0x08;
            _dataArr[11] = 0x09;
            _dataArr[12] = 0x0A;
            _dataArr[13] = 0x0B;
            _dataArr[14] = 0x0C;
            _dataArr[15] = 0x0D;
            _dataArr[16] = 0x0E;
            _dataArr[17] = 0x0F;
            
        }else{
            for (int i = 2; i < 18; i ++) {
                _dataArr[i] = _dataArr[i] + 16;
            }
        }
        
        UInt16 getCrc16 = Get_CRC16_Check_Sum(_dataArr, 18);
        _dataArr[18] = getCrc16 >> 8;
        _dataArr[19] = getCrc16;
        
        NSMutableString *muSendStr = [[NSMutableString alloc] init];
        
        for (int i = 0; i < 20; i++) {
            
            NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
            
            [muSendStr appendString:str];
            
        }
        
        NSLog(@"sendStr = %@",muSendStr);
        
        NSData *data = [NSData dataWithBytes:_dataArr length:20];
        [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithoutResponse];
        
        [NSThread sleepForTimeInterval:0.05];   //设置进程停止2秒
        
        //sleep(2);
        
        [_getPeripheral readValueForCharacteristic:_character12];
        
        //                        }else{
        //                            _textView.text = [NSString stringWithFormat:@"第%d帧数据校验错误\n",_indexInt+1];
        //                            if (_textView.text.length > 100) {
        //                                _textView.text = @"";
        //                            }
        //
        //                            NSMutableString *muSendStr = [[NSMutableString alloc] init];
        //
        //                            for (int i = 0; i < 20; i++) {
        //
        //                                NSString *str = [NSString stringWithFormat:@" %x",_dataArr[i]&0xff];
        //
        //                                [muSendStr appendString:str];
        //
        //                            }
        //
        //                            NSLog(@"sendStr = %@",muSendStr);
        //
        //                            NSData *data = [NSData dataWithBytes:_dataArr length:20];
        //                            [_getPeripheral writeValue:data forCharacteristic:_character13 type:CBCharacteristicWriteWithResponse];
        //                        }
        //                    }
        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"*********");
    
    _isShutDown = 1;
    
    _isStartWrite = 0;
    
    if (_getPeripheral) {
        [_cbCentralMgr cancelPeripheralConnection:_getPeripheral];
    }
    
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
