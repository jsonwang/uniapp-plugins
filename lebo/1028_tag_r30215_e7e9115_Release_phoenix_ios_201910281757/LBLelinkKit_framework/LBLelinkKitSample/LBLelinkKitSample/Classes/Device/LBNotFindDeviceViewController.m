//
//  LBNotFindDeviceViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/22.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBNotFindDeviceViewController.h"
#import "UIButton+LBUIButton.h"

@import WebKit;

@interface LBNotFindDeviceViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *retryBtn;

@end

@implementation LBNotFindDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [self loadWebView];
    
}

#pragma mark - UI
- (void)setUI {
    [self.view addSubview:self.webView];
    [self.view addSubview:self.retryBtn];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
}

- (void)loadWebView {
    NSURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cdn.hpplay.com.cn/h5/app/guide.html?v=100"]];
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.retryBtn.hidden = NO;
}

#pragma mark - action

- (void)retryBtnClicked:(UIButton *)btn {
    NSLog(@"%s", __func__);
    [self loadWebView];
    btn.hidden = YES;
}


#pragma mark - getter & setter

- (WKWebView *)webView{
    if (_webView == nil) {
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIButton *)retryBtn{
    if (_retryBtn == nil) {
        _retryBtn = [UIButton buttonWithTitle:@"重试" target:self action:@selector(retryBtnClicked:)];
        _retryBtn.hidden = YES;
    }
    return _retryBtn;
}


@end
