//
//  LBAudioView.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/29.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBAudioView.h"
#import "UIButton+LBUIButton.h"

@interface LBAudioView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *castBtn;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *pauseOrResumeBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *previousBtn;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UIButton *volumeAddBtn;
@property (nonatomic, strong) UIButton *volumeSubBtn;
@property (nonatomic, strong) UIButton *switchDeviceBtn;
@property (nonatomic, strong) UIButton *stopBtn;


@end

@implementation LBAudioView

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
    self.castBtn.hidden = isCastMode;
    self.progressSlider.hidden = !isCastMode;
    self.pauseOrResumeBtn.hidden = !isCastMode;
    self.nextBtn.hidden = !isCastMode;
    self.previousBtn.hidden = !isCastMode;
    self.volumeLabel.hidden = !isCastMode;
    self.volumeAddBtn.hidden = !isCastMode;
    self.volumeSubBtn.hidden = !isCastMode;
    self.switchDeviceBtn.hidden = !isCastMode;
    self.stopBtn.hidden = !isCastMode;
}

- (void)updatePlayStatus:(NSInteger)status {
    switch (status) {
        case LBLelinkPlayStatusError:
            break;
        case LBLelinkPlayStatusUnkown:
            break;
        case LBLelinkPlayStatusLoading:
//            [self showTipWithMessage:nil];
            break;
        case LBLelinkPlayStatusPlaying:
//            [self changeUIToPlaying:YES];
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
}

#pragma mark - action

- (void)castBtnClicked:(UIButton *)btn {
    NSLog(@"castBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:castBtnClicked:)]) {
        [self.delegate audioView:self castBtnClicked:btn];
    }
}

- (void)progressSliderClicked:(UISlider *)slider {
    NSLog(@"progressSliderClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:progressSliderClicked:)]) {
        [self.delegate audioView:self progressSliderClicked:slider];
    }
}

- (void)pauseOrResumeBtnClicked:(UIButton *)btn {
    NSLog(@"pauseOrResumeBtnClicked");
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(audioView:pauseOrResumeBtnClicked:)]) {
        [self.delegate audioView:self pauseOrResumeBtnClicked:btn];
    }
}

- (void)nextBtnClicked:(UIButton *)btn {
    NSLog(@"nextBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:nextBtnClicked:)]) {
        [self.delegate audioView:self nextBtnClicked:btn];
    }
}

- (void)previousBtnClicked:(UIButton *)btn {
    NSLog(@"previousBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:previousBtnClicked:)]) {
        [self.delegate audioView:self previousBtnClicked:btn];
    }
}

- (void)volumeAddBtnClicked:(UIButton *)btn {
    NSLog(@"volumeAddBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:volumeAddBtnClicked:)]) {
        [self.delegate audioView:self volumeAddBtnClicked:btn];
    }
}

- (void)volumeSubBtnClicked:(UIButton *)btn {
    NSLog(@"volumeSubBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:volumeSubBtnClicked:)]) {
        [self.delegate audioView:self volumeSubBtnClicked:btn];
    }
}

- (void)switchDeviceBtnClicked:(UIButton *)btn {
    NSLog(@"switchDeviceBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:switchDeviceBtnClicked:)]) {
        [self.delegate audioView:self switchDeviceBtnClicked:btn];
    }
}

- (void)stopBtnClicked:(UIButton *)btn {
    NSLog(@"stopBtnClicked");
    if ([self.delegate respondsToSelector:@selector(audioView:stopBtnClicked:)]) {
        [self.delegate audioView:self stopBtnClicked:btn];
    }
}

#pragma mark - UI

- (void)setUI {
    [self addSubview:self.bgImageView];
    [self addSubview:self.castBtn];
    [self addSubview:self.progressSlider];
    [self addSubview:self.pauseOrResumeBtn];
    [self addSubview:self.nextBtn];
    [self addSubview:self.previousBtn];
    [self addSubview:self.volumeLabel];
    [self addSubview:self.volumeAddBtn];
    [self addSubview:self.volumeSubBtn];
    [self addSubview:self.switchDeviceBtn];
    [self addSubview:self.stopBtn];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(198, 198));
    }];
    [self.castBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (LBHasSafeArea) {
            make.top.equalTo(self.mas_safeAreaLayoutGuide).offset(20);
        } else {
            make.top.equalTo(self).offset(84);
        }
        make.trailing.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView.mas_bottom).offset(10);
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
    }];
    [self.pauseOrResumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.progressSlider.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pauseOrResumeBtn);
        make.leading.equalTo(self.pauseOrResumeBtn.mas_trailing).offset(50);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.previousBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pauseOrResumeBtn);
        make.trailing.equalTo(self.pauseOrResumeBtn.mas_leading).offset(-50);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.pauseOrResumeBtn.mas_bottom).offset(20);
    }];
    [self.volumeAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.volumeLabel);
        make.leading.equalTo(self.volumeLabel.mas_trailing);
    }];
    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.volumeAddBtn);
        make.leading.equalTo(self.volumeAddBtn.mas_trailing).offset(10);
    }];
    [self.volumeSubBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.volumeLabel);
        make.trailing.equalTo(self.volumeLabel.mas_leading);
    }];
    [self.switchDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.volumeSubBtn);
        make.trailing.equalTo(self.volumeSubBtn.mas_leading).offset(-10);
    }];
}

#pragma mark - setter & getter

- (UIImageView *)bgImageView{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"audio_bg"];
    }
    return _bgImageView;
}

- (UIButton *)castBtn{
    if (_castBtn == nil) {
        _castBtn = [UIButton buttonWithImage:@"cast_button" target:self action:@selector(castBtnClicked:)];
    }
    return _castBtn;
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
        [_pauseOrResumeBtn setImage:[UIImage imageNamed:@"plause_state"] forState:UIControlStateNormal];
        [_pauseOrResumeBtn setImage:[UIImage imageNamed:@"play_state"] forState:UIControlStateSelected];
        [_pauseOrResumeBtn addTarget:self action:@selector(pauseOrResumeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseOrResumeBtn;
}

- (UIButton *)nextBtn{
    if (_nextBtn == nil) {
        _nextBtn = [UIButton buttonWithImage:@"next" target:self action:@selector(nextBtnClicked:)];
    }
    return _nextBtn;
}

- (UIButton *)previousBtn{
    if (_previousBtn == nil) {
        _previousBtn = [UIButton buttonWithImage:@"previous" target:self action:@selector(previousBtnClicked:)];
    }
    return _previousBtn;
}

- (UILabel *)volumeLabel{
    if (_volumeLabel == nil) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.text = @"音量";
        _volumeLabel.font = [UIFont systemFontOfSize:17];
        _volumeLabel.textColor = [UIColor blackColor];
    }
    return _volumeLabel;
}

- (UIButton *)volumeAddBtn{
    if (_volumeAddBtn == nil) {
        _volumeAddBtn = [UIButton buttonWithTitle:@"+" titleColor:[UIColor blackColor] target:self action:@selector(volumeAddBtnClicked:)];
    }
    return _volumeAddBtn;
}

- (UIButton *)volumeSubBtn{
    if (_volumeSubBtn == nil) {
        _volumeSubBtn = [UIButton buttonWithTitle:@"-" titleColor:[UIColor blackColor] target:self action:@selector(volumeSubBtnClicked:)];
    }
    return _volumeSubBtn;
}

- (UIButton *)switchDeviceBtn{
    if (_switchDeviceBtn == nil) {
        _switchDeviceBtn = [UIButton buttonWithTitle:@"切换设备" titleColor:[UIColor blackColor] target:self action:@selector(switchDeviceBtnClicked:)];
    }
    return _switchDeviceBtn;
}

- (UIButton *)stopBtn{
    if (_stopBtn == nil) {
        _stopBtn = [UIButton buttonWithTitle:@"结束投屏" titleColor:[UIColor blackColor] target:self action:@selector(stopBtnClicked:)];
    }
    return _stopBtn;
}

@end
