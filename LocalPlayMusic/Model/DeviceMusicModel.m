//
//  DeviceMusicModel.m
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "DeviceMusicModel.h"

@implementation DeviceMusicModel

-(instancetype)initWithDeviceMusicModel:(NSString *)musicName singerName:(NSString *)singerName showImage:(UIImage *)showImage isSelected:(BOOL)isSelected{
    if (self=[super init]) {
        self.musicName=musicName;
        self.singerName=singerName;
        self.showImage=showImage;
        self.isSelected=isSelected;
    }
    return self;
}

+(instancetype)deviceMusicModel:(NSString *)musicName singerName:(NSString *)singerName showImage:(UIImage *)showImage isSelected:(BOOL)isSelected{
    return [[self alloc]initWithDeviceMusicModel:musicName singerName:singerName showImage:showImage isSelected:isSelected];
}
@end
