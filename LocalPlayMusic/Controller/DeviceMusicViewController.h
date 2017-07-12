//
//  DeviceMusicViewController.h
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "AllSuperViewController.h"

@interface DeviceMusicViewController : AllSuperViewController
/**
 *  底部视图的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bomAllViewH;
/**
 *  音乐父视图的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicSuperViewW;
/**
 *  音乐父视图的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicSuperViewH;

/**
 *  播放按钮的上边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonTopDistance;
/**
 *  播放按钮的底边距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonBomDistance;


@end
