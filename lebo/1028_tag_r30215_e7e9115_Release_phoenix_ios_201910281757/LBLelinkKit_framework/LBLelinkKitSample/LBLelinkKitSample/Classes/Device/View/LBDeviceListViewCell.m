//
//  LBDeviceListViewCell.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/21.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "LBDeviceListViewCell.h"

@implementation LBDeviceListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UI

- (void)setUI {
    [self.contentView addSubview:self.deviceTypeImageView];
    [self.contentView addSubview:self.deviceNameLabel];
    [self.contentView addSubview:self.connectionStatusImageView];
    
    [self.deviceTypeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.width.equalTo(@44);
    }];
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.deviceTypeImageView.mas_trailing).offset(8);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.connectionStatusImageView.mas_leading);
    }];
    [self.connectionStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-20);
        make.width.equalTo(@44);
    }];
}

#pragma mark - setter & getter

- (UIImageView *)deviceTypeImageView{
    if (_deviceTypeImageView == nil) {
        _deviceTypeImageView = [[UIImageView alloc] init];
    }
    return _deviceTypeImageView;
}

- (UILabel *)deviceNameLabel{
    if (_deviceNameLabel == nil) {
        _deviceNameLabel = [[UILabel alloc] init];
    }
    return _deviceNameLabel;
}

- (UIImageView *)connectionStatusImageView{
    if (_connectionStatusImageView == nil) {
        _connectionStatusImageView = [[UIImageView alloc] init];
    }
    return _connectionStatusImageView;
}

@end
