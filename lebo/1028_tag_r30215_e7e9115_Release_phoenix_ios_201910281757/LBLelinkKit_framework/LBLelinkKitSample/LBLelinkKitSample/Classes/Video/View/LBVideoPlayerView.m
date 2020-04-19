//
//  LBVideoPlayerView.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/22.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBVideoPlayerView.h"

#import "NSString+LBNSString.h"

@interface LBVideoPlayerView ()

@property (nonatomic, strong) UIButton *castToTVBtn;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *pauseOrResumeBtn;
@property (nonatomic, strong) UIButton *switchDeviceBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UILabel *deviceNameLabel;
@property (nonatomic, strong) UILabel *progressTimeLabel;
@property (nonatomic, strong) UIButton *volumeAddBtn;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UIButton *volumeSubBtn;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation LBVideoPlayerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUI];
    }
    return self;
}

#pragma mark - API

- (void)swithToCastMode:(BOOL)isCastMode {
    self.castToTVBtn.hidden = isCastMode;
    
    self.progressSlider.hidden = !isCastMode;
    self.pauseOrResumeBtn.hidden = !isCastMode;
    self.switchDeviceBtn.hidden = !isCastMode;
    self.stopBtn.hidden = !isCastMode;
    self.deviceNameLabel.hidden = !isCastMode;
    self.progressTimeLabel.hidden = !isCastMode;
    self.volumeAddBtn.hidden = !isCastMode;
    self.volumeLabel.hidden = !isCastMode;
    self.volumeSubBtn.hidden = !isCastMode;
    self.tipLabel.hidden = !isCastMode;
}

- (void)setServiceName:(NSString *)name {
    self.deviceNameLabel.text = name;
}

- (void)updatePlayStatus:(NSInteger)status {
    switch (status) {
        case LBLelinkPlayStatusError:
            break;
        case LBLelinkPlayStatusUnkown:
            break;
        case LBLelinkPlayStatusLoading:
            [self showTipWithMessage:nil];
            break;
        case LBLelinkPlayStatusPlaying:
            [self hideTip];
            self.pauseOrResumeBtn.selected = NO;
            break;
        case LBLelinkPlayStatusPause:
            self.pauseOrResumeBtn.selected = YES;
            break;
        case LBLelinkPlayStatusStopped:
            break;
        case LBLelinkPlayStatusCommpleted:
            break;
        default:
            break;
    }
}

- (void)updatePlayProgress:(LBLelinkProgressInfo *)progressInfo {
    /** 更新进度条 */
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = progressInfo.duration;
    self.progressSlider.value = progressInfo.currentTime;
    
    /** 更新label */
    self.progressTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[NSString timeStringFromeInteger:progressInfo.currentTime], [NSString timeStringFromeInteger:progressInfo.duration]];
    
    [self hideTip];
    
}

#pragma mark - action

- (void)castToTVBtnClicked:(UIButton *)btn {
    NSLog(@"castToTVBtnClicked");
    
    [LBLelinkBrowser reportAPPTVButtonAction];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:castToTVBtnClicked:)]) {
        [self.delegate videoPlayerView:self castToTVBtnClicked:btn];
    }
    
}

- (void)pauseOrResumeBtnClicked:(UIButton *)btn {
    NSLog(@"pauseOrResumeBtnClicked");
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:pauseOrResumeBtnClicked:)]) {
        [self.delegate videoPlayerView:self pauseOrResumeBtnClicked:btn];
    }
}

- (void)progressSliderClicked:(UISlider *)slider {
    NSLog(@"progressSliderClicked");
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:progressSliderClicked:)]) {
        [self.delegate videoPlayerView:self progressSliderClicked:slider];
    }
}

- (void)switchDeviceBtnClicked:(UIButton *)btn {
    NSLog(@"switchDeviceBtnClicked");
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:switchDeviceBtnClicked:)]) {
        [self.delegate videoPlayerView:self switchDeviceBtnClicked:btn];
    }
}

- (void)stopBtnClicked:(UIButton *)btn {
    NSLog(@"stopBtnClicked");
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:stopBtnClicked:)]) {
        [self.delegate videoPlayerView:self stopBtnClicked:btn];
    }
    [self hideTip];
}

- (void)volumeAddBtnClicked:(UIButton *)btn {
    NSLog(@"volumeAddBtnClicked");
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:volumeAddBtnClicked:)]) {
        [self.delegate videoPlayerView:self volumeAddBtnClicked:btn];
    }
}

- (void)volumeSubBtnClicked:(UIButton *)btn {
    NSLog(@"volumeSubBtnClicked");
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:volumeSubBtnClicked:)]) {
        [self.delegate videoPlayerView:self volumeSubBtnClicked:btn];
    }
}

#pragma mark - UI

- (void)setUI {
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.castToTVBtn];
    [self addSubview:self.progressSlider];
    [self addSubview:self.pauseOrResumeBtn];
    [self addSubview:self.switchDeviceBtn];
    [self addSubview:self.stopBtn];
    [self addSubview:self.deviceNameLabel];
    [self addSubview:self.progressTimeLabel];
    [self addSubview:self.volumeAddBtn];
    [self addSubview:self.volumeLabel];
    [self addSubview:self.volumeSubBtn];
    [self addSubview:self.tipLabel];
    
    [self.castToTVBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (LBHasSafeArea) {
            make.top.equalTo(self.mas_safeAreaLayoutGuide).offset(4);
        } else {
            make.top.equalTo(self).offset(24);
        }
        make.trailing.equalTo(self).offset(-8);
        make.size.mas_offset(CGSizeMake(44, 44));
    }];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.trailing.equalTo(self).offset(-8);
        make.bottom.equalTo(self).offset(-8);
        make.height.equalTo(@44);
    }];
    [self.pauseOrResumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.bottom.equalTo(self.progressSlider.mas_top);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.switchDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressSlider.mas_top);
        make.trailing.equalTo(self.mas_centerX).offset(-2);
    }];
    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressSlider.mas_top);
        make.leading.equalTo(self.mas_centerX).offset(2);
    }];
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(24);
        make.centerX.equalTo(self);
    }];
    [self.progressTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-20);
    }];
    [self.volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-20);
    }];
    [self.volumeAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.volumeLabel.mas_top);
        make.centerX.equalTo(self.volumeLabel);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.volumeSubBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.volumeLabel.mas_bottom);
        make.centerX.equalTo(self.volumeLabel);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
}

- (void)showTipWithMessage:(NSString *)message {
    if (message && message.length) {
        self.tipLabel.text = message;
    }
    self.tipLabel.hidden = NO;
}

- (void)hideTip {
    if (self.tipLabel.hidden == NO) {
        self.tipLabel.hidden = YES;
    }
}


#pragma mark - setter & getter

- (UIButton *)castToTVBtn{
    if (_castToTVBtn == nil) {
        _castToTVBtn = [[UIButton alloc] init];
        [_castToTVBtn setImage:[UIImage imageNamed:@"player_photo_play_button"] forState:UIControlStateNormal];
        [_castToTVBtn addTarget:self action:@selector(castToTVBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _castToTVBtn;
}

- (UISlider *)progressSlider{
    if (_progressSlider == nil) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider addTarget:self action:@selector(progressSliderClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _progressSlider;
}

- (UIButton *)pauseOrResumeBtn{
    if (_pauseOrResumeBtn == nil) {
        _pauseOrResumeBtn = [[UIButton alloc] init];
        [_pauseOrResumeBtn setImage:[UIImage imageNamed:@"moviepage_suspend_button"] forState:UIControlStateNormal];
        [_pauseOrResumeBtn setImage:[UIImage imageNamed:@"moviepage_play_button"] forState:UIControlStateSelected];
        [_pauseOrResumeBtn addTarget:self action:@selector(pauseOrResumeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseOrResumeBtn;
}

- (UIButton *)switchDeviceBtn{
    if (_switchDeviceBtn == nil) {
        _switchDeviceBtn = [[UIButton alloc] init];
        [_switchDeviceBtn setTitle:@"切换设备" forState:UIControlStateNormal];
        [_switchDeviceBtn addTarget:self action:@selector(switchDeviceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchDeviceBtn;
}

- (UIButton *)stopBtn{
    if (_stopBtn == nil) {
        _stopBtn = [[UIButton alloc] init];
        [_stopBtn setTitle:@"退出投屏" forState:UIControlStateNormal];
        [_stopBtn addTarget:self action:@selector(stopBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopBtn;
}

- (UILabel *)deviceNameLabel{
    if (_deviceNameLabel == nil) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.text = @"电视";
        _deviceNameLabel.textColor = [UIColor whiteColor];
        _deviceNameLabel.font = [UIFont systemFontOfSize:17];
    }
    return _deviceNameLabel;
}

- (UILabel *)progressTimeLabel{
    if (_progressTimeLabel == nil) {
        _progressTimeLabel = [[UILabel alloc] init];
        _progressTimeLabel.textColor = [UIColor whiteColor];
        _progressTimeLabel.text = @"00:00:00/00:00:00";
        _progressTimeLabel.font = [UIFont systemFontOfSize:17];
        
    }
    return _progressTimeLabel;
}

- (UIButton *)volumeAddBtn{
    if (_volumeAddBtn == nil) {
        _volumeAddBtn = [[UIButton alloc] init];
        [_volumeAddBtn setTitle:@"+" forState:UIControlStateNormal];
        [_volumeAddBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_volumeAddBtn addTarget:self action:@selector(volumeAddBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeAddBtn;
}

- (UILabel *)volumeLabel{
    if (_volumeLabel == nil) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.textColor = [UIColor whiteColor];
        _volumeLabel.font = [UIFont systemFontOfSize:12];
        _volumeLabel.text = @"音量";
    }
    return _volumeLabel;
}

- (UIButton *)volumeSubBtn{
    if (_volumeSubBtn == nil) {
        _volumeSubBtn = [[UIButton alloc] init];
        [_volumeSubBtn setTitle:@"-" forState:UIControlStateNormal];
        [_volumeSubBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_volumeSubBtn addTarget:self action:@selector(volumeSubBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeSubBtn;
}

- (UILabel *)tipLabel{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont systemFontOfSize:17];
        _tipLabel.text = @"正在努力投屏中...";
        _tipLabel.hidden = YES;
    }
    return _tipLabel;
}

@end
