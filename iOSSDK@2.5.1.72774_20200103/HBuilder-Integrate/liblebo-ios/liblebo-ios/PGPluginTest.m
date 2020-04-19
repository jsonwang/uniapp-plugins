//
//  PluginTest.m
//  HBuilder-Hello
//
//  Created by Mac Pro on 14-9-3.
//  Copyright (c) 2014年 DCloud. All rights reserved.
//

#import "PGPluginTest.h"
#import "PDRCoreAppFrame.h"
//#import "H5WEEngineExport.h"
#import "PDRToolSystemEx.h"
// 扩展插件中需要引入需要的系统库
#import <LocalAuthentication/LocalAuthentication.h>
 
#import "LBLelinkKitManager.h"


/**
 step 1: 导入头文件
 */
#import <LBLelinkKit/LBLelinkKit.h>

/**
 step 2: 到乐播官网注册账号，并添加APP，获取APPid和密钥
 */
NSString * const LBAPPID = @"13357";
NSString * const LBSECRETKEY = @"265eece11c84d13cb1872281969d2932";

@interface PGPluginTest()
{
    NSString *cbId;
    NSString *playURL;
}

@end

@implementation PGPluginTest



#pragma mark 这个方法在使用WebApp方式集成时触发，WebView集成方式不触发

/*
 * WebApp启动时触发
 * 需要在PandoraApi.bundle/feature.plist/注册插件里添加autostart值为true，global项的值设置为true
 */
- (void) onAppStarted:(NSDictionary*)options{
   
    NSLog(@"5+ WebApp启动时触发");
    // 可以在这个方法里向Core注册扩展插件的JS
    
}

// 监听基座事件事件
// 应用退出时触发
- (void) onAppTerminate{
    //
    NSLog(@"APPDelegate applicationWillTerminate 事件触发时触发");
}

// 应用进入后台时触发
- (void) onAppEnterBackground{
    //
    NSLog(@"APPDelegate applicationDidEnterBackground 事件触发时触发");
}

// 应用进入前天时触发
- (void) onAppEnterForeground{
    //
    NSLog(@"APPDelegate applicationWillEnterForeground 事件触发时触发");
}

#pragma mark 以下为插件方法，由JS触发， WebView集成和WebApp集成都可以触发


- (void)LBinit:(NSString *)appId appSecret:(NSString *)appSecret
{
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
        BOOL result = [LBLelinkKit authWithAppid:LBAPPID secretKey:LBSECRETKEY error:&error];
        if (result) {
            NSLog(@"授权成功");
        }else{
            NSLog(@"授权失败：error = %@",error);
        }
    });
    
    //2,开始查找设备
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidConnecte) name:LBLelinkKitManagerConnectionDidConnectedNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:LBLelinkKitManagerConnectionDisConnectedNotification object:nil];
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

- (void)LBPlayWithURL:(NSString *)url ipAddress:(NSString*)ipAddress
{
    
    playURL = url;
  
    LBLelinkConnection* templelinkConnection;
    for (LBLelinkConnection * lelinkConnection in [LBLelinkKitManager sharedManager].lelinkConnections) {
      if ([ipAddress isEqualToString:lelinkConnection.lelinkService.ipAddress])
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

- (void)updateDeviceList:(NSNotification *)notification {
    
    
    NSString * deveiceNs = @"";
    for (LBLelinkConnection * lelinkConnection in [LBLelinkKitManager sharedManager].lelinkConnections)
    {
           
        NSLog(@"查到 %@ %@ %@ 投屏！！！",lelinkConnection.lelinkService.lelinkServiceName, lelinkConnection.lelinkService.ipAddress,lelinkConnection.lelinkService.tvUID);
                   
                
        deveiceNs  =[NSString stringWithFormat:@"%@-%@",deveiceNs,lelinkConnection.lelinkService.lelinkServiceName];
                     
              
        }
    

    
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsString:deveiceNs];
    
     [self toCallback:cbId withReslut:[result toJSONString]];
    
}

- (void)PluginTestFunction:(PGMethod*)commands
{
    
    
	if ( commands ) {
        // CallBackid 异步方法的回调id，H5+ 会根据回调ID通知JS层运行结果成功或者失败
        cbId = [commands.arguments objectAtIndex:0];
        
        // 用户的参数会在第二个参数传回
        NSString* pArgument1 = [commands.arguments objectAtIndex:1];
        NSString* pArgument2 = [commands.arguments objectAtIndex:2];
        NSString* pArgument3 = [commands.arguments objectAtIndex:3];
        NSString* pArgument4 = [commands.arguments objectAtIndex:4];
        
        // 如果使用Array方式传递参数
        NSArray* pResultString = [NSArray arrayWithObjects:pArgument1, pArgument2, pArgument3, pArgument4, nil];
        
        [self LBinit:LBAPPID appSecret:LBSECRETKEY];
//
   
    }
}

- (NSData*)PluginTestFunctionSyncArrayArgu:(PGMethod*)command
{
    // 根据传入参数获取一个Array，可以从中获取参数
    NSArray* pArray = [command.arguments objectAtIndex:0];
    
    // 创建一个作为返回值的NSDictionary
    NSDictionary* pResultDic = [NSDictionary dictionaryWithObjects:pArray forKeys:[NSArray arrayWithObjects:@"RetArgu1",@"RetArgu2",@"RetArgu3", @"RetArgu4", nil]];

    
    [self LBPlayWithURL:@"http://hpplay.cdn.cibn.cc/videos/03.mp4" ipAddress:@"192.168.1.103"];
    
    // 返回类型为JSON，JS层在取值是需要按照JSON进行获取
    return [self resultWithJSON: pResultDic];
}

- (void)PluginTestFunctionArrayArgu:(PGMethod*)commands
{
  
    // CallBackid 异步方法的回调id，H5+ 会根据回调ID通知JS层运行结果成功或者失败
    NSString* cbId = [commands.arguments objectAtIndex:0];
    
    // 用户的参数会在第二个参数传回，可以按照Array方式传入，
    NSArray* pArray = [commands.arguments objectAtIndex:1];
    
    // 如果使用Array方式传递参数
    NSString* pResultString = [NSString stringWithFormat:@"%@ %@ %@ %@",[pArray objectAtIndex:0], [pArray objectAtIndex:1], [pArray objectAtIndex:2], [pArray objectAtIndex:3]];
    
    // 运行Native代码结果和预期相同，调用回调通知JS层运行成功并返回结果
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsString:pResultString];
    
    // 如果Native代码运行结果和预期不同，需要通过回调通知JS层出现错误，并返回错误提示
    //PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusError messageAsString:@"惨了! 出错了！ 咋(wu)整(liao)"];
    
    // 通知JS层Native层运行结果
    [self toCallback:cbId withReslut:[result toJSONString]];
}

@end
