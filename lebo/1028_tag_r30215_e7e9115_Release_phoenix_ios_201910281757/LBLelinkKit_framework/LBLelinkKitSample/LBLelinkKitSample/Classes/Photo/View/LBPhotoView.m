//
//  LBPhotoView.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/29.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBPhotoView.h"
#import "UIButton+LBUIButton.h"

@interface LBPhotoView ()

@property (nonatomic, strong) UIButton *castBtn;
@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) UIButton *previousBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *switchDeviceBtn;
@property (nonatomic, strong) UIButton *stopBtn;

@end

@implementation LBPhotoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUI];
    }
    return self;
}

#pragma mark - API

- (void)setPhotoImageViewWithUrlString:(NSString *)urlString {
    self.photo.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
}

- (void)swithToCastMode:(BOOL)isCastMode {
    self.switchDeviceBtn.hidden = !isCastMode;
    self.castBtn.hidden = isCastMode;
    self.stopBtn.hidden = !isCastMode;
}

#pragma mark - action

- (void)castBtnClicked:(UIButton *)btn {
    NSLog(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(photoView:castBtnClicked:)]) {
        [self.delegate photoView:self castBtnClicked:btn];
    }
}

- (void)previousBtnClicked:(UIButton *)btn {
    NSLog(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(photoView:previousBtnClicked:)]) {
        [self.delegate photoView:self previousBtnClicked:btn];
    }
}

- (void)nextBtnClicked:(UIButton *) btn {
    NSLog(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(photoView:nextBtnClicked:)]) {
        [self.delegate photoView:self nextBtnClicked:btn];
    }
}

- (void)switchDeviceBtnClicked:(UIButton *)btn {
    NSLog(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(photoView:switchDeviceBtnClicked:)]) {
        [self.delegate photoView:self switchDeviceBtnClicked:btn];
    }
}

- (void)stopBtnClicked:(UIButton *)btn {
    NSLog(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(photoView:stopBtnClicked:)]) {
        [self.delegate photoView:self stopBtnClicked:btn];
    }
}

#pragma mark - UI

- (void)setUI {
    [self addSubview:self.photo];
    [self addSubview:self.castBtn];
    [self addSubview:self.nextBtn];
    [self addSubview:self.previousBtn];
    [self addSubview:self.switchDeviceBtn];
    [self addSubview:self.stopBtn];
    
    [self.castBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (LBHasSafeArea) {
            make.top.equalTo(self.mas_safeAreaLayoutGuide).offset(20);
        } else {
            make.top.equalTo(self).offset(84);
        }
        make.trailing.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.photo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
    }];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-50);
        make.leading.equalTo(self.mas_centerX).offset(5);
    }];
    [self.previousBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nextBtn);
        make.trailing.equalTo(self.nextBtn.mas_leading).offset(-10);
    }];
    [self.switchDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.previousBtn);
        make.trailing.equalTo(self.previousBtn.mas_leading).offset(-10);
    }];
    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nextBtn);
        make.leading.equalTo(self.nextBtn.mas_trailing).offset(10);
    }];
    
}

#pragma mark - getter & setter

- (UIImageView *)photo{
    if (_photo == nil) {
        _photo = [[UIImageView alloc] init];
        _photo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _photo;
}

- (UIButton *)castBtn{
    if (_castBtn == nil) {
        _castBtn = [UIButton buttonWithImage:@"cast_button" target:self action:@selector(castBtnClicked:)];
    }
    return _castBtn;
}

- (UIButton *)nextBtn{
    if (_nextBtn == nil) {
        _nextBtn = [UIButton buttonWithTitle:@"下一张" titleColor:[UIColor blackColor] target:self action:@selector(nextBtnClicked:)];
    }
    return _nextBtn;
}

- (UIButton *)previousBtn{
    if (_previousBtn == nil) {
        _previousBtn = [UIButton buttonWithTitle:@"上一张" titleColor:[UIColor blackColor] target:self action:@selector(previousBtnClicked:)];
    }
    return _previousBtn;
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
