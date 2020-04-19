//
//  UIButton+LBUIButton.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/14.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "UIButton+LBUIButton.h"

@implementation UIButton (LBUIButton)

+ (instancetype)buttonWithTitle:(nullable NSString *)title target:(nullable id)target action:(SEL)action {
    UIButton * btn = [[UIButton alloc] init];
    
    btn.backgroundColor = [UIColor colorWithRed:15.0 / 255.0 green:131.0 / 255.0 blue:1.0 alpha:1.0];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(nullable UIColor *)color target:(id)target action:(SEL)action {
    UIButton * btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:color forState:UIControlStateNormal];
    
    return btn;
}

+ (instancetype)buttonWithImage:(NSString *)imageName target:(nullable id)target action:(SEL)action {
    UIButton * btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

+ (instancetype)buttonWithTitle:(nullable NSString *)title target:(nullable id)target action:(SEL)action imageName:(nonnull NSString *)imageName {
    UIButton * btn = [self buttonWithTitle:title target:target action:action imageName:imageName titleFont:[UIFont systemFontOfSize:17] titleTextColor:[UIColor blackColor]];
    return btn;
}

+ (instancetype)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action imageName:(NSString *)imageName titleFont:(UIFont *)font titleTextColor:(nullable UIColor *)color {
    UIButton * btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

+ (void)setButtonTitleToBottom:(UIButton *)button {
    
    // 左右居中调整
    CGFloat buttonCenterX = CGRectGetMidX(button.bounds);
    CGFloat imageViewCenterX = CGRectGetMidX(button.imageView.frame);
    // 计算title的文字实际宽度
    CGSize titleRealSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    CGFloat titleRealWidth = titleRealSize.width;
    CGRect titleRealFrame = button.titleLabel.frame;
    titleRealFrame.size.width = titleRealWidth;
    button.titleLabel.frame = titleRealFrame;
    CGFloat titleLabelCenterX = CGRectGetMidX(button.titleLabel.frame);
    
    // 上下移动调整
    CGFloat buttonHeight = button.bounds.size.height;
    CGFloat imageViewHeight = button.imageView.frame.size.height;
    CGFloat titleLabelHeight = button.titleLabel.frame.size.height;
    CGFloat topBottomMargin = (buttonHeight - (imageViewHeight + titleLabelHeight)) * 0.5;
    CGFloat imageMoveTop = (buttonHeight * 0.5 - imageViewHeight * 0.5) - topBottomMargin;
    CGFloat titleMoveBottom = (buttonHeight * 0.5 - titleLabelHeight * 0.5) - topBottomMargin;
    
    button.imageEdgeInsets = UIEdgeInsetsMake(-imageMoveTop, buttonCenterX - imageViewCenterX, imageMoveTop, -(buttonCenterX - imageViewCenterX));
    //    button.titleEdgeInsets = UIEdgeInsetsMake(titleMoveBottom, -(titleLabelCenterX - buttonCenterX), -titleMoveBottom, titleLabelCenterX - buttonCenterX);
    button.titleEdgeInsets = UIEdgeInsetsMake(titleMoveBottom, -(titleLabelCenterX - buttonCenterX), -titleMoveBottom, 0);// title的右边不移动，否则文字会显示不全
    
}

+ (void)setButtonTitleToLeft:(UIButton *)button {
    CGFloat imageWidth = button.imageView.frame.size.width;
    CGFloat titleWidth = button.titleLabel.frame.size.width;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
}

@end
