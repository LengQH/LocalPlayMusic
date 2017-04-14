//
//  ViewController.h
//  TestAApp
//
//  Created by 冷求慧 on 17/3/24.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
/**
 *  主图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
/**
 *  播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/**
 *  暂停按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
/**
 *  下一首按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
/**
 *  上一首按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
/**
 *  停止按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
/**
 *  进度条
 */
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;




/**
 *  主图片的宽度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainImageViewW;
/**
 *  按钮的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonH;
/**
 *  进度条的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressH;


@end

