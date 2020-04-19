//
//  LBPhotoViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/20.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBPhotoViewController.h"
#import "LBPhotoView.h"

#import "LBDeviceListViewController.h"
#import "UIAlertController+LBAlertController.h"

/**
 投屏状态

 - LBPhotoCastStateUnStart: 未点击投屏，未连接
 - LBPhotoCastStateStarting: 已点击投屏，未连接
 - LBPhotoCastStateStarted: 已点击投屏，已连接
 - LBPhotoCastStateEnded: 未点击投屏（或者点击退出投屏），已连接
 */
typedef NS_ENUM(NSUInteger, LBPhotoCastState) {
    LBPhotoCastStateUnCastUnConnect,
    LBPhotoCastStateCastedUnConnect,
    LBPhotoCastStateCastedConnected,
    LBPhotoCastStateUnCastConnected,
};

NSString * const kLBPhotoIndex = @"kLBPhotoIndex";

@interface LBPhotoViewController ()<LBPhotoViewDelegate>

/** 图片视图 */
@property (nonatomic, strong) LBPhotoView *photoView;
/** 图片url地址数组 */
@property (nonatomic, strong) NSArray *onlinePhotoArr;
/** 图片索引 */
@property (nonatomic, assign) NSInteger photoIndex;

/** 投屏状态 */
@property (nonatomic, assign) LBPhotoCastState castState;

@end

@implementation LBPhotoViewController

- (void)dealloc {
    // 退出投照片
    if (self.castState == LBPhotoCastStateCastedConnected) {
        if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
            [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
        }
    }
    
    // 保存当前图片索引
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.photoIndex] forKey:kLBPhotoIndex];
    
    // 移除通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置UI
    [self setUI];
    
    // 获取图片索引，并设置当前图片
    NSNumber * indexNum = [[NSUserDefaults standardUserDefaults] objectForKey:kLBPhotoIndex];
    if (indexNum) {
        self.photoIndex = [indexNum integerValue];
    }
    [self.photoView setPhotoImageViewWithUrlString:self.onlinePhotoArr[self.photoIndex]];
    
    // 设置投屏状态
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        self.castState = LBPhotoCastStateUnCastConnected;
    }else{
        self.castState = LBPhotoCastStateUnCastUnConnect;
    }
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectedNotification:) name:LBLelinkKitManagerConnectionDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disConnectedNotification:) name:LBLelinkKitManagerConnectionDisConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatusNotification:) name:LBLelinkKitManagerPlayerStatusNotification object:nil];
}

#pragma mark - LBPhotoViewDelegate
/** 投屏 */
- (void)photoView:(LBPhotoView *)photoView castBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if (self.castState == LBPhotoCastStateUnCastUnConnect) {
        // 调出设备列表
        LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
        [self.navigationController pushViewController:deviceListVC animated:YES];
        self.castState = LBPhotoCastStateCastedUnConnect;
    }else if (self.castState == LBPhotoCastStateUnCastConnected) {
        // 直接投
        self.castState = LBPhotoCastStateCastedConnected;
        [self castPhoto];
    }
}
/** 上一张 */
- (void)photoView:(LBPhotoView *)photoView previousBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    self.photoIndex--;
    if (self.photoIndex < 0) {
        self.photoIndex = self.onlinePhotoArr.count - 1;
    }
    [photoView setPhotoImageViewWithUrlString:self.onlinePhotoArr[self.photoIndex]];
    
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [self castPhoto];
    }
}
/** 下一张 */
- (void)photoView:(LBPhotoView *)photoView nextBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    self.photoIndex++;
    if (self.photoIndex > self.onlinePhotoArr.count - 1) {
        self.photoIndex = 0;
    }
    [photoView setPhotoImageViewWithUrlString:self.onlinePhotoArr[self.photoIndex]];
    
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [self castPhoto];
    }
}
/** 切换设备 */
- (void)photoView:(LBPhotoView *)photoView switchDeviceBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
    [self.navigationController pushViewController:deviceListVC animated:YES];
}
/** 退出投屏 */
- (void)photoView:(LBPhotoView *)photoView stopBtnClicked:(UIButton *)button {
    NSLog(@"%s",__func__);
    if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
        self.castState = LBPhotoCastStateUnCastConnected;
    }else{
        self.castState = LBPhotoCastStateUnCastUnConnect;
    }
}

#pragma mark - notification

- (void)didConnectedNotification:(NSNotification *)notification {
    if (self.castState == LBPhotoCastStateCastedUnConnect) {
        self.castState = LBPhotoCastStateCastedConnected;
        [self castPhoto];
    }else if(self.castState == LBPhotoCastStateCastedConnected){
        [self castPhoto];
    }
}

- (void)disConnectedNotification:(NSNotification *)notification {
    if (self.castState == LBPhotoCastStateCastedConnected) {
        self.castState = LBPhotoCastStateUnCastUnConnect;
    }
}

- (void)playerStatusNotification:(NSNotification *)notification {
    NSNumber * status = notification.userInfo[@"playStatus"];
    if ([status integerValue] == LBLelinkPlayStatusCommpleted) {
        // 接收端按遥控器退出照片投屏时，会有此状态回调
        // 切换到退出投屏状态
        self.castState = LBPhotoCastStateUnCastConnected;
    }
    
}

#pragma mark - private

- (void)castPhoto {
    if (!(self.castState == LBPhotoCastStateCastedConnected)) {
        return;
    }
    
    if ([[LBLelinkKitManager sharedManager].lelinkPlayer canPlayMedia:LBLelinkMediaTypePhotoOnline]) {
        LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
        
        if (self.type == LBPhotoViewControllerTypeOnline) {
            // 投在线图片，直接设置图片的url
            item.mediaType = LBLelinkMediaTypePhotoOnline;
            item.mediaURLString = self.onlinePhotoArr[self.photoIndex];
            [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
        }else{
            // 投本地图片，则设置图片的data
            item.mediaType = LBLelinkMediaTypePhotoLocal;
            item.mediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.onlinePhotoArr[self.photoIndex]]];
            if ([[LBLelinkKitManager sharedManager].lelinkPlayer canPlayMedia:LBLelinkMediaTypePhotoLocal]) {
                [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
            }else{
                [UIAlertController showAlertWithTitle:@"温馨提示" message:@"当前连接不支持推送本地图片" okHandler:^(UIAlertAction * _Nonnull action) {
                    self.castState = LBPhotoCastStateUnCastConnected;
                }];
            }
        }
        
    }
}

#pragma mark - UI

- (void)setUI {
    [self.view addSubview:self.photoView];
    
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        if (LBHasSafeArea) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
}

#pragma mark - setter & getter

- (LBPhotoView *)photoView{
    if (_photoView == nil) {
        _photoView = [[LBPhotoView alloc] init];
        _photoView.delegate = self;
    }
    return _photoView;
}

- (NSArray *)onlinePhotoArr {
    return @[
             @"http://a.hiphotos.baidu.com/image/pic/item/adaf2edda3cc7cd90df1ede83401213fb80e9127.jpg",
             @"http://c.hiphotos.baidu.com/image/pic/item/8694a4c27d1ed21b3c778fdda06eddc451da3f4f.jpg",
             @"http://e.hiphotos.baidu.com/image/pic/item/8c1001e93901213f5480ffe659e736d12f2e955d.jpg",
             @"http://g.hiphotos.baidu.com/image/pic/item/dcc451da81cb39db18994d6add160924ab1830b4.jpg",
             @"http://d.hiphotos.baidu.com/image/pic/item/ae51f3deb48f8c54efdafb1c37292df5e0fe7ff3.jpg",
             @"http://h.hiphotos.baidu.com/image/pic/item/8601a18b87d6277f61470d0a25381f30e924fcaf.jpg",
             @"http://f.hiphotos.baidu.com/image/pic/item/dcc451da81cb39db0b164262dd160924ab18302b.jpg",
             @"http://d.hiphotos.baidu.com/image/pic/item/d1a20cf431adcbef9518c83aa1af2edda3cc9fda.jpg",
             @"http://e.hiphotos.baidu.com/image/pic/item/11385343fbf2b21147303372c78065380cd78ef4.jpg"
             ];
}

- (void)setCastState:(LBPhotoCastState)castState {
    _castState = castState;
    if (castState == LBPhotoCastStateCastedConnected) {
        [self.photoView swithToCastMode:YES];
    }else if (castState == LBPhotoCastStateUnCastUnConnect || castState == LBPhotoCastStateUnCastConnected){
        [self.photoView swithToCastMode:NO];
    }
}


@end
