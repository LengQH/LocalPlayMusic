//
//  DeviceMusicViewController.m
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "DeviceMusicViewController.h"

#import "DeviceMusicTableViewCell.h"    //   TabelViewCell类
#import "MusicPlayViewController.h"     //   音乐播放控制器

#import "CustomProxy.h"

#define cellHeight     46*heightRatioWithAll

#define animationTime  5.0                    //  动画需要的时间

#define definePlaySongIndex 0                 //  默认播放歌曲下标

@interface DeviceMusicViewController ()<UITableViewDelegate,UITableViewDataSource,MusicPlayViewControllerDelegate,MPMediaPickerControllerDelegate>{
    BOOL joinClickPlayButton;    // 进来直接点击了播放按钮
    BOOL isPlayed;   // 是否播放过
}
/**
 *  定时器
 */
@property (strong,nonatomic) CADisplayLink *playLink;
/**
 *  主表
 */
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
/**
 *  音乐父视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *centerMusicImageView;
/**
 *  底部父视图
 */
@property (weak, nonatomic) IBOutlet UIView *bomSuperView;


/**
 *  歌曲名字
 */
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
/**
 *  播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/**
 *  点击视图
 */
@property (weak, nonatomic) IBOutlet UIView *clickView;
/**
 *  模型数据
 */
@property (nonatomic,strong)NSMutableArray<DeviceMusicModel *>  *arrModelData;
/**
 *  音乐播放地址的URL
 */
@property (nonatomic,strong)NSMutableArray<NSURL *>  *arrAddSongUrl;
/**
 *  当前选中的模型
 */
@property (nonatomic,strong)DeviceMusicModel *currentSelectModel;
/**
 *  上一次选中的下标
 */
@property (nonatomic,strong)NSIndexPath *lastSelectIndexPath;
/**
 *  视频播放选择控制器
 */
@property (nonatomic,strong)MPMediaPickerController *mediaPicker;



@end
static  NSString *cellID=@"deviceMusicCell";

@implementation DeviceMusicViewController

-(CADisplayLink *)playLink{
    if (_playLink==nil) {
        //这里的target没有指向自己是因为如果直接指向自己，addToRunLoop之后会造成CADisplayLink的内存泄漏
        _playLink=[CADisplayLink displayLinkWithTarget:[CustomProxy proxyWithTarget:self] selector:@selector(rotateImageViewAction)];
        [_playLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _playLink;
}
-(NSMutableArray<DeviceMusicModel *> *)arrModelData{
    if (_arrModelData==nil) {
        _arrModelData=[NSMutableArray array];
    }
    return _arrModelData;
}
// 懒加载
-(NSMutableArray *)arrAddSongUrl{
    if (_arrAddSongUrl==nil) {
        _arrAddSongUrl=[NSMutableArray array];
        for (int i=0; i<self.arrModelData.count; i++) {  // 本地只有三首歌
            NSURL *loadUrl=[[NSBundle mainBundle]URLForResource:[NSString stringWithFormat:@"music%zi",i] withExtension:@"mp3"];
            [_arrAddSongUrl addObject:loadUrl];
        }
    }
    return _arrAddSongUrl;
}
-(MPMediaPickerController *)mediaPicker{
    if(_mediaPicker==nil){
        _mediaPicker=[[MPMediaPickerController alloc]initWithMediaTypes:MPMediaTypeMusic];
        _mediaPicker.allowsPickingMultipleItems=YES;
        _mediaPicker.prompt=@"请选择你要播放的音乐";
        _mediaPicker.delegate=self;
    }
    return _mediaPicker;
}
#pragma mark -MediaPicker的代理
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    if(mediaItemCollection.items>0){
        for (MPMediaItem *medicItem in mediaItemCollection.items) {
            
            NSURL *playUrl=(NSURL *)[medicItem valueForKey:MPMediaItemPropertyAssetURL];
            
            if([self.arrAddSongUrl indexOfObject:playUrl]==NSNotFound){
                
                self.bomSuperView.hidden=NO;
                
                DeviceMusicModel *addMusicModel=[[DeviceMusicModel alloc]init];
                addMusicModel.musicName=(NSString *)[medicItem valueForKey:MPMediaItemPropertyTitle];
                addMusicModel.singerName=(NSString *)[medicItem valueForKey:MPMediaItemPropertyArtist];
                MPMediaItemArtwork *itemArtwork=[medicItem valueForKey:MPMediaItemPropertyArtwork];
                addMusicModel.showImage=[itemArtwork imageWithSize:CGSizeMake(100, 100)];
                addMusicModel.isSelected=(self.arrModelData.count==0)?YES:NO;
                addMusicModel.playUrl=playUrl;
                
                if (self.arrModelData.count==0) {               // 当模型数据数组没有数据时,添加第一条设置默认的选中歌曲
                    self.currentSelectModel=addMusicModel;
                    self.lastSelectIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                    self.songNameLabel.text=addMusicModel.musicName;
                }
                [self.arrAddSongUrl addObject:playUrl];
                [self.arrModelData addObject:addMusicModel];
                
            }
        }
    }
    [self.mainTableView reloadData];   // 刷新表
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    NSLengLog(@"取消选择");
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 视图加载完毕
- (void)viewDidLoad {
    [super viewDidLoad];
    [self someUISet];
}
#pragma mark 一些UI设置
-(void)someUISet{
    
//    self.mainTableView.editing=YES;
    
    [self someLayoutSet];   // 布局设置
    
    [self addModelData];   //  加载数据
    
    [self lockScreenAction]; //  锁屏的操作

    self.isAddBGImageInVC=YES;
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"导入本地音乐" style:UIBarButtonItemStylePlain target:self action:@selector(importMusic:)];
    
    self.clickView.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickSongNameAction)];
    [self.clickView addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backForegroundAction) name:UIApplicationWillEnterForegroundNotification object:nil];  // 添加回到前台的通知
    
    // 设置默认播放的歌曲(第一首)
    self.lastSelectIndexPath=[NSIndexPath indexPathForRow:definePlaySongIndex inSection:0];
    DeviceMusicModel *firstModel=self.arrModelData[self.lastSelectIndexPath.row];  // 这次选中的下标
    self.songNameLabel.text=firstModel.musicName;
    self.currentSelectModel=self.musicModel=firstModel;
    self.isLockScreenMsg=YES; // 设置锁屏信息

    self.title=@"我的乐库";
    self.mainTableView.delegate=self;
    self.mainTableView.dataSource=self;
    [self.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DeviceMusicTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellID];
}
#pragma mark 播放不同的歌曲
-(void)playDifferentSong:(NSIndexPath *)indexPath{
    [self selectedCellStyle:indexPath];   // 选中对应的cell和重新播放音乐
    [self resetRotateImageView];
    self.lastSelectIndexPath=indexPath;
}
#pragma mark 布局设置
-(void)someLayoutSet{
    self.bomAllViewH.constant=self.bomAllViewH.constant*heightRatioWithAll;
    
    self.musicSuperViewW.constant=self.musicSuperViewW.constant*heightRatioWithAll;
    self.musicSuperViewH.constant=self.musicSuperViewH.constant*heightRatioWithAll;
    
    self.playButtonTopDistance.constant=self.playButtonTopDistance.constant*heightRatioWithAll;
    self.playButtonBomDistance.constant=self.playButtonBomDistance.constant*heightRatioWithAll;
    
}
#pragma mark 添加模型数据
-(void)addModelData{

    DeviceMusicModel *model0=[DeviceMusicModel deviceMusicModel:@"Good Time" singerName:@"Owl City" showImage:[UIImage imageNamed:@"Owl_City"] isSelected:YES];
    DeviceMusicModel *model1=[DeviceMusicModel deviceMusicModel:@"诗画小镇" singerName:@"CRITTY" showImage:[UIImage imageNamed:@"CRITTY"] isSelected:NO];
    DeviceMusicModel *model2=[DeviceMusicModel deviceMusicModel:@"离心咒" singerName:@"可歆" showImage:[UIImage imageNamed:@"timg"] isSelected:NO];
    [self.arrModelData addObjectsFromArray:@[model0,model1,model2]];
    
    for (NSInteger i=0; i<self.arrModelData.count; i++) {   // 赋值URL
        DeviceMusicModel *model=self.arrModelData[i];
        NSURL *url=self.arrAddSongUrl[i];
        model.playUrl=url;
    }
}
#pragma mark -数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrModelData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceMusicTableViewCell *cell=(DeviceMusicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    cell.modelData=self.arrModelData[indexPath.row];
    return cell;
}
#pragma mark -代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==self.lastSelectIndexPath.row){          // 选中的是同一行,暂停或者播放操作
        [self playAction:nil];
        return;
    }
    [self selectedCellStyle:indexPath];                      //  选中Cell改变样式
    [self resetRotateImageView];                             //   重新旋转图片
    self.lastSelectIndexPath=indexPath;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark -数据源方法删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 停止音乐播放
    [[MySingleton shareMySingleton] stopAction];
    self.playButton.selected=NO;
    
    // 删除对应的数据和cell
    [self.arrAddSongUrl removeObjectAtIndex:indexPath.row];
    [self.arrModelData removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // 重新设置对应的选中的Cell
    if (self.arrModelData.count>0) {
        NSIndexPath *selectPath=indexPath;
        if (indexPath.row!=0) {
            selectPath=[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
        }
        [self selectedCellStyle:selectPath];
    }
    // 删除完毕设置对应视图的隐藏
    if (self.arrModelData.count==0) {
        self.bomSuperView.hidden=YES;
        self.currentSelectModel=nil;
        self.songNameLabel.text=nil;
    }
}
#pragma mark 选中Cell改变对应的Cell
-(void)selectedCellStyle:(NSIndexPath *)indexPath{
    
    NSMutableArray *arrModelWithReload=[NSMutableArray array];
    [arrModelWithReload addObject:indexPath];
    if (self.lastSelectIndexPath) {  // 上次选中的下标
        DeviceMusicModel *selectModel=self.arrModelData[self.lastSelectIndexPath.row];
        selectModel.isSelected=NO;
        [arrModelWithReload addObject:self.lastSelectIndexPath];
    }
    DeviceMusicModel *musicModel=self.arrModelData[indexPath.row];  // 这次选中的下标
    musicModel.isSelected=YES;
    self.songNameLabel.text=musicModel.musicName;
    self.currentSelectModel=self.musicModel=musicModel;
    self.isLockScreenMsg=YES;  // 设置锁屏信息
    
    [self.mainTableView reloadRowsAtIndexPaths:(NSArray *)arrModelWithReload withRowAnimation:UITableViewRowAnimationNone]; // 刷新对应的行
}
#pragma mark 旋转音乐图片
-(void)rotateImageViewAction{
    if(self.playButton.selected){
        self.centerMusicImageView.transform = CGAffineTransformRotate(self.centerMusicImageView.transform, M_PI_4/60);
    }
}
#pragma mark 重新旋转音乐图片
-(void)resetRotateImageView{
    NSLengLog(@"重新旋转音乐图片");
    isPlayed=YES;
    // 先停止音乐,再播放(重新播放)
    [[MySingleton shareMySingleton] stopAction];
    [[MySingleton shareMySingleton] playAction:self.currentSelectModel.playUrl];
    
    // 旋转对应的图片
    self.playButton.selected=YES;
    self.centerMusicImageView.transform=CGAffineTransformIdentity;
    [self playLink];

}
#pragma mark 播放操作
- (IBAction)playAction:(UIButton *)sender {
    isPlayed=YES;
    if (self.playButton.selected) {    // 暂停播放
        NSLengLog(@"暂停播放音乐");
        
        [[MySingleton shareMySingleton] pauseAction];  // 暂停音乐
        self.playButton.selected=NO;
        [self playLink];
    }
    else{
        self.playButton.selected=YES;
        if((self.lastSelectIndexPath.row==definePlaySongIndex)&&(!joinClickPlayButton)){  // 只会进来一次
            NSLengLog(@"直接点击的播放,第一次进来");
            joinClickPlayButton=YES;
            [self selectedCellStyle:self.lastSelectIndexPath];  // 默认播放第一个
            [self resetRotateImageView];
        }
        else{
            NSLengLog(@"恢复播放音乐");
            [[MySingleton shareMySingleton] playAction:self.currentSelectModel.playUrl];  // 恢复播放
            [self playLink];  // 恢复播放
        }
    }
}
#pragma mark 点击歌曲名跳转页面
-(void)clickSongNameAction{
    MusicPlayViewController *playVC=[[MusicPlayViewController alloc]initWithNibName:NSStringFromClass([MusicPlayViewController class]) bundle:nil];;
    playVC.isPlaying=self.playButton.selected;
    playVC.currentMusicModel=self.currentSelectModel;
    playVC.allSongModel=self.arrModelData;
    playVC.delegate=self;
    playVC.lastPageVCIsPlayed=isPlayed;
    [self.navigationController pushViewController:playVC animated:YES];
}
#pragma mark  导入本地音乐操作
-(void)importMusic:(UIBarButtonItem *)item{
    NSLengLog(@"导入本地音乐操作");
    [self presentViewController:self.mediaPicker animated:YES completion:nil];
}
#pragma mark 播放音乐详情的代理
-(void)musicPlayView:(MusicPlayViewController *)musicPlayVC isPlaying:(BOOL)isPlaying playSongIndex:(NSInteger)index playMode:(PlayMusicMode)mode{
    
//    NSLengLog(@"是否正在播放:%zi 播放的下标:%zi 播放的模式:%zi",isPlaying,index,mode);
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
    
    [self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];

    if (index!=self.lastSelectIndexPath.row) {    // 不同的下标
        [self selectedCellStyle:indexPath];
        self.lastSelectIndexPath=indexPath;
        self.songNameLabel.text=self.currentSelectModel.musicName;
    }
    if (isPlaying) {
        if (index!=self.lastSelectIndexPath.row) {
            [self resetRotateImageView];         //重新旋转图片
        }
        else{
            [self playLink];   // 继续旋转和播放
            [[MySingleton shareMySingleton] playAction:self.currentSelectModel.playUrl];
        }
    }
    else{
        [[MySingleton shareMySingleton] pauseAction];  // 暂停音乐
    }
    self.playButton.selected=isPlaying;
    
}
#pragma mark 是否插入了耳机(重写setting方法)
-(void)setIsInsertHeadset:(BOOL)isInsertHeadset{
    self.playButton.selected=isInsertHeadset;
    [self playLink];
}
#pragma mark App进入前台
-(void)backForegroundAction{
    if(self.playButton.selected){
        [self playLink];   // 恢复播放
    }
}
#pragma mark 锁屏的操作
-(void)lockScreenAction{
    
    __weak typeof(self)  lowSelf=self;
    
    //  音乐播放完成的回调
    [MySingleton shareMySingleton].playFinish=^(){
        NSLengLog(@"音乐列表页面,播放下一首");
        NSInteger currentIndex=lowSelf.lastSelectIndexPath.row;
        [lowSelf playNextSong:currentIndex];
    };

    // 锁屏时点击的按钮
    self.block = ^(UIEvent *event) {
        NSInteger currentIndex=lowSelf.lastSelectIndexPath.row;
        if (event.subtype==UIEventSubtypeRemoteControlPlay) {    //播放
            lowSelf.playButton.selected=YES;
            [[MySingleton shareMySingleton] playAction:lowSelf.currentSelectModel.playUrl];
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
            [lowSelf playNextSong:currentIndex];
        }
        if (event.subtype==UIEventSubtypeRemoteControlPreviousTrack) {  // 上一首
            [lowSelf playLastSong:currentIndex];
        }
    };
}
#pragma mark 播放下一首歌
-(void)playNextSong:(NSInteger)currentIndex{
    if (currentIndex==(self.arrModelData.count-1)) {
        NSIndexPath *pathValue=[NSIndexPath indexPathForRow:0 inSection:0];
        [self playDifferentSong:pathValue];     // 播放对应的歌曲
    }
    else if((currentIndex>=0)&&(currentIndex<(self.arrModelData.count-1))){
        NSIndexPath *pathValue=[NSIndexPath indexPathForRow:currentIndex+1 inSection:0];
        [self playDifferentSong:pathValue];
    }
}
#pragma mark 播放上一首歌
-(void)playLastSong:(NSInteger)currentIndex{
    if(currentIndex==0){
        NSIndexPath *pathValue=[NSIndexPath indexPathForRow:self.arrModelData.count-1 inSection:0];
        [self playDifferentSong:pathValue];
    }
    else if((currentIndex>0)&&(currentIndex<self.arrModelData.count)){
        NSIndexPath *pathValue=[NSIndexPath indexPathForRow:currentIndex-1 inSection:0];
        [self playDifferentSong:pathValue];
    }
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
