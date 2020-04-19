//
//  LBHomeViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/14.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBHomeViewController.h"
#import "LBHomeBaseView.h"

#import "LBDeviceListViewController.h"
#import "LBVideoViewController.h"
#import "LBAudioViewController.h"
#import "LBPhotoViewController.h"
#import "LBNotFindDeviceViewController.h"

@interface LBHomeViewController ()<LBHomeBaseViewDelegate>

@property (nonatomic, strong) LBHomeBaseView *baseView;

@end

@implementation LBHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"投屏SDK Sample";
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - LBHomeBaseViewDelegate
// 投屏设备列表
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView deviceLisetBtnClicked:(UIButton *)button {
    NSLog(@"deviceLisetBtnClicked %@",button.titleLabel.text);
    
    LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
    [self.navigationController pushViewController:deviceListVC animated:YES];
}

// 投屏幕
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castScreenBtnClicked:(UIButton *)button {
    NSLog(@"castScreenBtnClicked %@",button.titleLabel.text);
    
    NSString * systemVersion = [UIDevice currentDevice].systemVersion;
    if ([systemVersion doubleValue] >= 11.0) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"iOS 11.0以上系统需要从系统控制中心打开屏幕镜像。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        
        if ([UIScreen screens].count > 1) {
            // 正在镜像中
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在屏幕镜像中，是否关闭？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [LBLelinkCast stopCastComplete:^(NSError *error) {
                    if (error) {
                        NSLog(@"关闭失败");
                    }
                }];
            }];
            [alertController addAction:okAction];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancel];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        if ([LBLelinkKitManager sharedManager].currentConnection.isConnected) {
            if (![[LBLelinkKitManager sharedManager].lelinkPlayer canPlayMedia:LBLelinkMediaTypePhotoLocal]) {
                NSLog(@"当前连接不支持投屏幕");
                return;
            }
            [LBLelinkCast castToLelinkService:[LBLelinkKitManager sharedManager].currentConnection.lelinkService complete:^(NSError *error) {
                if (error) {
                    NSLog(@"投屏幕失败");
                }else{
                    NSLog(@"投屏幕成功");
                }
            }];
        }else{
            LBDeviceListViewController * deviceListVC = [[LBDeviceListViewController alloc] init];
            [self.navigationController pushViewController:deviceListVC animated:YES];
        }
    }
}

// 在线单集
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castOnlineVideoSingleBtnClicked:(UIButton *)button {
    NSLog(@"castOnlineVideoSingleBtnClicked %@",button.titleLabel.text);
    LBVideoViewController * videoVC = [[LBVideoViewController alloc] init];
    videoVC.type = LBVideoViewControllerOnlineSingle;
    videoVC.title = button.titleLabel.text;
    [self.navigationController pushViewController:videoVC animated:YES];
}

// 在线剧集
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castOnlineVideoSerialBtnClicked:(UIButton *)button {
    NSLog(@"castOnlineVideoSerialBtnClicked %@",button.titleLabel.text);
    LBVideoViewController * videoVC = [[LBVideoViewController alloc] init];
    videoVC.type = LBVideoViewControllerOnlineSerial;
    videoVC.title = button.titleLabel.text;
    [self.navigationController pushViewController:videoVC animated:YES];
}

// 在线音频
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castOnlineAudioBtnClicked:(UIButton *)button {
    NSLog(@"castOnlineAudioBtnClicked %@",button.titleLabel.text);
    LBAudioViewController * audioVC = [[LBAudioViewController alloc] init];
    audioVC.title = button.titleLabel.text;
    audioVC.type = LBAudioViewControllerTypeOnline;
    [self.navigationController pushViewController:audioVC animated:YES];
}

// 在线图片
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castOnlinePhotoBtnClicked:(UIButton *)button {
    NSLog(@"castOnlinePhotoBtnClicked %@",button.titleLabel.text);
    LBPhotoViewController * photoVC = [[LBPhotoViewController alloc] init];
    photoVC.title = button.titleLabel.text;
    photoVC.type = LBPhotoViewControllerTypeOnline;
    [self.navigationController pushViewController:photoVC animated:YES];
}

// 本地视频
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castLocalVideoBtnClicked:(UIButton *)button {
    NSLog(@"castLocalVideoBtnClicked %@",button.titleLabel.text);
    LBVideoViewController * videoVC = [[LBVideoViewController alloc] init];
    videoVC.type = LBVideoViewControllerLocal;
    videoVC.title = button.titleLabel.text;
    [self.navigationController pushViewController:videoVC animated:YES];
}

// 本地音频
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castLocalAudioBtnClicked:(UIButton *)button {
    NSLog(@"castLocalAudioBtnClicked %@",button.titleLabel.text);
    LBAudioViewController * audioVC = [[LBAudioViewController alloc] init];
    audioVC.title = button.titleLabel.text;
    audioVC.type = LBAudioViewControllerTypeLocal;
    [self.navigationController pushViewController:audioVC animated:YES];
}

// 本地图片
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView castLocalPhotoBtnClicked:(UIButton *)button {
    NSLog(@"castLocalPhotoBtnClicked %@",button.titleLabel.text);
    LBPhotoViewController * photoVC = [[LBPhotoViewController alloc] init];
    photoVC.title = button.titleLabel.text;
    photoVC.type = LBPhotoViewControllerTypeLocal;
    [self.navigationController pushViewController:photoVC animated:YES];
}

// 投屏功能介绍
- (void)homeBaseView:(LBHomeBaseView *)homeBaseView introduceBtnClicked:(UIButton *)button {
    NSLog(@"introduceBtnClicked %@",button.titleLabel.text);
    LBNotFindDeviceViewController * notFindVC = [[LBNotFindDeviceViewController alloc] init];
    [self.navigationController pushViewController:notFindVC animated:YES];
}


#pragma mark - UI

- (void)setUI {
    [self.view addSubview:self.baseView];
    
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - setter & getter

- (LBHomeBaseView *)baseView{
    if (_baseView == nil) {
        _baseView = [[LBHomeBaseView alloc] init];
        _baseView.delegate = self;
    }
    return _baseView;
}

@end
