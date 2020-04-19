//
//  NSString+LBNSString.h
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/27.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LBNSString)

/**
 将以秒为单位的整形数字转换为“时：分：秒”格式的字符串

 @param time 秒
 @return “xx:xx:xx”
 */
+ (NSString *)timeStringFromeInteger:(NSInteger)time;

@end

NS_ASSUME_NONNULL_END
