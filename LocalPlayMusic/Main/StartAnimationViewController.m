//
//  StartAnimationViewController.m
//  LocalPlayMusic
//
//  Created by 冷求慧 on 17/6/21.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "StartAnimationViewController.h"
#define animationNeedTime    2.0     // 动画需要的时间
@interface StartAnimationViewController ()<CAAnimationDelegate>
/**
 *  图片视图
 */
@property(strong,nonatomic)UIImageView *welcomeImgView;

@end

@implementation StartAnimationViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addImageView];
}
#pragma mark 开始动画
-(void)addImageView{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // 添加图片
    self.welcomeImgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidthW, screenHeightH)];
    self.welcomeImgView.image=[UIImage imageNamed:[self getLaunchImageName]];
    self.welcomeImgView.contentMode=UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.welcomeImgView];
    
    // 延时操作(极小的时间后执行,不然动画不会执行)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CGFLOAT_MIN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animationAction];
    });
}
#pragma mark 转场动画
-(void)animationAction{
    CATransition *transi=[[CATransition alloc]init];  // 转场动画(核心动画的子类)
    transi.fillMode=kCAFillModeForwards;
    transi.type=@"rippleEffect";
    transi.duration=animationNeedTime;
    transi.delegate=self;
    transi.subtype=kCATransitionFromRight;
    transi.removedOnCompletion=YES;
    
    [self.welcomeImgView.layer addAnimation:transi forKey:nil];
}
#pragma mark 转场动画执行完毕的回调
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.finishAnimationBlock) {
        self.finishAnimationBlock();
    }
}
#pragma mark 得到系统的Launch图片
-(NSString *)getLaunchImageName {
    CGSize viewSize=[UIScreen mainScreen].bounds.size;
    // 竖屏
    NSString *viewOrientation=@"Portrait";
    NSString *launchImageName=nil;
    NSArray* imagesDict=[[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize=CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName=dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}
#pragma mark 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
