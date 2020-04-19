//
//  UIButton+LBUIButton.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/14.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LBUIButton)

+ (instancetype)buttonWithTitle:(nullable NSString *)title target:(nullable id)target action:(SEL)action;
+ (instancetype)buttonWithImage:(NSString *)imageName target:(nullable id)target action:(SEL)action;
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(nullable UIColor *)color target:(id)target action:(SEL)action;

+ (instancetype)buttonWithTitle:(nullable NSString *)title target:(nullable id)target action:(SEL)action imageName:(nonnull NSString *)imageName;


+ (instancetype)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action imageName:(NSString *)imageName titleFont:(UIFont *)font titleTextColor:(nullable UIColor *)color;

+ (void)setButtonTitleToBottom:(UIButton *)button;
+ (void)setButtonTitleToLeft:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
