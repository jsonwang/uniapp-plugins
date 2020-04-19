//
//  LBDeviceListViewCell.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/21.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBDeviceListViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *deviceTypeImageView;
@property (nonatomic, strong) UILabel *deviceNameLabel;
@property (nonatomic, strong) UIImageView *connectionStatusImageView;

@end

NS_ASSUME_NONNULL_END
