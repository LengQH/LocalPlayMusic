//
//  AppDelegate.m
//  TestAApp
//
//  Created by 冷求慧 on 17/3/24.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "AppDelegate.h"

#import "StartAnimationViewController.h"

#import "AllSuperNavigationController.h"
#import "DeviceMusicViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    StartAnimationViewController  *animationVC=[[StartAnimationViewController alloc]init];   //  动画视图控制器
    self.window.rootViewController=animationVC;
    
    animationVC.finishAnimationBlock=^{   // 动画执行完毕,进入导航控制器
        
         AllSuperNavigationController *mainNavigation=[[AllSuperNavigationController alloc]initWithRootViewController:[MySingleton loadViewController:[DeviceMusicViewController class]]];
        [MySingleton getSystemMainWindow].rootViewController=mainNavigation;        
    };
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}


@end
