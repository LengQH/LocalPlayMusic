//
//  AllSuperViewController.m
//  LocalPlayMusic
//
//  Created by 冷求慧 on 17/6/16.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "AllSuperViewController.h"

@interface AllSuperViewController ()

@end

@implementation AllSuperViewController

#pragma mark -重写Setting方法
-(void)setIsAddBGImageInVC:(BOOL)isAddBGImageInVC{
    _isAddBGImageInVC=isAddBGImageInVC;
    
    UIImageView *bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,0, screenWidthW, screenHeightH)];
    bgImageView.image=[UIImage imageNamed:@"backgroundImage"];
    bgImageView.contentMode=UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];   // 将背景视图放在最后面
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
