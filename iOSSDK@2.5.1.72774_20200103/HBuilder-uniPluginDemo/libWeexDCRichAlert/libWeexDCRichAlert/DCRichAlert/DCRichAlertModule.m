//
//  DCRichAlertModule.m
//  libWeexDCRichAlert
//
//  Created by XHY on 2018/12/21.
//  Copyright © 2018 DCloud. All rights reserved.
//

#import "DCRichAlertModule.h"
#import "WXUtility.h"
#import "DCRichAlertView.h"


/**
 step 1: 导入头文件
 */
#import <LBLelinkKit/LBLelinkKit.h>
#import "LBLelinkKitManager.h"
#import "AKLeboModule.h"
/**
 step 2: 到乐播官网注册账号，并添加APP，获取APPid和密钥
 */
NSString * const LBAPPID = @"13357";
NSString * const LBSECRETKEY = @"265eece11c84d13cb1872281969d2932";



@interface DCRichAlertModule ()
{
    NSString *cbId;
    NSString *playURL;
    
    WXModuleKeepAliveCallback conntCallBack;
}

@property (nonatomic, weak) DCRichAlertView *alertView;
@end

@implementation DCRichAlertModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(show:callback:))
WX_EXPORT_METHOD(@selector(dismiss))
 
 

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        /* 监听App停止运行事件，如果alert存在，调一下dismiss方法移除 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"PDRCoreAppDidStopedKey" object:nil];
    }
    return self;
}

- (void)_show:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    NSLog(@"这里是JS 传过来的参数%@",options);
    conntCallBack = callback;
    
    [[[AKLeboModule alloc] init] LBBeginSerach:@{@"LBAPPID":@"13357",@"LBSECRETKEY":@"265eece11c84d13cb1872281969d2932"} callback:nil];

    DCRichAlertView *alertView = [DCRichAlertView alertWithOptions:options
                                                          callback:^(NSDictionary *result) {
                                                              if (callback) {
                                                                  callback(result,YES);
                                                              }
                                                          }];
    self.alertView = alertView;
    [alertView show];
}


#pragma mark - Export Method

- (void)show:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    [self _show:options callback:callback];
}

- (void)dismiss
{
    [self.alertView dismiss];
}

@end
