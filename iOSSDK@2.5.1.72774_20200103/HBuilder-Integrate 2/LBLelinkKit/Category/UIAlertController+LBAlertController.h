//
//  UIAlertController+LBAlertController.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/9/3.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (LBAlertController)

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message okHandler:(void (^ __nullable)(UIAlertAction *action))handler;

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message okHandler:(void (^ __nullable)(UIAlertAction *action))okHandler cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler;

@end

NS_ASSUME_NONNULL_END
