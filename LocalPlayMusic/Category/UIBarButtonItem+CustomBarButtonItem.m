//
//  UIBarButtonItem+CustomBarButtonItem.m
//  yoli
//
//  Created by 冷求慧 on 16/11/8.
//  Copyright © 2016年 Leng. All rights reserved.
//

#import "UIBarButtonItem+CustomBarButtonItem.h"

@implementation UIBarButtonItem (CustomBarButtonItem)
+(UIBarButtonItem *)customBarButtonItem:(NSString *)normalImage HighlightedImage:(NSString *)Highlighted  target:(id)customTarget  action:(SEL)customAction{

    
    UIButton *button=[[UIButton alloc]init];
    [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];//正常状态下的按钮图片
    [button setBackgroundImage:[UIImage imageNamed:Highlighted] forState:UIControlStateHighlighted];//高亮状态下的按钮图片
    button.size=button.currentBackgroundImage.size;
    [button addTarget:customTarget action:customAction forControlEvents:UIControlEventTouchUpInside];//按钮的目标和方法
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];//将按钮添加到UIBarButtonItem上面
    return barButtonItem;
}
@end
