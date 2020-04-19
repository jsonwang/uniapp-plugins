//
//  LBLocalWebServerTool.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/30.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBLocalWebServerTool.h"
#import "GCDWebDAVServer.h"
#import "Reachability.h"

@interface LBLocalWebServerTool ()

@property (nonatomic, strong) GCDWebDAVServer *webDAVServer;
@property (nonatomic, copy) NSString *localUrlString;

@property (nonatomic, strong) Reachability *rech;

@end

@implementation LBLocalWebServerTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rech = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    }
    return self;
}


/**
 启动本地服务器
 */
- (void)startGCDWebServer {
    
    if (_webDAVServer.isRunning) {
        NSLog(@"webserver isRunning");
        return;
    }
    if (!self.rech.isReachableViaWiFi) {
        NSLog(@"isReachableViaWiFi is NO!");
        return;
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webDAVServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:path];
    
    int port = 8090;
    for (int i = 0; i < 10; i++) {
        port = port + i;
        BOOL login  = [_webDAVServer startWithPort:port bonjourName:@""];
        if (login) {
            break;
        }
    }
    _localUrlString = _webDAVServer.serverURL.absoluteString;
    NSLog(@"_localUrlString:%@",_localUrlString);
}

- (void)stopGCDWebServer {
    if (_webDAVServer.isRunning) {
        [_webDAVServer stop];
    }
}

- (void)copyFilesToDocument:(NSArray*)fileNames type:(NSString *)type {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for (NSString * fileName in fileNames) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString * fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName,type]];
        
        BOOL isExist = [fm fileExistsAtPath:fullPath];
        
        if (!isExist){
            //获取工程中文件
            NSString *fileBundlePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
            if ([fm copyItemAtPath:fileBundlePath toPath:fullPath error:nil]) {
                NSLog(@"%@成功复制到沙盒", fileName);
            }else {
                NSLog(@"%@复制到沙盒失败", fileName);
            }
        } else {
            NSLog(@"%@已存在沙盒里", fileName);
        }
    }
}

- (NSArray *)getLocalUrlsWithFileNames:(NSArray *)fileNames type:(NSString *)type {
    NSMutableArray * urls = [NSMutableArray arrayWithCapacity:fileNames.count];
    for (NSInteger i = 0; i < fileNames.count; i++) {
        NSString * url = [NSString stringWithFormat:@"%@%@.%@",self.localUrlString,fileNames[i],type];
        [urls addObject:url];
    }
    return urls.copy;
}

@end
