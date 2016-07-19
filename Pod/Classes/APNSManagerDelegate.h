//
//  APNSManagerDelegate.h
//  Pods
//
//  Created by alex520biao on 15/11/8.
//
//

#import <Foundation/Foundation.h>

/*!
 *  @brief 字符串类型的KeyPath  如: user.name
 */
typedef NSString ALKeyPath;

@class ALAPNSMsg;

/*!
 *  @brief APNS消息分发消息
 *
 *  @param apns消息
 *
 *  @return
 */
typedef id (^ALAPNSMsgHandler)(ALAPNSMsg *msg);





