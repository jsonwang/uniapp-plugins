//
//  LBLocalWebServerTool.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/30.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBLocalWebServerTool : NSObject

/**
 启动WebServer
 */
- (void)startGCDWebServer;

/**
 停止WebServer
 */
- (void)stopGCDWebServer;

/**
 将工程中的一组文件拷贝到沙盒

 @param fileNames 文件名称
 @param type 文件类型，如.mp3
 */
- (void)copyFilesToDocument:(NSArray*)fileNames type:(NSString *)type;

/**
 获取本地文件的URL

 @param fileNames 文件名称
 @param type 文件类型
 @return 本地文件的URL
 */
- (NSArray *)getLocalUrlsWithFileNames:(NSArray *)fileNames type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
