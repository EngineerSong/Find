//
//  TwoViewController.m
//  Find
//
//  Created by barara on 15/8/4.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "TwoViewController.h"
#import "TwoGoViewController.h"

@interface TwoViewController () <AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Device
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    
    [ _output setRectOfInterest : CGRectMake (( 124 )/ self.view.frame.size.height ,(( self.view.frame.size.width - 220 )/ 2 )/ self.view.frame.size.width , 220 / self.view.frame.size.height , 220 / self.view.frame.size.width )];
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    
    _session = [[AVCaptureSession alloc]init];
    
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
        
    {
        
        [_session addInput:self.input];
        
    }
    
    if ([_session canAddOutput:self.output])
        
    {
        
        [_session addOutput:self.output];
        
    }
    
    if ([_session canAddOutput:_output]){
        [_session addOutput:_output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    
    _preview.frame =self.view.layer.bounds;
    
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    
    // Start
    
    [_session startRunning];
    
    
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
        
    {
        
        //停止扫描
        
        [_session stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
        stringValue = metadataObject.stringValue;
        
        NSLog(@"%@",stringValue);
        
        TwoGoViewController *tv = [[TwoGoViewController alloc] init];
        tv.url = stringValue;
        [self.navigationController pushViewController:tv animated:YES];
        
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
