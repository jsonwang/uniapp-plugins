//
//  LBVideoPlayerView.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/22.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LBVideoPlayerView;

@protocol LBVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView castToTVBtnClicked:(UIButton *)button;
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView pauseOrResumeBtnClicked:(UIButton *)button;
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView progressSliderClicked:(UISlider *)slider;
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView switchDeviceBtnClicked:(UIButton *)button;
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView stopBtnClicked:(UIButton *)button;
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView volumeAddBtnClicked:(UIButton *)button;
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView volumeSubBtnClicked:(UIButton *)button;

@end

@interface LBVideoPlayerView : UIView

@property(nonatomic, weak) id<LBVideoPlayerViewDelegate> delegate;

- (void)swithToCastMode:(BOOL)isCastMode;
- (void)setServiceName:(NSString *)name;
- (void)updatePlayStatus:(NSInteger)status;
- (void)updatePlayProgress:(LBLelinkProgressInfo *)progressInfo;

@end

NS_ASSUME_NONNULL_END
