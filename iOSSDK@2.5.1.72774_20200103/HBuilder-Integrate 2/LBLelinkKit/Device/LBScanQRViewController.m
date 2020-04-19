//
//  LBScanQRViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/22.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBScanQRViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "UIAlertController+LBAlertController.h"

@interface LBScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, strong) UILabel *tipLabel01;
@property (nonatomic, strong) UILabel *tipLabel02;

@property (nonatomic, assign) BOOL isGetQRCodeStringValue;
@end

@implementation LBScanQRViewController

- (void)dealloc {
    [self stopScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫码发现设备";
    [self.view addSubview:self.tipLabel01];
    [self.view addSubview:self.tipLabel02];
    
    [self.tipLabel01 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    [self.tipLabel02 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tipLabel01.mas_bottom).offset(5);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopScan];
}

- (void)stopScan{
    [self.session stopRunning];
    self.session = nil;
}

- (void)startScan {
    //    iOS 判断应用是否有使用相机的权限
    
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [UIAlertController showAlertWithTitle:@"温馨提示" message:@"应用相机权限受限,请在设置中启用" okHandler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
            
        } cancelHandler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        } ];
        return;
    }
    

    // 设置
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *errror = nil;
    [self.device lockForConfiguration:&errror];
    if (errror == nil) {
        
        if (self.device.smoothAutoFocusSupported && (self.device.smoothAutoFocusEnabled == NO)) {
            self.device.smoothAutoFocusEnabled = YES;
            NSLog(@"确定启用平滑自动对焦。");
        }
        if ([self.device isAutoFocusRangeRestrictionSupported]) {
            self.device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionFar;
        }
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && (self.device.focusMode != AVCaptureFocusModeContinuousAutoFocus)) {
            self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            NSLog(@"确定设备的对焦模式--%ld",self.device.focusMode);
        }
        NSLog(@"autoFocusRangeRestrictionSupported:%d,---autoFocusRangeRestriction:%ld",self.device.autoFocusRangeRestrictionSupported,self.device.autoFocusRangeRestriction);
        if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [self.device unlockForConfiguration];
    }
    NSLog(@"是否启用平滑自动对焦smoothAutoFocusEnabled:%d,对焦模式focusMode:%ld,自动对焦范围值autoFocusRangeRestriction:%ld",self.device.smoothAutoFocusEnabled,self.device.focusMode,self.device.autoFocusRangeRestriction);
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //连接输入和输出
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    // 设置条码类型
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#else
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
#endif
    
    // 添加扫描画面
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    self.preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.preview.frame =self.view.layer.bounds;
        [self.view.layer insertSublayer:self.preview atIndex:0];
        // 开始
        [self.session startRunning];
    });
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (self.isGetQRCodeStringValue == NO) {
        self.isGetQRCodeStringValue = YES;
    }else{
        return;
    }
    
    NSString *stringValue;
    if (metadataObjects != nil && ([metadataObjects count] >0)){
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
        
        stringValue = metadataObject.stringValue;
        NSError * error = nil;
        BOOL result =  [[LBLelinkKitManager sharedManager] searchFromQRCodeValue:stringValue onError:&error];//searchForLelinkServiceFormQRCode:stringValue onError:&error];
        
        if (result) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (error) {
            NSLog(@"扫码错误：%@",error);
        }
    }
}

#pragma mark - lazy

- (UILabel *)tipLabel01 {
    if (!_tipLabel01) {
        _tipLabel01 = [[UILabel alloc] init];
        _tipLabel01.text = @"在电视应用市场搜索“乐播投屏”，下载最新版投屏应用";
        _tipLabel01.textColor = [UIColor whiteColor];
        _tipLabel01.font = [UIFont systemFontOfSize:14];
    }
    return _tipLabel01;
}

- (UILabel *)tipLabel02 {
    if (!_tipLabel02) {
        _tipLabel02 = [[UILabel alloc] init];
        _tipLabel02.text = @"扫描电视端乐播投屏的二维码，即可发现设备";
        _tipLabel02.textColor = [UIColor whiteColor];
        _tipLabel02.font = [UIFont systemFontOfSize:14];
    }
    return _tipLabel02;
}

@end
