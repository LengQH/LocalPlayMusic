//
//  ViewController.m
//  TestAApp
//
//  Created by 冷求慧 on 17/3/24.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "ViewController.h"

typedef void (^TouchBlock)(UIEvent *event);   // 用来锁屏点击音乐按钮的回调

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define animationTime  12.0   // 动画需要的时间

#define songNumber  3      // 歌曲的数量(本地的只有三个)  第一首是:Owl City的《Good Time》   第二首是:CRITTY的《诗画小镇》  第三首是:可歆的《离心咒》

@interface ViewController ()<AVAudioPlayerDelegate>
/**
 *  所有歌曲的信息(两层数组)
 */
@property (nonatomic,strong)NSMutableArray<NSArray<NSString *> *> *allSongMess;
/**
 *  本地音乐的地址数组
 */
@property (nonatomic,strong)NSMutableArray<NSURL *>  *arrAddSongUrl;
/**
 *  播放器对象
 */
@property (nonatomic,strong)AVAudioPlayer   *player;
/**
 *  当前播放的下标
 */
@property (nonatomic,assign)NSInteger      currentIndex;
/**
 *  锁屏的回调
 */
@property (nonatomic,copy)TouchBlock       block;

@end

@implementation ViewController
// 懒加载
-(NSMutableArray<NSArray<NSString *> *> *)allSongMess{
    if (_allSongMess==nil) {
        _allSongMess=[[NSMutableArray alloc]init];
    }
    return _allSongMess;
}
// 懒加载
-(NSMutableArray *)arrAddSongUrl{
    if (_arrAddSongUrl==nil) {
        _arrAddSongUrl=[NSMutableArray array];
        for (int i=0; i<songNumber; i++) {  // 本地只有三首歌
            NSURL *loadUrl=[[NSBundle mainBundle]URLForResource:[NSString stringWithFormat:@"music%zi",i] withExtension:@"mp3"];
            [_arrAddSongUrl addObject:loadUrl];
        }
    }
    return _arrAddSongUrl;
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
#pragma mark 视图加载完毕
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self someUISet];           // 一些UI设置
    [self rotateMainImageView]; // 旋转图片
    [self addAllSongMess];                               // 添加所有的歌曲对应的信息
    [self setBackgroundRunAndAddNotification];          //  设置可以后台运行

    __weak typeof(self) lowSelf=self;
    self.block=^(UIEvent *event){    // 锁屏后的点击回调
        if (event.subtype==UIEventSubtypeRemoteControlPlay) {    //播放
            [lowSelf playOperation];
        }
        if (event.subtype==UIEventSubtypeRemoteControlPause) {   //暂停
            [lowSelf pauseOperation];
        }
        if (event.subtype==UIEventSubtypeRemoteControlStop) {   // 停止
            [lowSelf stopOperation];
        }
        if (event.subtype==UIEventSubtypeRemoteControlNextTrack) {      // 下一首
            [lowSelf nextOperation];
        }
        if (event.subtype==UIEventSubtypeRemoteControlPreviousTrack) {  // 上一首
            [lowSelf lastOperation];
        }
    };
}
#pragma mark 一些UI设置
-(void)someUISet{
    self.mainImageView.clipsToBounds=YES;
    self.mainImageView.layer.cornerRadius=self.mainImageViewW.constant/2;
    self.mainImageView.layer.masksToBounds=YES;
    self.playButton.layer.cornerRadius=self.pauseButton.layer.cornerRadius=self.nextButton.layer.cornerRadius=self.lastButton.layer.cornerRadius=self.stopButton.layer.cornerRadius=self.playButtonH.constant/2;
    self.playButton.layer.masksToBounds=self.pauseButton.layer.masksToBounds=self.nextButton.layer.masksToBounds=self.lastButton.layer.masksToBounds=self.stopButton.layer.masksToBounds=YES;
    
    self.progressView.layer.cornerRadius=self.progressH.constant/2;
    self.progressView.layer.masksToBounds=YES;
    
    self.progressView.progressTintColor=[UIColor redColor];
    self.progressView.trackTintColor=[UIColor whiteColor];

}
#pragma mark 添加所有的歌曲信息
-(void)addAllSongMess{
    NSArray<NSString *> *arrMessWithFirst=@[@"Good Time",@"Owl City",@"Owl_City"];
    NSArray<NSString *> *arrMessWithSecond=@[@"诗画小镇",@"CRITTY",@"CRITTY"];
    NSArray<NSString *> *arrMessWithThird=@[@"离心咒",@"可歆",@"timg"];
    
    [self.allSongMess addObjectsFromArray:@[arrMessWithFirst,arrMessWithSecond,arrMessWithThird]];
    
    [self setLockScreenMess:self.allSongMess[self.currentIndex]];
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
#pragma mark 播放按钮操作
- (IBAction)playAction:(UIButton *)sender {
    [self playOperation];
}
#pragma mark 暂停按钮操作
- (IBAction)pauseAction:(UIButton *)sender {
    [self pauseOperation];
}
#pragma mark 下一首按钮操作
- (IBAction)nextAction:(UIButton *)sender {
    [self nextOperation];
}
#pragma mark 上一首按钮操作
- (IBAction)lastAction:(UIButton *)sender {
    [self lastOperation];
}
#pragma mark 停止操作
- (IBAction)stopAction:(UIButton *)sender {
    [self stopOperation];
}
#pragma mark 创建对于的播放器
-(void)createPlay{
    NSError *error=nil;
    self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:self.arrAddSongUrl[self.currentIndex] error:&error];
    self.player.numberOfLoops=0;  // 就播放一次,如果播放两次就设置为 1
    self.player.delegate=self;
    self.player.volume=1.0;     //   设置对应的音量
}
#pragma mark 调用播放
-(void)playOperation{
    
    if (!self.player.playing) {  // 没有播放
        if (!self.player) {     //  没有创建播放器对象
            [self createPlay];
        }
        BOOL playSuccess=[self.player play]; // 播放是否成功
        
        if(playSuccess){
            NSLog(@"播放成功");
        }
        else{
            NSLog(@"播放失败,请检测URL是否正确或者<AVAudioPlayer>对象是否设置为全局变量");
        }
    }
}
#pragma mark 下一个操作
-(void)nextOperation{
    self.currentIndex+=1;
    if (self.currentIndex>(songNumber-1)) {
        self.currentIndex=0;
    }
    [self.player stop];  // 停止正在播放的音乐
    self.player=nil;    //  置空当前的播放器对象
    [self createPlay]; //   重新创建和播放下一个音乐
    [self playOperation];
    
    [self setLockScreenMess:self.allSongMess[self.currentIndex]];  // 设置锁屏信息
}
#pragma mark 上一个操作
-(void)lastOperation{
    self.currentIndex-=1;
    if (self.currentIndex<0) {
        self.currentIndex=(songNumber-1);
    }
    [self.player stop];
    self.player=nil;
    [self createPlay];
    [self playOperation];
    
    [self setLockScreenMess:self.allSongMess[self.currentIndex]]; // 设置锁屏信息
    
}
#pragma mark 调用暂停
-(void)pauseOperation{
    if (self.player.playing) {  // 正在播放
        [self.player pause];
    }
}
#pragma mark 调用停止
-(void)stopOperation{
    if (self.player.playing) {  // 正在播放
        [self.player stop];
        self.player=nil;
    }
}
#pragma mark -代理方法
// 播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完成,执行下一个播放");
    [self nextOperation];
}
// 播放中出现错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog(@"播放中出现错误");
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    if (event.type==UIEventTypeRemoteControl) {   // 如果是远程事件
        if (self.block) {
            self.block(event);   // 回调
        }
    }
}
#pragma mark 拔出和插入耳机的通知回调
-(void)pullOutHeadset:(NSNotification *)notifa{

    NSDictionary *dicMess=notifa.userInfo;
    
    NSLog(@"(插入/拔出设备)通知里面的信息是:%@",dicMess);
    
    AVAudioSessionRouteDescription *sessionDesc=dicMess[AVAudioSessionRouteChangePreviousRouteKey];
    AVAudioSessionPortDescription *portDesc=[sessionDesc.outputs firstObject];
    
    int changeIntValue=[dicMess[AVAudioSessionRouteChangeReasonKey] intValue];
    if (changeIntValue==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {     // 一个旧设备不可用
        if([portDesc.portType isEqualToString:@"Headphones"]){  // 说明设备已经插入
            [self pauseOperation];  // 暂停
        }
    }
    else if(changeIntValue==AVAudioSessionRouteChangeReasonNewDeviceAvailable){ // 新的设备可用
        if ([portDesc.portType isEqualToString:@"Speaker"]) {  // 说明设备已经拔出,改为了扬声器
            [self playOperation]; //  播放
        }
    }
}
#pragma mark 设备锁屏的相关歌曲信息
-(void)setLockScreenMess:(NSArray<NSString *> *)songMess{
    if (songMess.count!=3) return;
    NSString *songName=songMess[0];     // 歌曲名
    NSString *singerName=songMess[1];  //  歌手名
    NSString *showImageName=songMess[2]; // 显示的图片名
    
    
    BOOL isChange=[[UIDevice currentDevice].systemName floatValue]>=10.0;
    __block UIImage *imageObj=[UIImage imageNamed:showImageName];
    MPMediaItemArtwork *itemArtwork=[[MPMediaItemArtwork alloc]initWithImage:imageObj];  // 这个方法只能IOS到 IOS-10.0
    if (isChange) {
        itemArtwork=[[MPMediaItemArtwork alloc]initWithBoundsSize:imageObj.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return imageObj;
        }];
    }

    NSDictionary  *dicMess=@{
                             MPMediaItemPropertyTitle:songName,       // 歌曲的名字
                             MPMediaItemPropertyArtist:singerName,   //  歌手的名字
                             MPMediaItemPropertyArtwork:itemArtwork  //  对应的图片
                             };
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo=dicMess;
    
}
#pragma mark 旋转主图片
-(void)rotateMainImageView{
    
    id changeValue=changeValue=@(2*M_PI);
    CABasicAnimation *base=[[CABasicAnimation alloc]init];
    base.keyPath=@"transform.rotation";  // 设置是旋转类型
    base.fromValue=@(0);
    base.toValue=changeValue;         // 旋转的角度(一个顺时针,一个逆时针)
    
    base.repeatCount=CGFLOAT_MAX;   // 无限循环
    base.duration=animationTime;   //  动画执行的时间
    base.valueFunction=[CAValueFunction functionWithName:kCAMediaTimingFunctionLinear]; // 匀速运动
    base.removedOnCompletion=YES;      // 删除之前的动画路径
    base.fillMode=kCAFillModeForwards;
    
    [self.mainImageView.layer addAnimation:base forKey:nil];  // 添加视图动画

}
@end
