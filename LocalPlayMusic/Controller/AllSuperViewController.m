//
//  AllSuperViewController.m
//  LocalPlayMusic
//
//  Created by 冷求慧 on 17/6/16.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "AllSuperViewController.h"

@interface AllSuperViewController ()

@end

@implementation AllSuperViewController

#pragma mark -重写Setting方法
-(void)setIsAddBGImageInVC:(BOOL)isAddBGImageInVC{
    _isAddBGImageInVC=isAddBGImageInVC;
    
    UIImageView *bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,0, screenWidthW, screenHeightH)];
    bgImageView.image=[UIImage imageNamed:@"backgroundImage"];
    bgImageView.contentMode=UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];   // 将背景视图放在最后面
}
#pragma mark 视图出现完毕
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents]; // 接受远程控制
}
#pragma mark 视图消失完毕
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [[UIApplication sharedApplication]registerForRemoteNotifications];   //  取消远程控制
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackgroundRunAndAddNotification];
}
#pragma mark 设置可以后台运行和添加对应的监听
-(void)setBackgroundRunAndAddNotification{
    AVAudioSession *session=[AVAudioSession sharedInstance];
    NSError *error=nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];  // 设置策略模式为后台
    [session setActive:YES error:nil];   // 设置为活跃状态
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];  //开启App远程事件(锁屏时使用)
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pullOutHeadset:) name:AVAudioSessionRouteChangeNotification object:nil];  // 添加耳机插入和拔出的监听,用来暂停播放中的音乐
    
}
#pragma mark 拔出和插入耳机的通知回调
-(void)pullOutHeadset:(NSNotification *)notifa{
    
    NSDictionary *dicMess=notifa.userInfo;
    
    NSLengLog(@"(插入/拔出设备)通知里面的信息是:%@",dicMess);
    
    AVAudioSessionRouteDescription *sessionDesc=dicMess[AVAudioSessionRouteChangePreviousRouteKey];
    AVAudioSessionPortDescription *portDesc=[sessionDesc.outputs firstObject];
    
    int changeIntValue=[dicMess[AVAudioSessionRouteChangeReasonKey] intValue];
    if (changeIntValue==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {     // 一个旧设备不可用
        if([portDesc.portType isEqualToString:@"Headphones"]){                     // 说明设备已经拔出,改为了扬声器
            [[MySingleton shareMySingleton] pauseAction];  // 暂停音乐
            self.isInsertHeadset=NO;
        }
    }
    else if(changeIntValue==AVAudioSessionRouteChangeReasonNewDeviceAvailable){ // 新的设备可用
        if ([portDesc.portType isEqualToString:@"Speaker"]) {                   // 说明设备已经插入
            [[MySingleton shareMySingleton] playAction:self.musicModel.playUrl];// 播放音乐
            self.isInsertHeadset=YES;
        }
    }
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type==UIEventTypeRemoteControl) {   // 如果是远程事件
        if (self.block) {
            self.block(event);   // 回调
        }
    }
}
#pragma mark 重写设置锁屏信息的setting方法
-(void)setIsLockScreenMsg:(BOOL)isLockScreenMsg{
    if (!isLockScreenMsg) return;
    
    BOOL isChange=[[UIDevice currentDevice].systemName floatValue]>=10.0;
    
    __block UIImage *imageObj=[UIImage imageNamed:self.musicModel.showImageName];
    MPMediaItemArtwork *itemArtwork=[[MPMediaItemArtwork alloc]initWithImage:imageObj];  // 这个方法只能IOS到 IOS-10.0
    if (isChange) {
        itemArtwork=[[MPMediaItemArtwork alloc]initWithBoundsSize:imageObj.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return imageObj;
        }];
    }
    NSDictionary  *dicMess=@{
                             MPMediaItemPropertyTitle:self.musicModel.musicName,       //  歌曲的名字
                             MPMediaItemPropertyArtist:self.musicModel.singerName,     //  歌手的名字
                             MPMediaItemPropertyArtwork:itemArtwork  //  对应的图片
                             };
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo=dicMess;
    
}
#pragma mark 销毁控制器移除通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
