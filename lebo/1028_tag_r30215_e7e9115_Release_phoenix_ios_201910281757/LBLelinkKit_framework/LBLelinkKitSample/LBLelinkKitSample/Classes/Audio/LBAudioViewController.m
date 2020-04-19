//
//  LBAudioViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/20.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBAudioViewController.h"
#import "LBAudioView.h"

#import "LBDeviceListViewController.h"
#import "AppDelegate.h"
#include "UIAlertController+LBAlertController.h"

/**
 投屏状态

 - LBAudioCastStateUnCastUnConnect: 未点击投屏，未连接
 - LBAudioCastStateCastedUnConnect: 已点击投屏，未连接
 - LBAudioCastStateCastedConnected: 已点击投屏，已连接
 - LBAudioCastStateUnCastConnected: 未点击投屏（或者点击退出投屏），已连接
 */
typedef NS_ENUM(NSUInteger, LBAudioCastState) {
    LBAudioCastStateUnCastUnConnect,
    LBAudioCastStateCastedUnConnect,
    LBAudioCastStateCastedConnected,
    LBAudioCastStateUnCastConnected,
};

NSString * const kLBOnlineAudioIndex = @"kLBOnlineAudioIndex";
NSString * const kLBLocalAudioIndex = @"kLBLocalAudioIndex";

@interface LBAudioViewController ()<LBAudioViewDelegate>

/** 音乐视图 */
@property (nonatomic, strong) LBAudioView *audioView;
/** 在线音乐url数组 */
@property (nonatomic, strong) NSArray *onlineAudioArr;
/** 在线音乐索引 */
@property (nonatomic, assign) NSInteger onlineAudioIndex;

/** 本地音乐名称 */
@property (nonatomic, strong) NSArray *localAudiosName;
/** 本地音乐在本地webServer的url */
@property (nonatomic, strong) NSArray *localAudiosUrlString;
/** 本地音乐索引 */
@property (nonatomic, assign) NSInteger localAudioIndex;

@property (nonatomic, assign) LBAudioCastState castState;


@end

@implementation LBAudioViewController

- (void)dealloc {
    // 保存当前在线音乐索引
    if (self.type == LBLelinkMediaTypeAudioOnline) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.onlineAudioIndex] forKey:kLBOnlineAudioIndex];
    }else{
        // 保存当前本地音乐索引
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.localAudioIndex] forKey:kLBLocalAudioIndex];
    }
    
    // 移除通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 配置本地
    [self setPrepare];
    
    // 设置UI
    [self setUI];
    
    
    // 设置投屏状态
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        self.castState = LBAudioCastStateUnCastConnected;
    }else{
        self.castState = LBAudioCastStateUnCastUnConnect;
    }
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectedNotification:) name:LBLelinkKitManagerConnectionDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disConnectedNotification:) name:LBLelinkKitManagerConnectionDisConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusNotification:) name:LBLelinkKitManagerPlayerStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerProgressNotification:) name:LBLelinkKitManagerPlayerProgressNotification object:nil];
    
}


- (void)setPrepare {
    if (self.type == LBAudioViewControllerTypeLocal) {// 配置本地音乐相关
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // 启动本地服务器
        [appDelegate.localWebServer startGCDWebServer];
        // 将本地文件拷贝到沙盒
        [appDelegate.localWebServer copyFilesToDocument:self.localAudiosName type:@"mp3"];
        // 获取本地文件的url
        self.localAudiosUrlString = [appDelegate.localWebServer getLocalUrlsWithFileNames:self.localAudiosName type:@"mp3"];
        NSLog(@"%@",self.localAudiosUrlString);
        // 获取本地音乐索引
        NSNumber * indexNum = [[NSUserDefaults standardUserDefaults] objectForKey:kLBLocalAudioIndex];
        if (indexNum) {
            self.localAudioIndex = [indexNum integerValue];
        }
    }else{
        // 获取在线音乐索引
        NSNumber * indexNum = [[NSUserDefaults standardUserDefaults] objectForKey:kLBOnlineAudioIndex];
        if (indexNum) {
            self.onlineAudioIndex = [indexNum integerValue];
        }
    }
}


#pragma mark - LBAudioViewDelegate
/** 投屏 */
- (void)audioView:(LBAudioView *)audioView castBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if (self.castState == LBAudioCastStateUnCastUnConnect) {
        // 调出设备列表
        LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
        [self.navigationController pushViewController:deviceListVC animated:YES];
        self.castState = LBAudioCastStateCastedUnConnect;
    }else if (self.castState == LBAudioCastStateUnCastConnected) {
        // 直接投
        self.castState = LBAudioCastStateCastedConnected;
        [self castAudio];
    }
}
/** 拖动进度条 */
- (void)audioView:(LBAudioView *)audioView progressSliderClicked:(UISlider *)slider {
    NSLog(@"%s",__func__);
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        NSInteger value = (NSInteger)slider.value;
        [[LBLelinkKitManager sharedManager].lelinkPlayer seekTo:value];
    }
}
/** 暂停和继续 */
- (void)audioView:(LBAudioView *)audioView pauseOrResumeBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        if (button.selected) {
            [[LBLelinkKitManager sharedManager].lelinkPlayer pause];
        }else{
            [[LBLelinkKitManager sharedManager].lelinkPlayer resumePlay];
        }
    }else{
        button.selected = !button.selected;
    }
}
/** 上一个 */
- (void)audioView:(LBAudioView *)audioView previousBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if (self.type == LBAudioViewControllerTypeOnline) {// 在线音频
        self.onlineAudioIndex--;
        if (self.onlineAudioIndex < 0) {
            self.onlineAudioIndex = self.onlineAudioArr.count - 1;
        }
    }else{// 本地音频
        self.localAudioIndex--;
        if (self.localAudioIndex < 0) {
            self.localAudioIndex = self.localAudiosUrlString.count - 1;
        }
    }
    
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [self castAudio];
    }
}
/** 下一个 */
- (void)audioView:(LBAudioView *)audioView nextBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    [self nextAudio];
}
/** 音量+ */
- (void)audioView:(LBAudioView *)audioView volumeAddBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer addVolume];
    }
}
/** 音量- */
- (void)audioView:(LBAudioView *)audioView volumeSubBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer reduceVolume];
    }
}
/** 切换设备 */
- (void)audioView:(LBAudioView *)audioView switchDeviceBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
    [self.navigationController pushViewController:deviceListVC animated:YES];
}
/** 退出投屏 */
- (void)audioView:(LBAudioView *)audioView stopBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
        self.castState = LBAudioCastStateUnCastConnected;
    }else{
        self.castState = LBAudioCastStateUnCastUnConnect;
    }
}

#pragma mark - notification

- (void)didConnectedNotification:(NSNotification *)notification {
    if (self.castState == LBAudioCastStateCastedUnConnect) {
        self.castState = LBAudioCastStateCastedConnected;
        [self castAudio];
    }else if(self.castState == LBAudioCastStateCastedConnected){
        [self castAudio];
    }
}

- (void)disConnectedNotification:(NSNotification *)notification {
    if (self.castState == LBAudioCastStateCastedConnected) {
        self.castState = LBAudioCastStateUnCastUnConnect;
    }
}

- (void)playerStatusNotification:(NSNotification *)notification {
    NSNumber * status = notification.userInfo[@"playStatus"];
    [self.audioView updatePlayStatus:[status integerValue]];
    
    switch ([status integerValue]) {
        case LBLelinkPlayStatusError:
            break;
        case LBLelinkPlayStatusUnkown:
            break;
        case LBLelinkPlayStatusLoading:
            break;
        case LBLelinkPlayStatusPlaying:
            break;
        case LBLelinkPlayStatusPause:
            break;
        case LBLelinkPlayStatusStopped:
            break;
        case LBLelinkPlayStatusCommpleted:
            [self nextAudio];
            break;
        default:
            break;
    }
}

- (void)playerProgressNotification:(NSNotification *)notification {
    LBLelinkProgressInfo * progressInfo = notification.userInfo[@"progressInfo"];
    [self.audioView updatePlayProgress:progressInfo];
}

#pragma mark - private

- (void)castAudio {
    if (!(self.castState == LBAudioCastStateCastedConnected)) {
        return;
    }
    
    if ([[LBLelinkKitManager sharedManager].lelinkPlayer canPlayMedia:LBLelinkMediaTypePhotoOnline]) {
        LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
        
        if (self.type == LBAudioViewControllerTypeOnline) {
            // 投在线音乐
            item.mediaType = LBLelinkMediaTypeAudioOnline;
            item.mediaURLString = self.onlineAudioArr[self.onlineAudioIndex];
            [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
        }else{
            // 投本音乐
            item.mediaType = LBLelinkMediaTypeAudioLocal;
            item.mediaURLString = self.localAudiosUrlString[self.localAudioIndex];
            if ([[LBLelinkKitManager sharedManager].lelinkPlayer canPlayMedia:LBLelinkMediaTypeAudioLocal]) {
                [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
            }else{
                [UIAlertController showAlertWithTitle:@"温馨提示" message:@"当前连接不支持本地音乐推送" okHandler:^(UIAlertAction * _Nonnull action) {
                    self.castState = LBAudioCastStateUnCastConnected;
                }];
            }
        }
        
        
    }
}

/** 下一个 */
- (void)nextAudio {
    if (self.type == LBAudioViewControllerTypeOnline) {
        self.onlineAudioIndex++;
        if (self.onlineAudioIndex > self.onlineAudioArr.count - 1) {
            self.onlineAudioIndex = 0;
        }
    }else{
        self.localAudioIndex++;
        if (self.localAudioIndex > self.localAudiosUrlString.count - 1) {
            self.localAudioIndex = 0;
        }
    }
    
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [self castAudio];
    }
}

#pragma mark - UI
- (void)setUI {
    [self.view addSubview:self.audioView];
    
    [self.audioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        if (LBHasSafeArea) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {        
            make.bottom.equalTo(self.view);
        }
        make.trailing.equalTo(self.view);
    }];
}

#pragma mark - setter & getter

- (LBAudioView *)audioView{
    if (_audioView == nil) {
        _audioView = [[LBAudioView alloc] init];
        _audioView.delegate = self;
    }
    return _audioView;
}

- (NSArray *)onlineAudioArr {
    return @[
             @"http://music.163.com/song/media/outer/url?id=346576.mp3",
             @"http://music.163.com/song/media/outer/url?id=346075.mp3",
             @"http://music.163.com/song/media/outer/url?id=400162138.mp3",
             @"http://music.163.com/song/media/outer/url?id=347597.mp3",
             @"http://music.163.com/song/media/outer/url?id=347355.mp3"
             ];
}

- (NSArray *)localAudiosName {
    return @[
             @"audio001",
             @"audio002",
             @"audio003",
             @"audio004",
             @"audio005",
             @"audio006"
             ];
}

- (void)setCastState:(LBAudioCastState)castState {
    _castState = castState;
    if (castState == LBAudioCastStateCastedConnected) {
        [self.audioView swithToCastMode:YES];
    }else if (castState == LBAudioCastStateUnCastUnConnect || castState == LBAudioCastStateUnCastConnected){
        [self.audioView swithToCastMode:NO];
    }
}

@end
