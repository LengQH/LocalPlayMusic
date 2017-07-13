//
//  StartAnimationViewController.h
//  LocalPlayMusic
//
//  Created by 冷求慧 on 17/6/21.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "AllSuperViewController.h"

typedef void (^AnimationBock) (void);

@interface StartAnimationViewController : AllSuperViewController

/**
 *  动画完成的回调
 */
@property (nonatomic,copy)AnimationBock   finishAnimationBlock;

@end
