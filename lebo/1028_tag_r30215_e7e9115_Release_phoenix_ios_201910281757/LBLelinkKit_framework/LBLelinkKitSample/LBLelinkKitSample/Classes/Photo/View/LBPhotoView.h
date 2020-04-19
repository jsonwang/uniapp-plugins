//
//  LBPhotoView.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/29.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LBPhotoView;

@protocol LBPhotoViewDelegate <NSObject>

@optional
- (void)photoView:(LBPhotoView *)photoView castBtnClicked:(UIButton *)button;
- (void)photoView:(LBPhotoView *)photoView previousBtnClicked:(UIButton *)button;
- (void)photoView:(LBPhotoView *)photoView nextBtnClicked:(UIButton *)button;
- (void)photoView:(LBPhotoView *)photoView switchDeviceBtnClicked:(UIButton *)button;
- (void)photoView:(LBPhotoView *)photoView stopBtnClicked:(UIButton *)button;

@end

@interface LBPhotoView : UIView

@property (nonatomic, weak) id<LBPhotoViewDelegate> delegate;

- (void)setPhotoImageViewWithUrlString:(NSString *)urlString;
- (void)swithToCastMode:(BOOL)isCastMode;

@end

NS_ASSUME_NONNULL_END
