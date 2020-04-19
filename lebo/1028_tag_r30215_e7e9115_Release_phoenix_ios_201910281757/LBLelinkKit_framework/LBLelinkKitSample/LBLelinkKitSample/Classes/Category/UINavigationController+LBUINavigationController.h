//
//  UINavigationController+LBUINavigationController.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/28.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (LBUINavigationController)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer * lb_popGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
