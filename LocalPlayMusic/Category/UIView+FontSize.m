//
//  UIView+FontSize.m
//  yoli
//
//  Created by 冷求慧 on 16/11/24.
//  Copyright © 2016年 Leng. All rights reserved.
//

#import "UIView+FontSize.h"
#import <objc/runtime.h>

@implementation UIView (FontSize)
@end

@implementation UILabel (FontSize)
+ (void)load{
    
    // 通过Xib关联UILabel的时候
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));     //通过运行时用自定义的方法去交换系统的(initWithCoder:)方法
    Method myImp = class_getInstanceMethod([self class], @selector(customLabelInitWithCoder:));
    method_exchangeImplementations(imp, myImp);
    
    // 通过Frame创建UILabel后,用上面的方法是不行的(因为如果不设置font的大小,永远都是17(默认大小)*比例,设置font的大小永远就是font的值),具体原因是UILabe要先创建再去设置font的大小,如果不设置就是默认的17
    
    //    Method cmp = class_getInstanceMethod([self class], @selector(initWithFrame:));
    //    Method myCmp = class_getInstanceMethod([self class], @selector(customInitWithFrame:));
    //    method_exchangeImplementations(cmp, myCmp);
}
#pragma mark Xib关联的时候,替换系统的方法
-(id)customLabelInitWithCoder:(NSCoder*)aDecode {
    [self customLabelInitWithCoder:aDecode];
    if (self) {
        CGFloat addFontFloat=self.font.pointSize*heightRatioWithAll;
        self.font=[self.font fontWithSize:addFontFloat];
//        NSLengLogLeng(@"XIB(UILabel),文字比例:%f 最终显示的字体大小:%f",titleRatio,addFontFloat);
    }
    return self;
}
@end


/*********       UIButton      ************/

@implementation UIButton (FontSize)
+(void)load{
    
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod([self class], @selector(customButtonInitWithCode:)); // 改变字体的大小
    method_exchangeImplementations(imp, myImp);
    
    Method highMethod=class_getInstanceMethod([self class], @selector(setHighlighted:));
    Method replaceMethod=class_getInstanceMethod([self class], @selector(replaceHighlighted:)); // 自定义的方法取消系统的高亮状态
    method_exchangeImplementations(highMethod, replaceMethod);
    
}
#pragma mark xib关联改变字体的大小
-(id)customButtonInitWithCode:(NSCoder*)aDecode{
    [self customButtonInitWithCode:aDecode];
    if (self) {
        CGFloat addFontFloat=self.titleLabel.font.pointSize*heightRatioWithAll;
        self.titleLabel.font=[self.titleLabel.font fontWithSize:addFontFloat];
//        NSLengLogLeng(@"XIB(Button),文字比例:%f 最终显示的字体大小:%f",titleRatio,addFontFloat);
    }
    return self;
}
#pragma mark 取消高亮状态
-(void)replaceHighlighted:(BOOL)highlighted{
    
}
@end



/*********       UITextField      ************/

@implementation UITextField (FontSize)
+(void)load{
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod([self class], @selector(customTextFieldInitWithCoder:));
    method_exchangeImplementations(imp, myImp);
}
-(id)customTextFieldInitWithCoder:(NSCoder*)aDecode{
    [self customTextFieldInitWithCoder:aDecode];
    if (self) {
        CGFloat addFontFloat=self.font.pointSize*heightRatioWithAll;
        self.font=[self.font fontWithSize:addFontFloat];
//        NSLengLogLeng(@"XIB(TextField),文字比例:%f 最终显示的字体大小:%f",titleRatio,addFontFloat);
    }
    return self;
}

@end



/*********       UITextView      ************/

@implementation UITextView (FontSize)
+(void)load{
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod([self class], @selector(customTextViewInitWithCoder:));
    method_exchangeImplementations(imp, myImp);
}
-(id)customTextViewInitWithCoder:(NSCoder*)aDecode{
    [self customTextViewInitWithCoder:aDecode];
    if (self) {
        CGFloat addFontFloat=self.font.pointSize*heightRatioWithAll;
        self.font=[self.font fontWithSize:addFontFloat];
//        NSLengLogLeng(@"XIB(TextView),文字比例:%f 最终显示的字体大小:%f",titleRatio,addFontFloat);
    }
    return self;
}

@end


