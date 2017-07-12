//
//  UIBarButtonItem+CustomBarButtonItem.h
//  yoli
//
//  Created by 冷求慧 on 16/11/8.
//  Copyright © 2016年 Leng. All rights reserved.
//


#import <UIKit/UIKit.h>
@interface UIBarButtonItem (CustomBarButtonItem)
/**
 *
 *
 *  @param normalImage 正常状态下的图片名字
 *  @param Highlighted 高亮状态下的图片名字
 *  @param target      事件触发的目标
 *  @param action      事件
 *
 *  @return UIBarButtonItem
 */
+(UIBarButtonItem *)customBarButtonItem:(NSString *)normalImage HighlightedImage:(NSString *)Highlighted  target:(id)target  action:(SEL)action;
@end
