//
//  NSString+LBNSString.m
//  LBLelinkKitSample
//
//  Created by 刘明星 on 2018/8/27.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import "NSString+LBNSString.h"

@implementation NSString (LBNSString)

+ (NSString *)timeStringFromeInteger:(NSInteger)time {
    if (time < 60) {
        return [NSString stringWithFormat:@"00:00:%02ld", (time % 60)];
    }else if (time >= 60 && time < 3600) {
        return [NSString stringWithFormat:@"00:%02ld:%02ld", (time / 60 % 60),(time % 60)];
    }else{
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (time / 3600),(time / 60 % 60),(time % 60)];
    }
}

@end
