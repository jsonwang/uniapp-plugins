//
//  LBVideoViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/20.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBVideoViewController.h"
#import "LBVideoPlayerView.h"

#import "LBDeviceListViewController.h"
#import "AppDelegate.h"
#import "UIAlertController+LBAlertController.h"
#import "UIButton+LBUIButton.h"

/**
 视频投屏状态

 - LBVideoCastStateUnCastUnConnect: 未点击投屏，未连接
 - LBVideoCastStateCastedUnConnect: 已点击投屏，未连接
 - LBVideoCastStateCastedConnected: 已点击投屏，已连接
 - LBVideoCastStateUnCastConnected: 未点击投屏（或者点击退出投屏），已连接
 */
typedef NS_ENUM(NSUInteger, LBVideoCastState) {
    LBVideoCastStateUnCastUnConnect,
    LBVideoCastStateCastedUnConnect,
    LBVideoCastStateCastedConnected,
    LBVideoCastStateUnCastConnected,
};

NSString * const kLBOnlineVideoIndex = @"kLBOnlineVideoIndex";
NSString * const kLBLocalVideoIndex = @"kLBLocalVideoIndex";

@interface LBVideoViewController ()<LBVideoPlayerViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIButton *backBtn;

/** 在线剧集视频数组 */
@property (nonatomic, strong) NSArray *videos;
/** 在线剧集索引 */
@property (nonatomic, assign) NSInteger onlineVideoIndex;

/** 在线单集视频URL */
@property (nonatomic, copy) NSString *singleVideo;

/** 本地视频名称 */
@property (nonatomic, strong) NSArray *localVideosName;
/** 本地视频在本地webServer的url */
@property (nonatomic, strong) NSArray *localVideosUrlString;
/** 本地视频索引 */
@property (nonatomic, assign) NSInteger localVideoIndex;

/** 播放器View */
@property (nonatomic, strong) LBVideoPlayerView *videoPlayerView;
/** 选集按钮 */
@property (nonatomic, strong) NSArray *indexBtnArr;
/** 弹幕开关 */
@property (nonatomic, strong) UISwitch *barrageSwitch;
@property (nonatomic, strong) UILabel *swithLabel;
/** 发送弹幕按钮 */
@property (nonatomic, strong) UIButton *sendBarrageBtn;
/** 弹幕输入文本框 */
@property (nonatomic, strong) UITextField *barrageInputTextField;
/** 弹幕定时器，用于定时发送弹幕，模拟测试弹幕发送 */
@property (nonatomic, strong) NSTimer *barrageTimer;

@property (nonatomic, assign) LBVideoCastState castState;



@end

@implementation LBVideoViewController

- (void)dealloc {
    // 保存当前在线视频剧集索引
    if (self.type == LBVideoViewControllerOnlineSerial ) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.onlineVideoIndex] forKey:kLBOnlineVideoIndex];
    }else if (self.type == LBVideoViewControllerLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.onlineVideoIndex] forKey:kLBLocalVideoIndex];
    }
    
    // 移除通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 销毁定时器
    if (self.barrageTimer) {
        [self.barrageTimer invalidate];
        self.barrageTimer = nil;
    }
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
        self.castState = LBVideoCastStateUnCastConnected;
    }else{
        self.castState = LBVideoCastStateUnCastUnConnect;
    }
    
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disConnectedNotification:) name:LBLelinkKitManagerConnectionDisConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidConnected:) name:LBLelinkKitManagerConnectionDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerErrorNotification:) name:LBLelinkKitManagerPlayerErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusNotification:) name:LBLelinkKitManagerPlayerStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerProgressNotification:) name:LBLelinkKitManagerPlayerProgressNotification object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    // 销毁定时器
//    if (self.barrageTimer) {
//        [self.barrageTimer invalidate];
//        self.barrageTimer = nil;
//    }
    // 如果弹幕开关打开，则关闭弹幕开关
    if (self.barrageSwitch.isOn) {
        self.barrageSwitch.on = NO;
        [self.barrageSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setPrepare {
    // 配置本地视频相关
    if (self.type == LBVideoViewControllerLocal) {
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // 启动本地服务器
        [appDelegate.localWebServer startGCDWebServer];
        // 将本地文件拷贝到沙盒
        [appDelegate.localWebServer copyFilesToDocument:self.localVideosName type:@"mp4"];
        // 获取本地文件的url
        self.localVideosUrlString = [appDelegate.localWebServer getLocalUrlsWithFileNames:self.localVideosName type:@"mp4"];
        NSLog(@"%@",self.localVideosUrlString);
        
        NSNumber * indexNum = [[NSUserDefaults standardUserDefaults] objectForKey:kLBLocalVideoIndex];
        if (indexNum) {
            self.localVideoIndex = [indexNum integerValue];
        }
        
    }else if (self.type == LBVideoViewControllerOnlineSerial){
        NSNumber * indexNum = [[NSUserDefaults standardUserDefaults] objectForKey:kLBOnlineVideoIndex];
        if (indexNum) {
            self.onlineVideoIndex = [indexNum integerValue];
        }
    }
}

#pragma mark - notification

- (void)disConnectedNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    if (self.castState == LBVideoCastStateCastedConnected) {
        self.castState = LBVideoCastStateUnCastUnConnect;
    }
}

- (void)connectionDidConnected:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    
    if (self.castState == LBVideoCastStateCastedUnConnect) {
        self.castState = LBVideoCastStateCastedConnected;
        [self castVideo];
    }else if(self.castState == LBVideoCastStateCastedConnected){
        [self castVideo];
    }else if (self.castState == LBVideoCastStateUnCastUnConnect){
        self.castState = LBVideoCastStateCastedConnected;
        [self castVideo];
    }
}

- (void)playerErrorNotification:(NSNotification *)notification {
    NSLog(@"playerErrorNotification");
}

- (void)playerStatusNotification:(NSNotification *)notification {
    NSNumber * status = notification.userInfo[@"playStatus"];
    [self.videoPlayerView updatePlayStatus:[status integerValue]];
    
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
            if (self.type == LBVideoViewControllerOnlineSerial || self.type == LBVideoViewControllerLocal) {
                [self autoNext];
            }
            break;
        default:
            break;
    }
}

- (void)playerProgressNotification:(NSNotification *)notification {
    LBLelinkProgressInfo * progressInfo = notification.userInfo[@"progressInfo"];
    [self.videoPlayerView updatePlayProgress:progressInfo];
}

#pragma mark - LBVideoPlayerViewDelegate播放器视图控件点击事件
/** 播放器右上角TV按钮点击 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView castToTVBtnClicked:(UIButton *)button {
    
    if (self.castState == LBVideoCastStateUnCastUnConnect) {
        // 调出设备列表
        LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
        [self.navigationController pushViewController:deviceListVC animated:YES];
        self.castState = LBVideoCastStateCastedUnConnect;
    }else if (self.castState == LBVideoCastStateUnCastConnected) {
        // 直接投
        self.castState = LBVideoCastStateCastedConnected;
        [self castVideo];
    }
}
/** 播放器视图暂停或播放按钮点击 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView pauseOrResumeBtnClicked:(UIButton *)button {
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
/** 播放器视图进度条拖动 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView progressSliderClicked:(UISlider *)slider {
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        NSInteger value = (NSInteger)slider.value;
        [[LBLelinkKitManager sharedManager].lelinkPlayer seekTo:value];
    }
}
/** 播放器视图切换设备点击 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView switchDeviceBtnClicked:(UIButton *)button {
    LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
    [self.navigationController pushViewController:deviceListVC animated:YES];
}
/** 播放器视图退出播放点击 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView stopBtnClicked:(UIButton *)button {
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
        self.castState = LBVideoCastStateUnCastConnected;
    }else{
        self.castState = LBVideoCastStateUnCastUnConnect;
    }
}
/** 播放器视图音量+点击 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView volumeAddBtnClicked:(UIButton *)button {
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer addVolume];
    }
}
/** 播放器视图音量-点击 */
- (void)videoPlayerView:(LBVideoPlayerView *)videoPlayerView volumeSubBtnClicked:(UIButton *)button {
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer reduceVolume];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%s", __func__);
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - action

- (void)indexBtnClicked:(UIButton *)btn {
    for (UIButton * button in self.indexBtnArr) {
        if ([btn isEqual:button]) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
    if (self.type == LBVideoViewControllerLocal) {
        self.localVideoIndex = btn.tag;
    }else if (self.type == LBVideoViewControllerOnlineSerial) {
        self.onlineVideoIndex = btn.tag;
    }
    
    // 推送媒体
    if (self.castState == LBVideoCastStateCastedConnected) {
        LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
        if (self.type == LBVideoViewControllerLocal) {
            item.mediaType = LBLelinkMediaTypeVideoLocal;
            item.mediaURLString = self.localVideosUrlString[btn.tag];
            if ([[LBLelinkKitManager sharedManager].lelinkPlayer canPlayMedia:LBLelinkMediaTypeVideoLocal]) {
                /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
                [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
                [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
            }else{
                [UIAlertController showAlertWithTitle:@"温馨提示" message:@"当前连接不支持本地视频播放" okHandler:^(UIAlertAction * _Nonnull action) {
                    self.castState = LBVideoCastStateUnCastConnected;
                }];
            }
        }else if (self.type == LBVideoViewControllerOnlineSerial) {
            item.mediaType = LBLelinkMediaTypeVideoOnline;
            item.mediaURLString = self.videos[btn.tag];
            /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
            [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
            [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
        }
    }else if (self.castState == LBVideoCastStateCastedUnConnect) {
        [UIAlertController showAlertWithTitle:@"温馨提示" message:@"当前连接已断开，请重新连接" okHandler:^(UIAlertAction * _Nonnull action) {
            LBDeviceListViewController * deviceVC = [[LBDeviceListViewController alloc] init];
            [self.navigationController pushViewController:deviceVC animated:YES];
        } cancelHandler:nil];
    }
}

/** 发送按钮点击，发送单个弹幕 */
- (void)sendBarrageBtnClicked:(UIButton *)button {
    NSLog(@"%s", __func__);
    if (!self.barrageInputTextField.text.length) {
        return;
    }
    
    // 判断当前连接是否能推送弹幕
    if (![[LBLelinkKitManager sharedManager].lelinkPlayer canCurrentPushBarrage]) {
        return;
    }
    
    // 创建并设置弹幕
    LBLelinkTextBarrage * textBarrage = [[LBLelinkTextBarrage alloc] init];
    textBarrage.textColor = [UIColor redColor];
    textBarrage.fontSize = 40;
    textBarrage.text = self.barrageInputTextField.text;
    
    // 发送弹幕
    [[LBLelinkKitManager sharedManager].lelinkPlayer pushPriorityBarrage:textBarrage];
    
    // 清空文本框，收起键盘
    self.barrageInputTextField.text = @"";
    [self.view endEditing:YES];
}

/** 弹幕开关按钮点击，显示和隐藏弹幕 */
- (void)barrageSwitchBtnClicked:(UISwitch *)switchBtn {
    self.barrageInputTextField.hidden = !switchBtn.isOn;
    self.sendBarrageBtn.hidden = !switchBtn.isOn;
    
    // 打开和关闭弹幕
    [LBLelinkKitManager sharedManager].lelinkPlayer.hideBarrage = !switchBtn.isOn;
    
    // 打开和关闭随机发送弹幕
    [self castBarrageRandomly:switchBtn.isOn];
}

#pragma mark - private

- (void)castVideo {
    switch (self.type) {
        case LBVideoViewControllerLocal:
        case LBVideoViewControllerOnlineSerial: {
            [self castSerial];
        }
            break;
        case LBVideoViewControllerOnlineSingle: {
            [self castSingleOnline];
        }
            break;
    }
}

- (void)castSingleOnline {
    LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
    item.mediaType = LBLelinkMediaTypeVideoOnline;
    item.mediaURLString = self.singleVideo;
    /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
    [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
    [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
}

- (void)castSerial {
    BOOL sendAction = NO;
    for (UIButton *btn in self.indexBtnArr) {
        if (btn.isSelected) {
            [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            sendAction = YES;
            break;
        }
    }
    if (!sendAction) {
        UIButton * btn = [self.indexBtnArr firstObject];
        [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

/** 自动选择下一集按钮 */
- (void)autoNext {
    for (NSInteger i = 0; i < self.videos.count; i++) {
        UIButton * btn = self.indexBtnArr[i];
        
        if (btn.selected) {
            UIButton * nextBtn;
            if (i == self.videos.count - 1) {
                nextBtn = [self.indexBtnArr firstObject];
            }
            else {
                nextBtn = self.indexBtnArr[(i + 1)];
            }
            [nextBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (void)castBarrageRandomly:(BOOL)isOn {
    if (isOn) {
        if (self.barrageTimer == nil) {
            self.barrageTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(sendBarrageRandomly) userInfo:nil repeats:YES];
            [self.barrageTimer fire];
        }
    }
    else {
        if (self.barrageTimer != nil) {
            [self.barrageTimer invalidate];
            self.barrageTimer = nil;
        }
    }
}

- (void)sendBarrageRandomly {
    NSArray * testArr = @[@"乐播投屏果然好用",@"天，原来投屏还能带弹幕",@"乐播投屏，万屏互联",@"云投屏打破了网络界限",@"厉害了，以后在家就能投屏看视频了",@"你们没有发现之前投屏没弹幕吗，赞！",@"乐播投屏，投你所投",@"以后手机给儿子玩，也能看手机视频了？！",@"舔屏ing",@"投屏也能这么清晰？啥软件？",@"感觉比其他家的好用多了！",@"段子手在哪？把广告刷下去！"];
    NSUInteger count = testArr.count;
    
    // 每次发送弹幕的条数随机，0-5
    int numberOfBarrage = arc4random() % 5;
    
    NSMutableArray * barrages = [NSMutableArray array];
    for (int i = 0; i < numberOfBarrage; i++) {
        // 每条弹幕从给定的数组testArr中随机取
        int indexOfBarrage = arc4random() % count;
        LBLelinkTextBarrage * barrage = [[LBLelinkTextBarrage alloc] init];
        barrage.text = testArr[indexOfBarrage];
        barrage.textColor = [UIColor greenColor];
        barrage.fontSize = 30;
        
        [barrages addObject:barrage];
    }
    
    if (!barrages.count) {
        return;
    }
    
    if (![LBLelinkKitManager sharedManager].lelinkPlayer.canCurrentPushBarrage) {
        return;
    }
    
    // 弹幕设置
    [LBLelinkKitManager sharedManager].lelinkPlayer.barrageMaxLine = 5;
    
    // 发送弹幕数组
    [[LBLelinkKitManager sharedManager].lelinkPlayer pushBarrageAry:barrages];
}

#pragma mark - UI
- (void)setUI {
    [self.view addSubview:self.videoPlayerView];
    [self.view addSubview:self.backBtn];
    
    [self.videoPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@([UIScreen mainScreen].bounds.size.width * 9 / 16));
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (LBHasSafeArea) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.top.equalTo(self.view).offset(20);
        }
        make.leading.equalTo(self.view).offset(8);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    // 剧集按钮布局
    if (self.type == LBVideoViewControllerOnlineSerial || self.type == LBVideoViewControllerLocal) {
        NSMutableArray * tempArr = [NSMutableArray array];
        
        NSUInteger count = 0;
        if (self.type == LBVideoViewControllerOnlineSerial) {
            count = self.videos.count;
        }else{
            count = self.localVideosUrlString.count;
        }
        for (NSUInteger i = 0; i < count; i++) {
            UIButton * indexBtn = [[UIButton alloc] init];
            indexBtn.tag = i;
            indexBtn.backgroundColor = [UIColor grayColor];
            [indexBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [indexBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [indexBtn setTitle:[NSString stringWithFormat:@"%lu", i + 1] forState:UIControlStateNormal];
            [indexBtn addTarget:self action:@selector(indexBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:indexBtn];
            
            [indexBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.videoPlayerView.mas_bottom).offset(20);
                make.leading.equalTo(self.videoPlayerView).offset(i * 44 + 20 + i * 10);
                make.size.mas_equalTo(CGSizeMake(44, 44));
            }];
            [tempArr addObject:indexBtn];
            
            if (self.type == LBVideoViewControllerLocal) {
                if (i == self.localVideoIndex) {
                    indexBtn.selected = YES;
                }
            }else if (self.type == LBVideoViewControllerOnlineSerial) {
                if (i == self.onlineVideoIndex) {
                    indexBtn.selected = YES;
                }
            }
        }
        self.indexBtnArr = tempArr.copy;
    }
    
    UIView * temp = nil;
    
    if (self.indexBtnArr.count > 0) {
        temp = [self.indexBtnArr lastObject];
    } else {
        temp = self.videoPlayerView;
    }
    
    [self.view addSubview:self.barrageInputTextField];
    [self.view addSubview:self.sendBarrageBtn];
    [self.view addSubview:self.barrageSwitch];
    [self.view addSubview:self.swithLabel];
    
    [self.barrageInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(temp.mas_bottom).offset(20);
        make.leading.equalTo(self.view).offset(20);
        make.height.equalTo(@34);
    }];
    [self.barrageSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-20);
        make.top.equalTo(self.barrageInputTextField);
        make.width.equalTo(@40);
        make.height.equalTo(@34);
    }];
    [self.swithLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.barrageSwitch.mas_bottom).offset(5);
        make.centerX.equalTo(self.barrageSwitch);
    }];
    [self.sendBarrageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.barrageSwitch.mas_leading).offset(-10);
        make.top.equalTo(self.barrageInputTextField);
        make.width.equalTo(@60);
        make.leading.equalTo(self.barrageInputTextField.mas_trailing).offset(10);
        make.height.equalTo(@34);
    }];
    
}

#pragma mark - setter & getter

- (void)setCastState:(LBVideoCastState)castState {
    _castState = castState;
    if (castState == LBVideoCastStateCastedConnected) {
        [self.videoPlayerView swithToCastMode:YES];
        [self.videoPlayerView setServiceName:[LBLelinkKitManager sharedManager].currentConnection.lelinkService.lelinkServiceName];
        
        BOOL supportBarrage = [[LBLelinkKitManager sharedManager].lelinkPlayer canSupportPushBarrage];
        self.barrageSwitch.hidden = !supportBarrage;
        self.swithLabel.hidden = !supportBarrage;
        
    }else if (castState == LBVideoCastStateUnCastUnConnect || castState == LBVideoCastStateUnCastConnected){
        [self.videoPlayerView swithToCastMode:NO];
        if (self.barrageSwitch.isOn) {
            self.barrageSwitch.on = NO;
            [self.barrageSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        }
        self.barrageSwitch.hidden = YES;
        self.swithLabel.hidden = YES;
    }
}

- (UIButton *)backBtn{
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setImage:[UIImage imageNamed:@"backbutton_white_link"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (NSArray *)videos{
    if (_videos == nil) {
        _videos = @[
                    @"http://hpplay.cdn.cibn.cc/videos/01.mp4",
                    @"http://hpplay.cdn.cibn.cc/videos/02.mp4",
                    @"http://hpplay.cdn.cibn.cc/videos/03.mp4"
                    ];
    }
    return _videos;
}

- (NSString *)singleVideo {
    return @"http://hpplay.cdn.cibn.cc/videos/01.mp4";//@"http://hpplay.cdn.cibn.cc/videos/03.mp4";
}

- (NSArray *)localVideosName {
    return @[
             @"video001",
             @"video002",
             @"video003",
             @"video004"
             ];
}

- (LBVideoPlayerView *)videoPlayerView{
    if (_videoPlayerView == nil) {
        _videoPlayerView = [[LBVideoPlayerView alloc] init];
        _videoPlayerView.delegate = self;
    }
    return _videoPlayerView;
}

- (UIButton *)sendBarrageBtn{
    if (_sendBarrageBtn == nil) {
        _sendBarrageBtn = [UIButton buttonWithTitle:@"发送" target:self action:@selector(sendBarrageBtnClicked:)];
        _sendBarrageBtn.hidden = YES;
    }
    return _sendBarrageBtn;
}

- (UITextField *)barrageInputTextField{
    if (_barrageInputTextField == nil) {
        _barrageInputTextField = [[UITextField alloc] init];
        _barrageInputTextField.borderStyle = UITextBorderStyleRoundedRect;
        _barrageInputTextField.delegate = self;
        _barrageInputTextField.placeholder = @"发一条弹幕吧";
        _barrageInputTextField.backgroundColor = [UIColor grayColor];
        _barrageInputTextField.hidden = YES;
    }
    return _barrageInputTextField;
}

- (UISwitch *)barrageSwitch{
    if (_barrageSwitch == nil) {
        _barrageSwitch = [[UISwitch alloc] init];
        [_barrageSwitch addTarget:self action:@selector(barrageSwitchBtnClicked:) forControlEvents:UIControlEventValueChanged];
        _barrageSwitch.hidden = YES;
    }
    return _barrageSwitch;
}

- (UILabel *)swithLabel{
    if (_swithLabel == nil) {
        _swithLabel = [[UILabel alloc] init];
        _swithLabel.textColor = [UIColor darkGrayColor];
        _swithLabel.text = @"弹幕开关";
        _swithLabel.font = [UIFont systemFontOfSize:12];
        _swithLabel.hidden = YES;
    }
    return _swithLabel;
}

@end
