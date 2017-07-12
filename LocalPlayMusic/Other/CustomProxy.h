//
//  CustomProxy.h
//  TestRotate
//
//  Created by 冷求慧 on 17/6/5.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomProxy : NSProxy

/**
 *  目标事件
 */
@property (nullable, nonatomic, assign, readonly) id target;
/**
 *  实例方法
 *
 */
- (instancetype)initWithTarget:(id)target;
/**
 *  类方法
 *
 */
+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
