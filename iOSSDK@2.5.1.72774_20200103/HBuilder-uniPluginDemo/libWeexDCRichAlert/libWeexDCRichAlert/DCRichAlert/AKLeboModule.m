//
//  AKLeboModule.m
//  libWeexDCRichAlert
//
//  Created by ak on 2020/2/20.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "AKLeboModule.h"
#import "WXUtility.h"


/**
 step 1: 导入头文件
 */
#import <LBLelinkKit/LBLelinkKit.h>
#import "LBLelinkKitManager.h"

///**
// step 2: 到乐播官网注册账号，并添加APP，获取APPid和密钥
// */
//NSString * const LBAPPID = @"13357";
//NSString * const LBSECRETKEY = @"265eece11c84d13cb1872281969d2932";
//


@interface AKLeboModule()
{
  
    NSString *cbId;
    NSString *playURL;
    
    WXModuleKeepAliveCallback conntCallBack;
    
}

@end

@implementation AKLeboModule


WX_EXPORT_METHOD(@selector(LBBeginSerach:callback:))
WX_EXPORT_METHOD(@selector(LBBeginPlaying:callback:))

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init])
    {


    }
    return self;
}


- (void)LBBeginSerach:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    NSLog(@"查找设备参数 %@",options);
     conntCallBack = callback;
   
        //1,初始化
        /**
         step 3: 是否打开log，默认是关闭的
         */
        [LBLelinkKit enableLog:YES];
        
        /**
         step 4: 使用APP id 和密钥授权授权SDK
         注意：（1）需要在Info.plist中设置ATS；（2）可以异步执行，不影响APP的启动
         */
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError * error = nil;
            BOOL result = [LBLelinkKit authWithAppid:[options objectForKey:@"LBAPPID"] secretKey:[options objectForKey:@"LBSECRETKEY"] error:&error];
            if (result) {
                NSLog(@"授权成功");
            }else{
                NSLog(@"授权失败：error = %@",error);
            }
        });
        
        //2,开始查找设备
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidConnecte) name:LBLelinkKitManagerConnectionDidConnectedNotification object:nil];
   
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:LBLelinkKitManagerServiceDidChangeNotification object:nil];
        [[LBLelinkKitManager sharedManager] search];
    
    
}

// 联接成功后开始播放
- (void)connectionDidConnecte
{
 
        LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
        item.mediaType = LBLelinkMediaTypeVideoOnline;
        item.mediaURLString =playURL;
        /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
        [[LBLelinkKitManager sharedManager].lelinkPlayer stop];
        [[LBLelinkKitManager sharedManager].lelinkPlayer playWithItem:item];
}

///  开始播放
/// @param options  dic 参有 “url”  & "ipAddress"   两个 KEY 注意 JS 中一定也要这样写
/// @param callback 回调方法
- (void)LBBeginPlaying:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    
    playURL = [options objectForKey:@"url"];
   
    LBLelinkConnection* templelinkConnection;
    
    for (LBLelinkConnection * lelinkConnection in [LBLelinkKitManager sharedManager].lelinkConnections) {
      if ([[options objectForKey:@"ipAddress"] isEqualToString:lelinkConnection.lelinkService.ipAddress])
    {
            templelinkConnection = lelinkConnection;
          NSLog(@"使用 %@ %@ %@ 投屏！！！",lelinkConnection.lelinkService.lelinkServiceName, lelinkConnection.lelinkService.ipAddress,lelinkConnection.lelinkService.tvUID);
          break;
      }
    }
    
          /**
           点击设备，如果未连接，则建立连接，如果已连接，则断开连接
           */
          // 当前连接
          LBLelinkConnection * currentConnection = [LBLelinkKitManager sharedManager].currentConnection;
          // 选择的连接
          LBLelinkConnection * selectedConnection = templelinkConnection;
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

- (void)stopSearch {
    
    [[LBLelinkKitManager sharedManager] stopSearch];
}



- (void)updateDeviceList:(NSNotification *)notification {
    NSMutableDictionary * dic = [NSMutableDictionary new];
    for (LBLelinkConnection * lelinkConnection in [LBLelinkKitManager sharedManager].lelinkConnections)
    {
           
        NSLog(@"查到 %@ %@ %@ 投屏！！！",lelinkConnection.lelinkService.lelinkServiceName, lelinkConnection.lelinkService.ipAddress,lelinkConnection.lelinkService.tvUID);

        [dic setValue:lelinkConnection.lelinkService.ipAddress forKey:lelinkConnection.lelinkService.lelinkServiceName];
              
    }
    
    if(conntCallBack){conntCallBack(dic,YES);}
 
}


@end
