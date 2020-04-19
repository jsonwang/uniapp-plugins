//
//  LBDeviceListViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/20.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBDeviceListViewController.h"
#import "LBDeviceListView.h"

#import "LBScanQRViewController.h"
#import "LBNotFindDeviceViewController.h"

@interface LBDeviceListViewController ()<LBDeviceListViewDelegate>

@property (nonatomic, strong) LBDeviceListView *deviceListView;

@end

@implementation LBDeviceListViewController

- (void)dealloc {
    
    [[LBLelinkKitManager sharedManager] reportSerivesListViewDisappear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        self.view.backgroundColor = [UIColor yellowColor];
    // Do any additional setup after loading the view.
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:LBLelinkKitManagerConnectionDidConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:LBLelinkKitManagerConnectionDisConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:LBLelinkKitManagerServiceDidChangeNotification object:nil];
    [[LBLelinkKitManager sharedManager] search];
    self.deviceListView.lelinkConnections = [LBLelinkKitManager sharedManager].lelinkConnections;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - notification

- (void)updateDeviceList:(NSNotification *)notification {
    
    [self.deviceListView updateUI];
    
    
}

- (void)connet;
{
      //当做所有发现设备
//    [LBLelinkKitManager sharedManager].lelinkConnections;
    
    LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
      item.mediaType = LBLelinkMediaTypeVideoOnline;
      item.mediaURLString = @"http://hpplay.cdn.cibn.cc/videos/01.mp4";
      /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
      [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
      [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
      /**
       点击设备，如果未连接，则建立连接，如果已连接，则断开连接
       */
      // 当前连接
      LBLelinkConnection * currentConnection = [LBLelinkKitManager sharedManager].currentConnection;
      // 选择的连接
      LBLelinkConnection * selectedConnection = [LBLelinkKitManager sharedManager].lelinkConnections[0];
      if (currentConnection == nil) {
          [LBLelinkKitManager sharedManager].currentConnection = selectedConnection;
          currentConnection = selectedConnection;
          [currentConnection connect];
      }else{
          if ([currentConnection isEqual:selectedConnection]) {
              if (currentConnection.isConnected) {
                  [currentConnection disConnect];
              } else {
                  [currentConnection connect];
              }
          } else {
              if (currentConnection.isConnected) {
                  [currentConnection disConnect];
              }
              [LBLelinkKitManager sharedManager].currentConnection = selectedConnection;
              currentConnection = selectedConnection;
              [currentConnection connect];
          }
      }
}

#pragma mark - action

// 刷新
- (void)refreshBtnClicked:(UIButton *)button {
    NSLog(@"refreshBtnClicked");
//    [[LBLelinkKitManager sharedManager] search];
    
    [self connet];
}

// 扫一扫
- (void)scanBtnClicked:(UIButton *)button {
    NSLog(@"scanBtnClicked");
    LBScanQRViewController * sacnVC = [[LBScanQRViewController alloc] init];
    [self.navigationController pushViewController:sacnVC animated:YES];
}

#pragma mark - LBDeviceListViewDelegate

- (void)deviceListView:(LBDeviceListView *)deviceListView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
      item.mediaType = LBLelinkMediaTypeVideoOnline;
      item.mediaURLString = @"http://hpplay.cdn.cibn.cc/videos/02.mp4";
      /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
      [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
      [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
    /**
     点击设备，如果未连接，则建立连接，如果已连接，则断开连接
     */
    // 当前连接
    LBLelinkConnection * currentConnection = [LBLelinkKitManager sharedManager].currentConnection;
    // 选择的连接
    LBLelinkConnection * selectedConnection = [LBLelinkKitManager sharedManager].lelinkConnections[indexPath.row];
    if (currentConnection == nil) {
        [LBLelinkKitManager sharedManager].currentConnection = selectedConnection;
        currentConnection = selectedConnection;
        [currentConnection connect];
    }else{
        if ([currentConnection isEqual:selectedConnection]) {
            if (currentConnection.isConnected) {
                [currentConnection disConnect];
            } else {
                [currentConnection connect];
            }
        } else {
            if (currentConnection.isConnected) {
                [currentConnection disConnect];
            }
            [LBLelinkKitManager sharedManager].currentConnection = selectedConnection;
            currentConnection = selectedConnection;
            [currentConnection connect];
        }
    }
}

- (void)deviceListView:(LBDeviceListView *)deviceListView helpBtnClicked:(UIButton *)button {
    LBNotFindDeviceViewController * notFindVC = [[LBNotFindDeviceViewController alloc] init];
    [self.navigationController pushViewController:notFindVC animated:YES];
}


#pragma mark - UI

- (void)setUI {
    self.title = @"投屏设备列表";
    [self navigationBarBtns];
    
    [self.view addSubview:self.deviceListView];
    
//    [self.deviceListView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(64);
//        make.leading.equalTo(self.view);
//        make.bottom.equalTo(self.view);
//        make.trailing.equalTo(self.view);
//    }];
}

-(void)navigationBarBtns{
    // 刷新
    UIButton * refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [refreshBtn setTitleColor:[UIColor colorWithRed:72.0 / 255.0 green:158.0 / 255.0 blue:248.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * refreshBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshBtn];
    // 扫一扫
//    UIButton * scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [scanBtn setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
//    [scanBtn addTarget:self action:@selector(scanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * scanBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:scanBtn];
    
    self.navigationItem.rightBarButtonItems = @[refreshBarButtonItem];
}

#pragma mark - setter & getter

- (LBDeviceListView *)deviceListView{
    if (_deviceListView == nil) {
        _deviceListView = [[LBDeviceListView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
        _deviceListView.delegate = self;
    }
    return _deviceListView;
}

@end
