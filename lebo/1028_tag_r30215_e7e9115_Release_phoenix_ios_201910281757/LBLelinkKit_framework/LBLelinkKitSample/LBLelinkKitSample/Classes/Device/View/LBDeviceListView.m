//
//  LBDeviceListView.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/21.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBDeviceListView.h"
#import "UIButton+LBUIButton.h"
#import "LBDeviceListViewCell.h"

NSString * const LBDeviceListCellIdentifier = @"LBDeviceListCellIdentifier";

@interface LBDeviceListView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *helpBtn;

@end

@implementation LBDeviceListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUI];
        [self.tableView registerClass:[LBDeviceListViewCell class] forCellReuseIdentifier:LBDeviceListCellIdentifier];
    }
    return self;
}

- (void)updateUI {
    [self.tableView reloadData];
}
 

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",(unsigned long)self.lelinkConnections.count);
    return self.lelinkConnections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBDeviceListViewCell * cell = (LBDeviceListViewCell *)[tableView dequeueReusableCellWithIdentifier:LBDeviceListCellIdentifier forIndexPath:indexPath];
    LBLelinkConnection * lelinkConnection = self.lelinkConnections[indexPath.row];
    
    // 设置名称
    cell.deviceNameLabel.text = lelinkConnection.lelinkService.lelinkServiceName;
    
    NSString * imageName = @"devicepage_remote_icon1";
    if (lelinkConnection.lelinkService.isInnerLelinkServiceAvailable || lelinkConnection.lelinkService.isUpnpServiceAvailable) {
        // 可局域网投屏的
        imageName = @"devicepage_device_icon1";
    }
    // 设置image
    cell.deviceTypeImageView.image = [UIImage imageNamed:imageName];
    
    if (lelinkConnection.isConnected) {
        cell.connectionStatusImageView.image = [UIImage imageNamed:@"landing_Checked"];
    }else{
        cell.connectionStatusImageView.image = nil;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(deviceListView:didSelectRowAtIndexPath:)]) {
        [self.delegate deviceListView:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UI

- (void)setUI {
    [self addSubview:self.headerLabel];
    [self addSubview:self.tableView];
    
    [self.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (LBHasSafeArea) {
            make.top.equalTo(self.mas_safeAreaLayoutGuide).offset(10);
        } else {
            make.top.equalTo(self).offset(10);
        }
        make.leading.equalTo(self).offset(8);
        make.trailing.equalTo(self).offset(8);
        make.height.equalTo(@30);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerLabel.mas_bottom);
        make.leading.equalTo(self);
        make.bottom.equalTo(self);
        make.trailing.equalTo(self);
    }];
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        if (LBHasSafeArea) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuide).offset(-10);
        } else {
            make.bottom.equalTo(self).offset(-10);
        }
        make.height.equalTo(@30);
    }];
}


#pragma mark - setter & getter

- (UILabel *)headerLabel{
    if (_headerLabel == nil) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.text = @"选择要投屏的设备";
        [_headerLabel setFont:[UIFont systemFontOfSize:20]];
        [_headerLabel setTextColor:[UIColor blackColor]];
    }
    return _headerLabel;
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = footerView;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    }
    return _tableView;
}
 
- (void)setLelinkConnections:(NSMutableArray *)lelinkConnections {
    _lelinkConnections = lelinkConnections;
    [self.tableView reloadData];
}

@end
