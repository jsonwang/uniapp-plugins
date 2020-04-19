//
//  AKLeboModule.h
//  libWeexDCRichAlert
//
//  Created by ak on 2020/2/20.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKLeboModule : NSObject <WXModuleProtocol>

- (void)LBBeginSerach:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback;

- (void)stopSearch;
@end

NS_ASSUME_NONNULL_END
