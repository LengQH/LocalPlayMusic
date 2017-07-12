//
//  MusicPlayViewController.m
//  yoli
//
//  Created by 冷求慧 on 17/6/6.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "MusicPlayViewController.h"

#import "CustomTrackSlider.h"

#import "CustomProxy.h"

#define modelField         @"MusicPlayMode"

#define animationTime       10.0      // 旋转一圈动画需要的时间
#define moveXValue          40*heightRatioWithAll      // 平移X的大小

#define alertPlayViewH         40*heightRatioWithAll   // 弹出视图的高度

#define imageViewLeftDistance  15*heightRatioWithAll  //  图片的左边距
#define imageViewW             14*heightRatioWithAll  //  图片的宽高
#define imageViewH             14*heightRatioWithAll

#define labelLeftDistance      10*heightRatioWithAll //   Label的左边距

@interface MusicPlayViewController ()<CustomTrackSliderDelegate>{
    BOOL isClickedPlayButtonWithFirst;          // 是否点击过一次播放按钮
    BOOL isClickedLastOrNextButtonWithFirst;   //  是否点击过一次上一首或者下一首按钮
}
/**
 *  定时器
 */
@property (strong,nonatomic) CADisplayLink *playLink;
/**
 *  添加播放模式图片名字
 */
@property (nonatomic,strong)NSMutableArray<NSString *> *arrAddImageName;
/**
 *  添加播放模式名字
 */
@property (nonatomic,strong)NSMutableArray<NSString *> *arrAddPlayMode;
/**
 *  播放歌曲的下标
 */
@property (nonatomic,assign)NSInteger   playSongIndex;
/**
 *  当前音乐播放模式
 */
@property (nonatomic,assign)PlayMusicMode currentPlayMode;
/**
 *  播放模式按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *randomPlayButton;
/**
 *  上一首按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *lastPlayButton;
/**
 *  播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/**
 *  下一首按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *nextPlayButton;
/**
 *  音量按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *volumeButton;

/**
 *  显示歌曲的名字
 */
@property (weak, nonatomic) IBOutlet UILabel *showSongNameLabel;
/**
 *  旋转中间图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *rotateCenterImageView;
/**
 *  旋转小图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *rotateSmallImageView;
/**
 *  播放杠图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *gangImageView;
/**
 *  播放模式弹出视图
 */
@property (nonatomic,strong)UIView  *alertPlayModeView;
/**
 *  显示播放模式的Label
 */
@property (nonatomic,strong)ChangeFontWithLabel *showPlayModeLabel;
/**
 *  音量大小视图
 */
@property (weak, nonatomic) IBOutlet CustomTrackSlider *volumeSlider;
/**
 *  音量按钮蒙版视图,防止音量按钮和Slider手势冲突
 */
@property (weak, nonatomic) IBOutlet UIView *volumeButtonMaskView;

@end

NSString *bigCircleWithBigKeyID=@"bigCircleWithBigKeyID";
NSString *smallCircleWithBigKeyID=@"smallCircleWithBigKeyID";

@implementation MusicPlayViewController

-(CADisplayLink *)playLink{
    if (_playLink==nil) {
        _playLink=[CADisplayLink displayLinkWithTarget:[CustomProxy proxyWithTarget:self] selector:@selector(rotateImageViewAction)];
        [_playLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _playLink;
}


-(NSMutableArray<NSString *> *)arrAddImageName{
    if (_arrAddImageName==nil) {
        _arrAddImageName=[NSMutableArray array];
        [_arrAddImageName addObjectsFromArray:@[@"sequencePlay",@"loopListPlay",@"onlyOnePlay",@"randomPlay"]]; // 播放模式的图片名
    }
    return _arrAddImageName;
}
-(NSMutableArray<NSString *> *)arrAddPlayMode{
    if (_arrAddPlayMode==nil) {
        _arrAddPlayMode=[NSMutableArray array];
        [_arrAddPlayMode addObjectsFromArray:@[@"顺序播放",@"列表循环",@"单曲循环",@"随机播放"]]; // 播放模式的文字描述
    }
    return _arrAddPlayMode;
}
#pragma mark 懒加载弹出播放模式视图
-(UIView *)alertPlayModeView{
    if (_alertPlayModeView==nil) {
        _alertPlayModeView=[[UIView alloc]initWithFrame:CGRectMake(0, statusToolH, screenWidthW, alertPlayViewH)];
        _alertPlayModeView.backgroundColor=cusColor(78, 142, 254, 1.0);
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(imageViewLeftDistance, alertPlayViewH/2-imageViewH/2, imageViewW, imageViewH)];
        imageView.image=[UIImage imageNamed:@"playModeWithAlert"];
        [_alertPlayModeView addSubview:imageView];
        
        CGFloat labelXValue=imageViewLeftDistance+imageViewW+labelLeftDistance;
        self.showPlayModeLabel=[[ChangeFontWithLabel alloc]initWithFrame:CGRectMake(labelXValue, 0, screenWidthW-labelXValue, alertPlayViewH)];
        self.showPlayModeLabel.textAlignment=NSTextAlignmentLeft;
        self.showPlayModeLabel.textColor=[UIColor whiteColor];
        self.showPlayModeLabel.cusFont=cusFont(16);
        [_alertPlayModeView addSubview:self.showPlayModeLabel];
    }
    return _alertPlayModeView;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(musicPlayView:isPlaying:playSongIndex:playMode:)]) {
        [self.delegate musicPlayView:self isPlaying:self.playButton.selected playSongIndex:self.playSongIndex playMode:self.currentPlayMode];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self otherOpeartion];
    [self someUISet];
    [self lockScreenAction]; //  锁屏的操作

}
#pragma mark 其他操作
-(void)otherOpeartion{
    self.playSongIndex=[self.allSongModel indexOfObject:self.currentMusicModel];   // 播放的下标
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backForegroundAction) name:UIApplicationWillEnterForegroundNotification object:nil];  // 添加回到前台的通知
}
#pragma mark 一些UI设置
-(void)someUISet{
    [self someLayoutSet];
    self.title=@"音乐播放";
    
    self.isAddBGImageInVC=YES;
    
    //进来的是否在播放音乐
    self.playButton.selected=self.isPlaying;
    if(self.isPlaying){
        [self goonPlayCurrentMusic];           // 继续播放当前音乐
        [self showGangWhenPausePlaySong:NO];
    }
    else{
        [self showGangWhenPausePlaySong:YES];  //  显示暂停播放杠
    }
    // 设置音量按钮蒙版视图
    self.volumeButtonMaskView.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(volumeActionWithView)];
    [self.volumeButtonMaskView addGestureRecognizer:tapGesture];
    
    // 设置音量Slider
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"sliderPointWithVolume"] forState:UIControlStateNormal];
    self.volumeSlider.delegate=self;
    
    [self setShowSongName:self.currentMusicModel];  // 显示歌曲的名字
    
    // 设置音乐的播放模式
    NSNumber *modelWithPlay=[MySingleton getsaveLoacalField:modelField];
    self.currentPlayMode=PlayMusicModeWithSequence;
    if (modelWithPlay) {
        self.currentPlayMode=(PlayMusicMode)[modelWithPlay integerValue];
    }
    [self.randomPlayButton setImage:[UIImage imageNamed:self.arrAddImageName[self.currentPlayMode]] forState:UIControlStateNormal];
}
#pragma mark 布局设置
-(void)someLayoutSet{
    
    if (Iphone4) {
        self.bomButtonSuperViewBomDistance.constant=26;
        self.bomButtonSuperViewH.constant=40;
        self.songNameLabelBomDistance.constant=40;
        self.songNameLabelH.constant=24;
        self.bgMusicPlayBomDistance.constant=60;
        self.sliderBomDistance.constant=46;
        return;
    }
    self.bomButtonSuperViewBomDistance.constant=self.bomButtonSuperViewBomDistance.constant*heightRatioWithAll;
    self.bomButtonSuperViewH.constant=self.bomButtonSuperViewH.constant*heightRatioWithAll;
    self.songNameLabelBomDistance.constant=self.songNameLabelBomDistance.constant*heightRatioWithAll;
    self.songNameLabelH.constant=self.songNameLabelH.constant*heightRatioWithAll;
    self.bgMusicPlayBomDistance.constant=self.bgMusicPlayBomDistance.constant*heightRatioWithAll;
    self.bgMusicPlayW.constant=self.bgMusicPlayW.constant*heightRatioWithAll;
    self.bgMusicPlayH.constant=self.bgMusicPlayH.constant*heightRatioWithAll;
    self.bigCircleSuperW.constant=self.bigCircleSuperW.constant*heightRatioWithAll;
    self.bigCircleSuperH.constant=self.bigCircleSuperH.constant*heightRatioWithAll;
    self.rotateBigCircleW.constant=self.rotateBigCircleW.constant*heightRatioWithAll;
    self.rotateBigCircleH.constant=self.rotateBigCircleH.constant*heightRatioWithAll;
    self.rotateSmallCircleW.constant=self.rotateSmallCircleW.constant*heightRatioWithAll;
    self.rotateSmallCircleH.constant=self.rotateSmallCircleH.constant*heightRatioWithAll;
    self.playMusicH.constant=self.playMusicH.constant*heightRatioWithAll;
    self.playMusicW.constant=self.playMusicW.constant*heightRatioWithAll;
    self.gangBomDistance.constant=self.gangBomDistance.constant*heightRatioWithAll;
    self.gangRightDistance.constant=self.gangRightDistance.constant*heightRatioWithAll;
    self.gangH.constant=self.gangH.constant*heightRatioWithAll;
    self.gangW.constant=self.gangW.constant*heightRatioWithAll;
}
#pragma mark 播放模式按钮操作
- (IBAction)randomPlayAction:(UIButton *)sender {
    self.volumeSlider.hidden=YES;        // 隐藏音量视图
    sender.userInteractionEnabled=NO;   // 按钮不能用户交互
    NSInteger modelIndex=(NSInteger)self.currentPlayMode;
    modelIndex+=1;
    if (modelIndex==(self.arrAddImageName.count)) {
        self.currentPlayMode=PlayMusicModeWithSequence;
        [self.randomPlayButton setImage:[UIImage imageNamed:self.arrAddImageName[self.currentPlayMode]] forState:UIControlStateNormal];
    }
    else if((modelIndex>0)&&(modelIndex<(self.arrAddImageName.count))){
        self.currentPlayMode=(PlayMusicMode)modelIndex;
        [self.randomPlayButton setImage:[UIImage imageNamed:self.arrAddImageName[self.currentPlayMode]] forState:UIControlStateNormal];
    }
    [MySingleton saveLoacalWithField:modelField value:[NSNumber numberWithInteger:self.currentPlayMode]];  // 保存音乐播放模式

    // 添加弹出视图和移除
    [[MySingleton getSystemMainWindow]addSubview:self.alertPlayModeView];
    self.showPlayModeLabel.text=[NSString stringWithFormat:@"已切换到%@",self.arrAddPlayMode[self.currentPlayMode]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.alertPlayModeView removeFromSuperview];  // 移除视图和恢复可以用户交互
        sender.userInteractionEnabled=YES;
    });
}
#pragma mark 上一首按钮操作
- (IBAction)lastPlayAction:(UIButton *)sender {
    
    self.volumeSlider.hidden=YES;               // 隐藏音量视图
    [self clickLastOrNextButtonSongShowGang];  // 显示杠和是否旋转图片
    
    if(self.playSongIndex==0){
        self.playSongIndex=self.allSongModel.count-1;
        self.currentMusicModel=self.musicModel=self.allSongModel[self.playSongIndex];
        self.isLockScreenMsg=YES;
        [self setShowSongName:self.currentMusicModel];  // 显示歌曲的名字
    }
    else if ((self.playSongIndex>0)&&(self.playSongIndex<(self.allSongModel.count))){
        self.playSongIndex-=1;
        self.currentMusicModel=self.musicModel=self.allSongModel[self.playSongIndex];
        self.isLockScreenMsg=YES;
        [self setShowSongName:self.currentMusicModel];  // 显示歌曲的名
    }
    // 重新播放
    [[MySingleton shareMySingleton] stopAction];
    [[MySingleton shareMySingleton] playAction:self.currentMusicModel.playUrl];
}
#pragma mark 播放按钮操作
- (IBAction)playAction:(UIButton *)sender {
    self.volumeSlider.hidden=YES;        // 隐藏音量视图
    self.playButton.selected=!self.playButton.selected;
    
    // 下面是判断图片是旋转还是暂停
    if(!isClickedPlayButtonWithFirst){      // 这个里面只会进来一次
        isClickedLastOrNextButtonWithFirst=isClickedPlayButtonWithFirst=YES;
        if (self.isPlaying) {
            [self playLink]; // 暂停旋转图片和显示暂停播放杠
            [self showGangWhenPausePlaySong:YES];
            [[MySingleton shareMySingleton]pauseAction];  // 暂停播放
        }
        else{
            if(self.lastPageVCIsPlayed){
                [self goonPlayCurrentMusic];  // 上个页面有播放,继续播放当前的音乐
            }
            else{
                [self resetRotateImageView]; // 上个页面没有播放,重新旋转图片和不显示暂停播放杠
            }
            [self showGangWhenPausePlaySong:NO];
        }
    }
    else{
        if(self.playButton.selected){
            [self playLink];         // 恢复旋转图片和不显示暂停播放杠
            [self showGangWhenPausePlaySong:NO];
            [[MySingleton shareMySingleton] playAction:self.currentMusicModel.playUrl];  // 恢复播放
        }
        else{
            [self playLink]; // 暂停旋转图片和显示暂停播放杠
            [self showGangWhenPausePlaySong:YES];
            [[MySingleton shareMySingleton]pauseAction];  // 暂停播放
        }
    }
}
#pragma mark 下一首按钮操作
- (IBAction)nextPlayAction:(UIButton *)sender {
    
    self.volumeSlider.hidden=YES;               // 隐藏音量视图
    [self clickLastOrNextButtonSongShowGang];  // 显示杠和是否旋转图片
    
    if (self.playSongIndex==(self.allSongModel.count-1)) {
        self.playSongIndex=0;
        self.currentMusicModel=self.musicModel=self.allSongModel[self.playSongIndex];
        self.isLockScreenMsg=YES;
        [self setShowSongName:self.currentMusicModel];  // 显示歌曲的名字
    }
    else if ((self.playSongIndex>=0)&&(self.playSongIndex<(self.allSongModel.count-1))){
        self.playSongIndex+=1;
        self.currentMusicModel=self.musicModel=self.allSongModel[self.playSongIndex];
        self.isLockScreenMsg=YES;
        [self setShowSongName:self.currentMusicModel];  // 显示歌曲的名
    }
    // 重新播放
    [[MySingleton shareMySingleton] stopAction];
    [[MySingleton shareMySingleton] playAction:self.currentMusicModel.playUrl];
}
#pragma mark 点击音量按钮蒙版视图操作
- (void)volumeActionWithView{
    self.volumeSlider.hidden=!self.volumeSlider.hidden;
}
#pragma mark 改变的音量值
-(void)currentValueOfSlider:(CGFloat)sliderValue{
    NSLengLog(@"滑动改变的值:%f",sliderValue);
}
#pragma mark 设置显示歌曲的名字
-(void)setShowSongName:(DeviceMusicModel *)modelData{
    self.showSongNameLabel.text=modelData.musicName;
}
#pragma mark 暂停显示播放杆的位置
-(void)showGangWhenPausePlaySong:(BOOL)isPlaying{
    if (isPlaying) {
        [UIView animateWithDuration:CGFLOAT_MIN animations:^{
            self.gangImageView.transform=CGAffineTransformMakeTranslation(moveXValue,0);  // 平移X
        }];
        self.gangImageView.image=[UIImage imageNamed:@"gangWithPause"];
    }
    else{
        [UIView animateWithDuration:CGFLOAT_MIN animations:^{
            self.gangImageView.transform=CGAffineTransformIdentity;
        }];
        self.gangImageView.image=[UIImage imageNamed:@"gang"];
    }
}
#pragma mark 点击了上一首和下一首显示杠和旋转图片
-(void)clickLastOrNextButtonSongShowGang{
    [self showGangWhenPausePlaySong:NO];         //不显示暂停播放杠
    if (!isClickedLastOrNextButtonWithFirst) {
        isClickedLastOrNextButtonWithFirst=isClickedPlayButtonWithFirst=YES;
        if(!self.isPlaying){
            [self resetRotateImageView];  // 重新旋转图片
            return;
        }
    }
    if(!self.playButton.selected){
        [self playLink];   // 没有播放音乐就恢复旋转
    }
    self.playButton.selected=YES;
}

#pragma mark 旋转音乐图片
-(void)rotateImageViewAction{
    if(self.playButton.selected){
        self.rotateCenterImageView.transform = CGAffineTransformRotate(self.rotateCenterImageView.transform, M_PI_4/60);
    }
}
#pragma mark 重新旋转音乐图片
-(void)resetRotateImageView{
    NSLengLog(@"旋转音乐图片");
    
    [[MySingleton shareMySingleton] stopAction];
    [[MySingleton shareMySingleton] playAction:self.currentMusicModel.playUrl];
    
    self.playButton.selected=YES;
    self.rotateCenterImageView.transform=CGAffineTransformIdentity;
    [self playLink];
}
#pragma mark 继续播放当前的音乐
-(void)goonPlayCurrentMusic{
    [[MySingleton shareMySingleton] playAction:self.currentMusicModel.playUrl];
    self.playButton.selected=YES;
    self.rotateCenterImageView.transform=CGAffineTransformIdentity;
    [self playLink];
}
#pragma mark 是否插入了耳机(重写setting方法)
-(void)setIsInsertHeadset:(BOOL)isInsertHeadset{
    self.playButton.selected=isInsertHeadset;
    [self playLink];
    
}
#pragma mark App进入前台
-(void)backForegroundAction{
    if(self.playButton.selected){
        [self playLink];  //继续旋转图片
    }
    else{
        isClickedLastOrNextButtonWithFirst=isClickedPlayButtonWithFirst=NO;
    }
}
#pragma mark 锁屏的操作
-(void)lockScreenAction{
    // 锁屏时点击的按钮
    __weak typeof(self)  lowSelf=self;
    self.block = ^(UIEvent *event) {
        if (event.subtype==UIEventSubtypeRemoteControlPlay) {    //播放
            lowSelf.playButton.selected=YES;
            [[MySingleton shareMySingleton] playAction:lowSelf.currentMusicModel.playUrl];
            [lowSelf playLink];
        }
        if (event.subtype==UIEventSubtypeRemoteControlPause) {   //暂停
            lowSelf.playButton.selected=NO;
            [[MySingleton shareMySingleton] pauseAction];
            [lowSelf playLink];
        }
        if (event.subtype==UIEventSubtypeRemoteControlStop) {   // 停止
            lowSelf.playButton.selected=NO;
            [[MySingleton shareMySingleton] stopAction];
            [lowSelf playLink];
        }
        if (event.subtype==UIEventSubtypeRemoteControlNextTrack) {      // 下一首
            [lowSelf nextPlayAction:lowSelf.playButton];
        }
        if (event.subtype==UIEventSubtypeRemoteControlPreviousTrack) {  // 上一首
            [lowSelf lastPlayAction:lowSelf.playButton];
        }
    };
}
#pragma mark 清除定时器
-(void)cleanTimer{
    [self.playLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.playLink invalidate];
    self.playLink=nil;
}
#pragma mark 销毁控制器去除定时器
-(void)dealloc{
    [self cleanTimer];
}
@end
