//
//  CustomSlider.m
//  SOSlider
//
//  Created by 冷求慧 on 17/6/7.
//  Copyright © 2017年 wangli. All rights reserved.
//

#import "CustomTrackSlider.h"

#define thumbBound_x 10    // 增大的滑动区域访问
#define thumbBound_y 10

@interface CustomTrackSlider (){
     CGRect lastBounds;
}

@end
@implementation CustomTrackSlider

#pragma mark 设置Slider的宽高
- (CGRect)trackRectForBounds:(CGRect)bounds{
    return bounds;
}

#pragma mark 是否垂直
- (void)setIsVertical:(BOOL)isVertical{
    _isVertical=isVertical;
    if (isVertical==YES) {
        self.transform=CGAffineTransformMakeRotation(-M_PI_2);  // 旋转负90度
    }
}
#pragma mark 加大点击的范围
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    rect.origin.x=rect.origin.x;
    rect.size.width=rect.size.width ;
    CGRect result=[super thumbRectForBounds:bounds trackRect:rect value:value];
    lastBounds=result;
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    UIView *result=[super hitTest:point withEvent:event];
    if(point.x<(-16)) return result;
    
    if ((point.y>=-thumbBound_y)&&(point.y<lastBounds.size.height+thumbBound_y)) {
        float value=0.0;
        value=point.x-self.bounds.origin.x;
        value=value/self.bounds.size.width;
        
        value=value<0?0:value;
        value=value>1?1:value;
        
        value=value*(self.maximumValue-self.minimumValue)+self.minimumValue;
        [self setValue:value animated:YES];
    }
    return result;
    
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL result=[super pointInside:point withEvent:event];
    if (!result && point.y>-10) {
        if ((point.x>=lastBounds.origin.x-thumbBound_x)&&(point.x<=(lastBounds.origin.x + lastBounds.size.width + thumbBound_x))&&(point.y<(lastBounds.size.height + thumbBound_y))) {
            result=YES;
        }
    }
    return result;
}





#pragma mark -重写UIControl对应的方法
// 开始触摸Slider
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    BOOL begin=[super beginTrackingWithTouch:touch withEvent:event];
    if (begin) {
        if ([self.delegate respondsToSelector:@selector(currentValueOfSlider:)]) {
            [self.delegate currentValueOfSlider:self.value];
        }
        if ([self.delegate respondsToSelector:@selector(beginSwipSlider)]) {
            [self.delegate beginSwipSlider];
        }
    }
    return begin;
}
// 继续触摸Slider
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    BOOL continueTrack=[super continueTrackingWithTouch:touch withEvent:event];
    if (continueTrack) {
        if ([self.delegate respondsToSelector:@selector(currentValueOfSlider:)]) {
            [self.delegate currentValueOfSlider:self.value];
        }
    }
    return continueTrack;
}
// 取消触摸Slider
- (void)cancelTrackingWithEvent:(UIEvent *)event{
    [super cancelTrackingWithEvent:event];
}
// 结束触摸Slider
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    if ([self.delegate respondsToSelector:@selector(currentValueOfSlider:)]) {
        [self.delegate currentValueOfSlider:self.value];
    }
    if ([self.delegate respondsToSelector:@selector(endSwipSlider)]) {
        [self.delegate endSwipSlider];
    }
}

@end
