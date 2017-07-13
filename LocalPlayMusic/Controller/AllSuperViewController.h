//
//  AllSuperViewController.h
//  LocalPlayMusic
//
//  Created by 冷求慧 on 17/6/16.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^LockScreenBlock)(UIEvent *event);   // 用来锁屏点击音乐按钮的回调

#import "DeviceMusicModel.h"            //   音乐模型类

@interface AllSuperViewController : UIViewController

/**
 *  是否添加背景图片
 */
@property(nonatomic,assign)BOOL     isAddBGImageInVC;
/**
 *  是否插入了耳机
 */
@property(nonatomic,assign)BOOL      isInsertHeadset;
/**
 *  是否设置锁屏信息
 */
@property(nonatomic,assign)BOOL      isLockScreenMsg;
/**
 *  音乐模型
 */
@property(nonatomic,strong)DeviceMusicModel  *musicModel;
/**
 *  锁屏的回调
 */
@property (nonatomic,copy)LockScreenBlock    block;


/**
 *  拔出和插入耳机的通知回调
 *
 *  @param notifa 通知
 */

-(void)pullOutHeadset:(NSNotification *)notifa;

@end
