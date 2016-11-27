//
//  RecordViewController.m
//  Find
//
//  Created by barara on 15/8/5.
//  Copyright (c) 2015年 Jay. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordViewController () <AVAudioPlayerDelegate,AVAudioRecorderDelegate>

{
    UIButton *_button;
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
}

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof (audioRouteOverride),&audioRouteOverride);
    
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button.frame = CGRectMake(100, 100, 100, 40);
    [_button setTitle:@"点击录音" forState:UIControlStateNormal];
    [_button setTitle:@"录音中..." forState:UIControlStateHighlighted];
    [_button addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
    [_button addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    //保存路径
    NSString *path = [NSString stringWithFormat:@"%@/Documents/a.pcm",NSHomeDirectory()];
    
    NSLog(@"recordPath = %@",path);
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    _recorder.delegate = self;
    //_recorder.meteringEnabled
    //准备录音
    [_recorder prepareToRecord];
    //[_recorder peakPowerForChannel:0];
    
    
}

//开始录音
- (void)startRecord
{
    
    //[_recorder deleteRecording];
    
    [_recorder record];
}

//停止录音
- (void)stopRecord
{
    [_recorder stop];
    
    NSString *path = [NSString stringWithFormat:@"%@/Documents/a.pcm",NSHomeDirectory()];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSLog(@"%@",path);
    
    
    
    //播放声音
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _player.delegate = self;
    _player.volume = 1.0;
    [_player prepareToPlay];
    [_player play];
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
