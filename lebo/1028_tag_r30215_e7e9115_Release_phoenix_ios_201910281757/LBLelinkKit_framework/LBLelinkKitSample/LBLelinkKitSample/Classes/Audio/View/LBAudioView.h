//
//  LBAudioView.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/29.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LBAudioView;

@protocol LBAudioViewDelegate <NSObject>

@optional
- (void)audioView:(LBAudioView *)audioView castBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView progressSliderClicked:(UISlider *)slider;
- (void)audioView:(LBAudioView *)audioView pauseOrResumeBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView nextBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView previousBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView volumeAddBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView volumeSubBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView switchDeviceBtnClicked:(UIButton *)button;
- (void)audioView:(LBAudioView *)audioView stopBtnClicked:(UIButton *)button;

@end

@interface LBAudioView : UIView

@property (nonatomic, weak) id<LBAudioViewDelegate> delegate;

- (void)swithToCastMode:(BOOL)isCastMode;
- (void)updatePlayStatus:(NSInteger)status;
- (void)updatePlayProgress:(LBLelinkProgressInfo *)progressInfo;

@end

NS_ASSUME_NONNULL_END
