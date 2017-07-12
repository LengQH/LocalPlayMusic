//
//  DeviceMusicTableViewCell.m
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import "DeviceMusicTableViewCell.h"


@implementation DeviceMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setModelData:(DeviceMusicModel *)modelData{
    self.rightMusicButton.selected=modelData.isSelected;
    self.musicNameLabel.text=modelData.musicName;
    if (modelData.isSelected) {
        self.musicNameLabel.textColor=cusColor(74, 139, 255, 1.0);
    }
    else{
        self.musicNameLabel.textColor=[UIColor whiteColor];
    }
}
@end
