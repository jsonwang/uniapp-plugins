//
//  LBVideoViewController.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/20.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 视频播放控制器类型

 - LBVideoViewControllerOnlineSingle: 在线单集
 - LBVideoViewControllerOnlineSerial: 在线剧集
 - LBVideoViewControllerLocal: 本地视频
 */
typedef NS_ENUM(NSUInteger, LBVideoViewControllerType) {
    LBVideoViewControllerOnlineSingle,
    LBVideoViewControllerOnlineSerial,
    LBVideoViewControllerLocal,
};

@interface LBVideoViewController : LBBaseViewController

@property (nonatomic, assign) LBVideoViewControllerType type;

@end

NS_ASSUME_NONNULL_END
