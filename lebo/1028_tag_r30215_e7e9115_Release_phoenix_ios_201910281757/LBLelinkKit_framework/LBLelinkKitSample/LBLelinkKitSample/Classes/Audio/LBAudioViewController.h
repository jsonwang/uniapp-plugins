//
//  LBAudioViewController.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/20.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LBAudioViewControllerType) {
    LBAudioViewControllerTypeOnline,
    LBAudioViewControllerTypeLocal,
};

@interface LBAudioViewController : LBBaseViewController

@property (nonatomic, assign) LBAudioViewControllerType type;

@end

NS_ASSUME_NONNULL_END
