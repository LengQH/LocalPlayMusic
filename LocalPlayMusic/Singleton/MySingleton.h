//
//  MySingleton.h
//  ParkedCars
//
//  Created by Leng on 16/4/20.
//  Copyright © 2016年 gdd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MySingleton : NSObject

/**
 *  初始化单例
 *
 *  @return 单例本类对象
 */
+(instancetype)shareMySingleton;

/**
 *  播放器对象
 */
@property (nonatomic,strong)AVAudioPlayer   *player;
/**
 *  播放操作
 */
-(void)playAction:(NSURL *)url;
/**
 *  上一首操作
 */
-(void)lastAction:(NSURL *)url;
/**
 *  下一首操作
 */
-(void)nextAction:(NSURL *)url;
/**
 *  暂停操作
 */
-(void)pauseAction;
/**
 *  停止操作
 */
-(void)stopAction;





/**
 *  加载控制器
 *
 *  @param className 类名
 *
 *  @return 控制器
 */
+(UIViewController *)loadViewController:(Class)className;
/**
 *  通过字段保存数据到本地
 *
 *  @param fieldName 字段名
 *  @param value     值
 */
+(void)saveLoacalWithField:(NSString *)fieldName value:(id)value;
/**
 *  通过字段得到保存在本地的数据
 *
 *  @param fieldName 字段名
 *
 *  @return 保存的数据
 */
+(id)getsaveLoacalField:(NSString *)fieldName;
/**
 *  得到系统的主Windows
 *
 *  @return 主窗口视图
 */
+(UIWindow *)getSystemMainWindow;

@end
