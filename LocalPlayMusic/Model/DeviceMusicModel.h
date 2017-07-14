//
//  DeviceMusicModel.h
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceMusicModel : NSObject
/**
 *  歌曲名
 */
@property (nonatomic,copy)NSString *musicName; 
/**
 *  歌手名
 */
@property (nonatomic,copy)NSString *singerName;
/**
 *  显示的图片名
 */
@property (nonatomic,strong)UIImage *showImage;
/**
 *  是否选中cell
 */
@property (nonatomic,assign)BOOL isSelected;
/**
 *  播放的地址
 */
@property (nonatomic,assign)NSURL *playUrl;

-(instancetype)initWithDeviceMusicModel:(NSString *)musicName singerName:(NSString *)singerName showImage:(UIImage *)showImage isSelected:(BOOL)isSelected;

+(instancetype)deviceMusicModel:(NSString *)musicName singerName:(NSString *)singerName showImage:(UIImage *)showImage isSelected:(BOOL)isSelected;

@end
