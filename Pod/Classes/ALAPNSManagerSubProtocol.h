//
//  ALAPNSManagerSubProtocol.h
//  Pods
//
//  @brief ALAPNSManager订阅者协议，应用的业务模块Service为APNS消息的订阅者
//  Created by alex520biao on 15/11/8.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSManagerDelegate.h"

/*!
 *  @brief APNS消息分发消息
 *
 *  @param apns消息
 *
 *  @return
 */
typedef void (^ALAPNSMsgHandler)(ALAPNSMsg *msg);

@protocol ALAPNSManagerSubProtocol <NSObject>

@optional

#pragma mark - Observer监听注册管理
/*!
 *  @brief 添加一个监听项
 *  @note  相同的observer、相同keyPath、相同value，则覆盖只保留最后一次监听
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 *  @param handler  监听者回调
 */
- (void)addAPNSPattern:(ALKeyPath *)keyPath
           filterValue:(NSString *)value
              observer:(id)observer
               handler:(ALAPNSMsgHandler)handler;

/*!
 *  @brief 删除一个监听项
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 */
-(void)removeAPNSPattern:(ALKeyPath *)keyPath
             filterValue:(NSString*)value
                observer:(id)observer;


@end





