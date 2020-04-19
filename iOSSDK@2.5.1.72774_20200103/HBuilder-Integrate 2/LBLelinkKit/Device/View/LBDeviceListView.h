//
//  LBDeviceListView.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/21.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LBDeviceListView;

@protocol LBDeviceListViewDelegate <NSObject>
@optional
- (void)deviceListView:(LBDeviceListView *)deviceListView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)deviceListView:(LBDeviceListView *)deviceListView helpBtnClicked:(UIButton *)button;

@end

@interface LBDeviceListView : UIView

@property (nonatomic, strong) NSMutableArray *lelinkConnections;
@property (nonatomic, weak) id<LBDeviceListViewDelegate> delegate;


- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
