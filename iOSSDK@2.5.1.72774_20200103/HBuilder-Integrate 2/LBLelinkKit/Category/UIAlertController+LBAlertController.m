//
//  UIAlertController+LBAlertController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/9/3.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "UIAlertController+LBAlertController.h"

@implementation UIAlertController (LBAlertController)

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message okHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handler];
    [alertController addAction:okAction];
    
    UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    [vc presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message okHandler:(void (^ __nullable)(UIAlertAction *action))okHandler cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:okHandler];
    [alertController addAction:okAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:cancelHandler];
    [alertController addAction:cancelAction];
    
    UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    [vc presentViewController:alertController animated:YES completion:nil];
}


@end
