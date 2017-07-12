//
//  DeviceMusicViewController.m
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "DeviceMusicViewController.h"

#import "DeviceMusicModel.h"            //   音乐模型类
#import "DeviceMusicTableViewCell.h"    //   TabelViewCell类
#import "MusicPlayViewController.h"     //   音乐播放控制器

#import "CustomProxy.h"

#define cellHeight     46*heightRatioWithAll

#define animationTime  5.0                    //  动画需要的时间

#define definePlaySongIndex 0                 //  默认播放歌曲下标

@interface DeviceMusicViewController ()<UITableViewDelegate,UITableViewDataSource,MusicPlayViewControllerDelegate,AVAudioPlayerDelegate>{
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
 *  当前选中的模型
 */
@property (nonatomic,strong)DeviceMusicModel *currentSelectModel;
/**
 *  上一次选中的下标
 */
@property (nonatomic,strong)NSIndexPath *lastSelectIndexPath;

/**
 *  本地音乐的地址数组
 */
@property (nonatomic,strong)NSMutableArray<NSURL *>  *arrAddSongUrl;



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
- (void)viewDidLoad {
    [super viewDidLoad];
    [self someUISet];
}
-(void)someUISet{
    
    [self someLayoutSet];   // 布局设置
    
    [self addModelData];   //  加载数据

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
    self.currentSelectModel=firstModel;
    
    self.title=@"我的乐库";
    self.mainTableView.delegate=self;
    self.mainTableView.dataSource=self;
    [self.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DeviceMusicTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellID];
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
    
    DeviceMusicModel *model0=[DeviceMusicModel deviceMusicModel:@"Good Time" singerName:@"Owl City" showImageName:@"Owl City" isSelected:YES];
    DeviceMusicModel *model1=[DeviceMusicModel deviceMusicModel:@"诗画小镇" singerName:@"CRITTY" showImageName:@"CRITTY" isSelected:NO];
    DeviceMusicModel *model2=[DeviceMusicModel deviceMusicModel:@"离心咒" singerName:@"可歆" showImageName:@"timg" isSelected:NO];
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
    self.currentSelectModel=musicModel;
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
#pragma mark App进入前台
-(void)backForegroundAction{
    if(self.playButton.selected){
        [self playLink];   // 恢复播放
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
