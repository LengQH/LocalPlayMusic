//
//  AllSuperNavigationController.m
//  LocalPlayMusic
//
//  Created by 冷求慧 on 17/6/16.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "AllSuperNavigationController.h"

#import "UIBarButtonItem+CustomBarButtonItem.h"

@interface AllSuperNavigationController ()

@end

@implementation AllSuperNavigationController

+(void)initialize{
    CGFloat navigationTitleFloat=16.0;
    if(!(Iphone5)){
        navigationTitleFloat=navigationTitleFloat*heightRatioWithAll;
    }
    UINavigationBar *myNavigationBar=[UINavigationBar appearance];
    [myNavigationBar setTintColor:[UIColor whiteColor]];
    [myNavigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:navigationTitleFloat],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [myNavigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBG"] forBarMetrics:UIBarMetricsDefault]; //设置透明背景图片,但是高度一定要是64
    myNavigationBar.translucent=YES;
    myNavigationBar.clipsToBounds=YES;
    
    UIBarButtonItem *barButtonItem=[UIBarButtonItem appearance]; // 设置UIBarButtonItem的主题
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:cusFont(navigationTitleFloat-2),NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:cusFont(navigationTitleFloat-2),NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateHighlighted];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:cusFont(navigationTitleFloat-2),NSForegroundColorAttributeName:[UIColor darkGrayColor]} forState:UIControlStateDisabled];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark 重写系统的PushViewController:animated: 方法
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count>0) {
        viewController.hidesBottomBarWhenPushed=YES;
        viewController.navigationItem.leftBarButtonItem=[UIBarButtonItem customBarButtonItem:@"backWithForgetPwd" HighlightedImage:@"backWithForgetPwd" target:self action:@selector(backAction)];
    }
    [super pushViewController:viewController animated:YES];
}
-(void)backAction{
    [self popViewControllerAnimated:YES];
}



@end
