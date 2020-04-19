//
//  HPOfficeCast.h
//  OfficeCastingSDK
//
//  Created by wzj on 2017/4/1.
//  Copyright © 2017年 wzj. All rights reserved.

#import <Foundation/Foundation.h>

// 接收端默认启始通信端口
#define kDefaultCastPort 52244
// 投屏设备默认名称
#define kCastDeviceName @"云之家"
// SDK版本
#define kSDKVersion @"1.5.3"
/*版本更新记录
 V1.1：
 1.添加开启打印开关，2.移除mic采集，3.非主线程调用接口处理，加强代码健壮性,细化错误描述,稳定性优化。
 V1.2：
 1.添加接收端不允许投屏状态HPOfficeCastErrorCodeTVNoAllowCast，2.修复可能存在的投屏繁忙不正确提示。
 V1.2.2:
 1.添加日志输出代理方法。
 V1.3:
 1.在非同网段下，IP服务发布，解决公司大网投屏问题,2.发布服务名称宏定义，默认“”，可更改,3.投屏优化,解决连接数据线不能投屏的bug。
 V1.3.1
 1.修复crash。
 V1.3.2
 1.ios11添加关闭投屏逻辑，ios11关闭投屏采用通知接收端主动断开与手机的方式.
 V1.3.3
 1.搜身SDK.
 V1.4
 1:搜索不到设备服务，添加重新发布机制，2.选择设备投屏后无响应，重试机制，3.修复野指针问题
 V1.4.1
 1.修复ipad可能存在野指针的问题 2.调整重试连接时间间隔(剩余时间需超过5秒,3秒重试选择设备)
 V1.4.2
 1.修复与项目超声波代码影响投屏的问题
 V1.4.3
 1.添加mode和设置错误打印，2.修改重新间隔时间
 V1.4.4
 1.在未搜索到设备时,重新设置category
 V1.4.5
 1.修复iOS11系统可能搜索不到服务的问题
 V1.4.6
 1.修复可能无法停止投屏的问题
 V1.4.7
 1.修改投屏状态获取方法,修复可能存在获取系统镜像状态不正确的问题
 V1.5.2
 1.添加“”设备是否正在投屏属性
 V1.5.3
 1.服务发布信息添加本地存储,修复重启程序后重新发布服务失败问题
 */

/** 支持可投屏码的类型 */
typedef enum {
    HPCastSupportCastCodeTypeServer  = 1 << 0, // 支持服务器投屏码投屏
    HPCastSupportCastCodeTypeLocal   = 1 << 1, // 支持本地投屏码转换成IP投屏
    HPCastSupportCastCodeTypeDefault = HPCastSupportCastCodeTypeServer | HPCastSupportCastCodeTypeLocal, // 默认同时支持服务器投屏码和本地投屏码投屏
}HPCastSupportCastCodeType;

/** 投屏错误码 */
typedef enum : NSUInteger {
    HPOfficeCastErrorCodeBusy = 4000,//投屏繁忙
    HPOfficeCastErrorCodeTimeOut,//投屏失败超时
    HPOfficeCastErrorCodeUnknown,//投屏失败未知
    HPOfficeCastErrorCodeOpenLeboCastFailBecauseIsLeboCasting,//打开投屏失败，因为投屏已经打开了
    HPOfficeCastErrorCodeCloseLeboCastFailBecauseIsClosed,//关闭投屏失败，因为投屏已经处于关闭状态
    HPOfficeCastErrorCodeCloseLeboCastFailLackCastTvIP,//关闭投屏失败，缺少关闭投屏电视的IP，可设置castSuccessIP属性,再调用关闭投屏
    HPOfficeCastErrorCodeCloseLeboCastRequestFailed,//关闭投屏失败，请求错误
    HPOfficeCastErrorCodeCloseLeboCastFailIPNotMatch,//关闭投屏失败，TV端正在投屏的手机IP不是该设备IP
    HPOfficeCastErrorCodeAppkeyVerifyFailure = 4040,//appkey验证失败
    HPOfficeCastErrorCodeCastIpAbnormal,//ip地址异常
    HPOfficeCastErrorCodeConnectTVFailure,//连接电视失败
    HPOfficeCastErrorCodeGetTVInfoFailure,//获取电视端信息失败
    HPOfficeCastErrorCodeGetTVInfoBusy,//获取电视端信息繁忙
    HPOfficeCastErrorCodeDnsPublishFailed,//dns发布失败
    HPOfficeCastErrorCodeTVNoAllowCast,//接收端不允许投屏
    
    HPCastDevicesErrorCodeCastCodeEmpty = 4080,//投屏码为空
    HPCastDevicesErrorCodeCastCodeLengthOverstep,//投屏码长度超出范围
    HPCastDevicesErrorCodeServiceIpNoSet,//服务地址未设置
    HPCastDevicesErrorCodeServiceRequestFailed,//服务请求失败
    HPCastDevicesErrorCodeCastCodeError,//投屏码错误，查找不到
    HPCastDevicesErrorCodeServiceRequestResultsInfoImperfect,//服务请求的结果信息不完整

}HPCastDevicesErrorCode;

@class HPOfficeCast;
@protocol HPOfficeCastDelegate <NSObject>
@optional
// 投屏过程中异常断开
- (void)officeCastDisconnect;
// 投屏被其它设备抢占
- (void)officeCastOccupy;
// 投屏log输出 isLogEnable须为YES，才输出
- (void)officeCastLogOutput:(NSString *)logStr;
@end

// 投屏结果返回
typedef void (^CastCompleteBlock)(BOOL succeed,NSError * error);

/// 发布服务结果返回
typedef void (^OffCastCompleteBlock)(BOOL succeed,NSString *serviceName,NSError * error);

@interface HPOfficeCast : NSObject

// appKey验证 通过返回YES
- (BOOL)authorizeWithKey:(NSString *)appkey;

// 是否正在投屏中
@property (nonatomic,assign,readonly)BOOL isCasting;
// 是否"云之家"设备投屏中
@property (nonatomic,assign,readonly)BOOL isSDKCasting;
// 投屏成功的IP
@property (nonatomic,copy) NSString *castSuccessIP;
// 投屏成功的端口
@property (nonatomic,assign) NSInteger castSuccessPort;
// 是否启动打印 默认NO
@property (nonatomic,assign)BOOL isLogEnable;
// 投屏代理
@property (nonatomic,weak)id<HPOfficeCastDelegate> delegate;
/// 支持可投屏码的类型
@property (nonatomic,assign)HPCastSupportCastCodeType supportCastCodeType;
//  获取投屏实例
+ (instancetype)sharedOfficeCast;

//  设置服务端地址,投屏码采用公网映射ip方案,需设置服务器地址
/// @param serviceIpAddress 服务器IP或域名
/// @param servicePort 服务器端口
/// @param isHttpsRequest 是否https请求
- (void)setServiceIp:(NSString *)serviceIpAddress servicePort:(NSInteger)servicePort isHttpsRequest:(BOOL)isHttpsRequest;

///  开始投屏 iOS系统>= 11.0,暂不支持一键投屏，error.code == HPCastDevicesErrorCodeDeviceIos11OrHigNotSupportQuickCast 引导用户到控制中心选择设备投屏
//  开始投屏
/// @param code 投屏码
/// @param name 控制中心显示的设备名
/// @param timeout 超时时间 最小设置3秒,默认5秒
/// @param completeBlock 完成回掉
- (void)startHappyCastWithCastCode:(NSString *)code ctrCenterShowName:(NSString *)name timeout:(NSTimeInterval)timeout completeBlock:(OffCastCompleteBlock)completeBlock;

//  停止投屏
/// @param completeBlock 完成回掉
- (void)stopCast:(CastCompleteBlock)completeBlock;

@end

