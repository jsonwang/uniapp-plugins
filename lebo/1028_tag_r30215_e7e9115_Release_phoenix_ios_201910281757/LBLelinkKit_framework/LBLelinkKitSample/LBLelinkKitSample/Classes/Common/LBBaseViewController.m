//
//  LBBaseViewController.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/21.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBBaseViewController.h"

@interface LBBaseViewController ()

@end

@implementation LBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setBaseUI];
}


#pragma mark - action
- (void)backBtnClicked:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI
- (void)setBaseUI {
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,24,44)];
    [backBtn setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItems = @[leftBtn];
}


@end
