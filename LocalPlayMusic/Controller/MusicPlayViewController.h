//
//  MusicPlayViewController.h
//  yoli
//
//  Created by 冷求慧 on 17/6/6.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "AllSuperViewController.h"
#import "DeviceMusicModel.h"

typedef void (^TouchBlock)(UIEvent *event);   //  用来锁屏点击音乐按钮的回调

typedef NS_ENUM(NSInteger, PlayMusicMode) {
    
    PlayMusicModeWithSequence =0,         //   顺序播放
    PlayMusicModeWithLoopList =1,        //    列表循环播放
    PlayMusicModeWithOnlyOne  =2,       //     单曲播放
    PlayMusicModeWithRandom   =3,      //      随机播放
};

@class MusicPlayViewController;
@protocol MusicPlayViewControllerDelegate <NSObject>
@optional
/**
 *
 *  @param musicPlayVC 本类控制器
 *  @param isPlaying   是否在播放中
 *  @param index       播放的下标
 *  @param mode        播放的模式
 */

-(void)musicPlayView:(MusicPlayViewController *)musicPlayVC isPlaying:(BOOL)isPlaying playSongIndex:(NSInteger)index playMode:(PlayMusicMode)mode;

@end

@interface MusicPlayViewController : AllSuperViewController
/**
 *  是否正在播放音乐
 */
@property (nonatomic,assign)BOOL  isPlaying;
/**
 *  上一个页面是否有播放过
 */
@property (nonatomic,assign)BOOL  lastPageVCIsPlayed;
/**
 *  当前音乐模型
 */
@property (nonatomic,strong)DeviceMusicModel *currentMusicModel;
/**
 *  所有歌曲模型数据
 */
@property (nonatomic,strong)NSMutableArray<DeviceMusicModel *> *allSongModel;
/**
 *  代理属性
 */
@property (nonatomic,weak)id<MusicPlayViewControllerDelegate> delegate;



/**
 *  底部按钮父视图的底边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bomButtonSuperViewBomDistance;
/**
 *  底部按钮父视图的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bomButtonSuperViewH;
/**
 *  歌曲名字Label的的底边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *songNameLabelBomDistance;
/**
 *  歌曲名字的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *songNameLabelH;
/**
 *  背景音乐图片的底边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgMusicPlayBomDistance;
/**
 *  背景音乐图片的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgMusicPlayW;
/**
 *  背景音乐图片的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgMusicPlayH;
/**
 *  大圆父视图的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigCircleSuperW;
/**
 *  大圆父视图的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigCircleSuperH;
/**
 *  旋转大圆的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rotateBigCircleW;
/**
 *  旋转小圆的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rotateBigCircleH;
/**
 *  旋转小圆的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rotateSmallCircleW;
/**
 *  旋转小圆的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rotateSmallCircleH;
/**
 *  播放音乐Logo的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playMusicH;
/**
 *  播放音乐Logo的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playMusicW;
/**
 *  播放杠的底边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gangBomDistance;
/**
 *  播放杠的右边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gangRightDistance;
/**
 *  播放杠的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gangW;
/**
 *  播放杠的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gangH;

/**
 *  音量滑动的底边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderBomDistance;


@end
