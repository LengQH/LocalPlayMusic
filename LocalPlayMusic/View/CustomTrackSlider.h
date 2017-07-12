//
//  CustomTrackSlider.h
//  SOSlider
//
//  Created by 冷求慧 on 17/6/7.
//  Copyright © 2017年 wangli. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CustomTrackSlider;
@protocol CustomTrackSliderDelegate <NSObject>
@optional
/**
 *  滑动的值
 *
 */
-(void)currentValueOfSlider:(CGFloat)sliderValue;
/**
 *  开始滑动
 *
 */
-(void)beginSwipSlider;
/**
 *  结束滑动
 *
 */
-(void)endSwipSlider;
@end

@interface CustomTrackSlider : UISlider

@property (nonatomic, weak) id<CustomTrackSliderDelegate>delegate;
/**
 *  是否垂直方法(映射到SB上面)
 */
@property (nonatomic, assign)IBInspectable BOOL isVertical;

@end
