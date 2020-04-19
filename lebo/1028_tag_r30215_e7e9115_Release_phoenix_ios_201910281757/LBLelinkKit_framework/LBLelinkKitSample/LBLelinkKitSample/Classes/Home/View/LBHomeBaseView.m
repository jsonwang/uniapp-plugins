//
//  LBHomeBaseView.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/14.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBHomeBaseView.h"
#import "UIButton+LBUIButton.h"

#define BTNWIDTH ([UIScreen mainScreen].bounds.size.width * 0.25)

@interface LBHomeBaseView ()

@property (nonatomic, strong) UIButton *deviceListBtn;
@property (nonatomic, strong) UIButton *castScreenBtn;

@property (nonatomic, strong) UILabel *onlineTitleLabel;
@property (nonatomic, strong) UIButton *onlineVideoBtnSingle;
@property (nonatomic, strong) UIButton *onlineVideoBtnSerial;
@property (nonatomic, strong) UIButton *onlineAudioBtn;
@property (nonatomic, strong) UIButton *onlinePhotoBtn;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UILabel *localTitleLabel;
@property (nonatomic, strong) UIButton *localVideoBtn;
@property (nonatomic, strong) UIButton *localAutioBtn;
@property (nonatomic, strong) UIButton *localPhotoBtn;

@property (nonatomic, strong) UIButton *introduceBtn;


@end

@implementation LBHomeBaseView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [UIButton setButtonTitleToBottom:self.onlineVideoBtnSingle];
    [UIButton setButtonTitleToBottom:self.onlineVideoBtnSerial];
    [UIButton setButtonTitleToBottom:self.onlineAudioBtn];
    [UIButton setButtonTitleToBottom:self.onlinePhotoBtn];
    
    [UIButton setButtonTitleToBottom:self.localVideoBtn];
    [UIButton setButtonTitleToBottom:self.localAutioBtn];
    [UIButton setButtonTitleToBottom:self.localPhotoBtn];
    
    [UIButton setButtonTitleToLeft:self.introduceBtn];
}

#pragma mark - action

- (void)deviceListBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:deviceLisetBtnClicked:)]) {
        [self.delegate homeBaseView:self deviceLisetBtnClicked:btn];
    }
}

- (void)castScreenBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castScreenBtnClicked:)]) {
        [self.delegate homeBaseView:self castScreenBtnClicked:btn];
    }
}

- (void)onlineVideoBtnSingleClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castOnlineVideoSingleBtnClicked:)]) {
        [self.delegate homeBaseView:self castOnlineVideoSingleBtnClicked:btn];
    }
}

- (void)onlineVideoBtnSerialClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castOnlineVideoSerialBtnClicked:)]) {
        [self.delegate homeBaseView:self castOnlineVideoSerialBtnClicked:btn];
    }
}

- (void)onlineAudioBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castOnlineAudioBtnClicked:)]) {
        [self.delegate homeBaseView:self castOnlineAudioBtnClicked:btn];
    }
}

- (void)onlinePhotoBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castOnlinePhotoBtnClicked:)]) {
        [self.delegate homeBaseView:self castOnlinePhotoBtnClicked:btn];
    }
}

- (void)localVideoBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castLocalVideoBtnClicked:)]) {
        [self.delegate homeBaseView:self castLocalVideoBtnClicked:btn];
    }
}

- (void)localAudioBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castLocalAudioBtnClicked:)]) {
        [self.delegate homeBaseView:self castLocalAudioBtnClicked:btn];
    }
}

- (void)localPhotoBtnClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(homeBaseView:castLocalPhotoBtnClicked:)]) {
        [self.delegate homeBaseView:self castLocalPhotoBtnClicked:btn];
    }
}

- (void)introduceBtnClicked:(UIButton *)btn {
    
    // 主要是测试在没搜索设备之前，数据上报
    [[LBLelinkKitManager sharedManager] reportSerivesListViewDisappear];
    
    if ([self.delegate respondsToSelector:@selector(homeBaseView:introduceBtnClicked:)]) {
        [self.delegate homeBaseView:self introduceBtnClicked:btn];
    }
}

#pragma mark - UI

- (void)setUI {
    [self addSubview:self.deviceListBtn];
    [self addSubview:self.castScreenBtn];
    
    [self addSubview:self.onlineTitleLabel];
    [self addSubview:self.onlineVideoBtnSingle];
    [self addSubview:self.onlineVideoBtnSerial];
    [self addSubview:self.onlineAudioBtn];
    [self addSubview:self.onlinePhotoBtn];
    
    [self addSubview:self.line];
    
    [self addSubview:self.localTitleLabel];
    [self addSubview:self.localVideoBtn];
    [self addSubview:self.localAutioBtn];
    [self addSubview:self.localPhotoBtn];
    
    [self addSubview:self.introduceBtn];
    
    [self.deviceListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (LBHasSafeArea) {
            make.top.equalTo(self.mas_safeAreaLayoutGuide).offset(10);
        } else {
            make.top.equalTo(self).offset(64 + 10);
        }
        make.leading.equalTo(self).offset(60);
        make.trailing.equalTo(self).offset(-60);
        make.height.equalTo(@40);
    }];
    
    [self.castScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceListBtn.mas_bottom).offset(10);
        make.leading.equalTo(self.deviceListBtn);
        make.size.equalTo(self.deviceListBtn);
    }];
    
    [self.onlineTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.castScreenBtn.mas_bottom).offset(10);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
    }];
    [self.onlineVideoBtnSingle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.onlineTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    [self.onlineVideoBtnSerial mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.onlineTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.onlineVideoBtnSingle.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    [self.onlineAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.onlineTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.onlineVideoBtnSerial.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    [self.onlinePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.onlineTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.onlineAudioBtn.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.onlinePhotoBtn.mas_bottom).offset(10);
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@2);
    }];
    
    [self.localTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line.mas_bottom).offset(10);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
    }];
    [self.localVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.localTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    [self.localAutioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.localTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.localVideoBtn.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    [self.localPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.localTitleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.localAutioBtn.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(BTNWIDTH, BTNWIDTH + 25));
    }];
    
    [self.introduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        if (LBHasSafeArea) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuide).offset(-20);
        } else {
            make.bottom.equalTo(self).offset(-20);
        }
        make.height.equalTo(@30);
    }];
    
}


#pragma mark - setter & getter

- (UIButton *)deviceListBtn{
    if (_deviceListBtn == nil) {
        _deviceListBtn = [UIButton buttonWithTitle:@"投屏设备列表" target:self action:@selector(deviceListBtnClicked:)];
    }
    return _deviceListBtn;
}

- (UIButton *)castScreenBtn{
    if (_castScreenBtn == nil) {
        _castScreenBtn = [UIButton buttonWithTitle:@"投屏幕" target:self action:@selector(castScreenBtnClicked:)];
    }
    return _castScreenBtn;
}

- (UILabel *)onlineTitleLabel{
    if (_onlineTitleLabel == nil) {
        _onlineTitleLabel = [[UILabel alloc] init];
        _onlineTitleLabel.text = @"在线资源投屏";
        _onlineTitleLabel.font = [UIFont boldSystemFontOfSize:30];
        _onlineTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _onlineTitleLabel;
}

- (UIButton *)onlineVideoBtnSingle{
    if (_onlineVideoBtnSingle == nil) {
        _onlineVideoBtnSingle = [UIButton buttonWithTitle:@"在线单集" target:self action:@selector(onlineVideoBtnSingleClicked:) imageName:@"u10"];
    }
    return _onlineVideoBtnSingle;
}

- (UIButton *)onlineVideoBtnSerial{
    if (_onlineVideoBtnSerial == nil) {
        _onlineVideoBtnSerial = [UIButton buttonWithTitle:@"在线剧集" target:self action:@selector(onlineVideoBtnSerialClicked:) imageName:@"onlineSerial"];
    }
    return _onlineVideoBtnSerial;
}

- (UIButton *)onlineAudioBtn{
    if (_onlineAudioBtn == nil) {
        _onlineAudioBtn = [UIButton buttonWithTitle:@"在线音频" target:self action:@selector(onlineAudioBtnClicked:) imageName:@"audio"];
    }
    return _onlineAudioBtn;
}

- (UIButton *)onlinePhotoBtn{
    if (_onlinePhotoBtn == nil) {
        _onlinePhotoBtn = [UIButton buttonWithTitle:@"在线图片" target:self action:@selector(onlinePhotoBtnClicked:) imageName:@"photo"];
    }
    return _onlinePhotoBtn;
}

- (UIView *)line{
    if (_line == nil) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor grayColor];
    }
    return _line;
}

- (UILabel *)localTitleLabel{
    if (_localTitleLabel == nil) {
        _localTitleLabel = [[UILabel alloc] init];
        _localTitleLabel.text = @"本地资源投屏";
        _localTitleLabel.font = [UIFont boldSystemFontOfSize:30];
        _localTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _localTitleLabel;
}

- (UIButton *)localVideoBtn{
    if (_localVideoBtn == nil) {
        _localVideoBtn = [UIButton buttonWithTitle:@"本地视频" target:self action:@selector(localVideoBtnClicked:) imageName:@"u10"];
    }
    return _localVideoBtn;
}

- (UIButton *)localAutioBtn{
    if (_localAutioBtn == nil) {
        _localAutioBtn = [UIButton buttonWithTitle:@"本地音频" target:self action:@selector(localAudioBtnClicked:) imageName:@"audio"];
    }
    return _localAutioBtn;
}

- (UIButton *)localPhotoBtn{
    if (_localPhotoBtn == nil) {
        _localPhotoBtn = [UIButton buttonWithTitle:@"本地图片" target:self action:@selector(localPhotoBtnClicked:) imageName:@"photo"];
    }
    return _localPhotoBtn;
}

- (UIButton *)introduceBtn{
    if (_introduceBtn == nil) {
        _introduceBtn = [UIButton buttonWithTitle:@"投屏功能介绍" target:self action:@selector(introduceBtnClicked:) imageName:@"rightArrow" titleFont:[UIFont boldSystemFontOfSize:20] titleTextColor:[UIColor colorWithRed:72.0 / 255.0 green:158.0 / 255.0 blue:248.0 / 255.0 alpha:1.0]];
    }
    return _introduceBtn;
}

@end
