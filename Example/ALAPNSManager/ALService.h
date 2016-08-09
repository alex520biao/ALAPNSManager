//
//  ALService.h
//  ALAPNSManager
//
//  Created by alex520biao on 16/7/19.
//  Copyright © 2016年 alex520biao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ALAPNSManager/ALAPNSManagerKit.h>

@interface ALService : NSObject

@property (nonatomic, strong) id<ALAPNSManagerPubProtocol,ALAPNSManagerSubProtocol> apnsManager;

/*!
 *  @brief service加载完成(子类需要重写)
 */
- (void)serviceDidLoad;

@end
