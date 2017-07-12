//
//  DeviceMusicTableViewCell.h
//  yoli
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 Leng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DeviceMusicModel.h"

@interface DeviceMusicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *rightMusicButton;

@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
/**
 *  模型数据
 */
@property (nonatomic,assign)DeviceMusicModel *modelData;

@end
