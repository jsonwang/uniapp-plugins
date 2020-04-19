//
//  LBUnlimitedBackgroundTaskTool.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/30.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBUnlimitedBackgroundTaskTool.h"
@import AVFoundation;

@interface LBUnlimitedBackgroundTaskTool ()

@property (nonatomic, strong) UIApplication *app;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSTimer *audioTimer;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation LBUnlimitedBackgroundTaskTool

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _app = [UIApplication sharedApplication];
        [self addNotifications];
    }
    return self;
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - notification

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    if (self.audioTimer) {
        [self.audioTimer invalidate];
        self.audioTimer = nil;
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    
    // 没有连接TV端则不用保活
    if (![LBLelinkKitManager sharedManager].currentConnection.isConnected) {
        return;
    }
    
    /** 启动保活 */
    self.bgTask = [self.app beginBackgroundTaskWithExpirationHandler:^{
        [self.app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    NSLog(@"applicationDidEnterBackground  backgroundTimeRemaining = %f",self.app.backgroundTimeRemaining);
    
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
    [self.audioTimer fire];
}

#pragma mark - private
- (void)applyForMoreTime {
    NSLog(@"applyForMoreTime  backgroundTimeRemaining = %f",self.app.backgroundTimeRemaining);
    
    if (self.app.backgroundTimeRemaining < 30) {
        NSURL * filePathUrl = [NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"1" ofType:@"wav"]];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:NULL];
        /**
         使用AVAudioPlayer会在系统连接了AirPlay的时候将音频推送到接收端，存在冲突，使用AVPlayer可解决此问题
         */
        self.player = [AVPlayer playerWithURL:filePathUrl];
        self.player.allowsExternalPlayback = NO;
        [self.player setVolume:1];
        [self.player play];
        
        self.bgTask = [self.app beginBackgroundTaskWithExpirationHandler:^{
            [self.app endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }];
        NSLog(@"重新申请后台任务，backgroundTimeRemaining = %f",self.app.backgroundTimeRemaining);
    }
}

@end
