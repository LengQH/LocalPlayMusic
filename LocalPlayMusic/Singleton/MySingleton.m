//
//  MySingleton.m
//  ParkedCars
//
//  Created by Leng on 16/4/20.
//  Copyright © 2016年 gdd. All rights reserved.
//

#import "MySingleton.h"

static MySingleton *mySing=nil;


@interface MySingleton ()

@end

@implementation MySingleton

#pragma mark -初始化一个单例
+(instancetype)shareMySingleton{
    if (mySing==nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{    // 用GCD只操作一次,确保线程的安全
            mySing=[[MySingleton alloc]init];
        });
    }
    return mySing;
}
// alloc 分配内存空间的时候
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (mySing==nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mySing=[super allocWithZone:zone];
        });
    }
    return mySing;
}
// 复制 拷贝的时候
+ (id)copyWithZone:(struct _NSZone *)zone{
    return mySing;
}
#pragma mark 初始化播放
-(void)startPlay:(NSURL *)url{
    NSError *error=nil;
    self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    self.player.numberOfLoops=0;  //   就播放一次,如果播放两次就设置为 1
    self.player.volume=1.0;       //   设置对应的音量
}
#pragma mark 播放操作
-(void)playAction:(NSURL *)url{
    if (!self.player.playing) {   //  没有播放
        if (!self.player) {       //  没有创建播放器对象
            [self startPlay:url];
        }
        BOOL playSuccess=[self.player play]; // 播放是否成功
        
        if(playSuccess){
            NSLengLog(@"播放成功");
        }
        else{
            NSLengLog(@"播放失败,请检测URL是否正确或者<AVAudioPlayer>对象是否设置为全局变量");
        }
    }
}
#pragma mark 上一首操作
-(void)lastAction:(NSURL *)url{
    [self.player stop];
    self.player=nil;
    [self startPlay:url];
    [self playAction:url];
}
#pragma mark 下一首操作
-(void)nextAction:(NSURL *)url{
    [self lastAction:url];
}
#pragma mark 暂停操作
-(void)pauseAction{
    if (self.player.playing) {  // 正在播放
        [self.player pause];
    }

}
#pragma mark 停止操作
-(void)stopAction{
    [self.player stop];
    self.player=nil;
}






#pragma mark 通过类名获取控制器
+(UIViewController *)loadViewController:(Class)className{
    return [[className alloc]initWithNibName:NSStringFromClass(className) bundle:nil];
}

#pragma mark 通过某一个字段保存一个值
+(void)saveLoacalWithField:(NSString *)fieldName value:(id)value{
    NSUserDefaults *defaus=[NSUserDefaults standardUserDefaults];
    [defaus setObject:value forKey:fieldName];
    [defaus synchronize];
}
#pragma mark 通过某一个字段得到之前保存的值
+(id)getsaveLoacalField:(NSString *)fieldName{
    NSUserDefaults *defaus=[NSUserDefaults standardUserDefaults];
    return [defaus objectForKey:fieldName];
}
+(UIWindow *)getSystemMainWindow{
    return [UIApplication sharedApplication].keyWindow;
}

@end
