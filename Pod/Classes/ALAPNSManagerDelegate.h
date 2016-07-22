//
//  APNSManagerDelegate.h
//  Pods
//
//  Created by alex520biao on 15/11/8.
//
//

#import <Foundation/Foundation.h>

/*!
 *  @brief 字符串类型的KeyPath  如:user.name
 *  @note  符合Key-Value-Coding(KVC)键值编码
 */
typedef NSString ALKeyPath;

@class ALAPNSMsg;
@class ALAPNSManager;
@class ALNodeFilter;

/*!
 *  @brief APNS消息分发消息
 *
 *  @param apns消息
 *
 *  @return
 */
typedef void (^ALAPNSMsgHandler)(ALAPNSMsg *msg);

@protocol ALAPNSManagerDelegate <NSObject>

@optional

/*!
 *  @brief 是否向将此APNS消息进入发布流程
 *
 *  @param manager
 *  @param msg
 */
- (BOOL)apnsManager:(ALAPNSManager *)manager shouldPublishAPNSMsg:(ALAPNSMsg *)msg;

/*!
 *  @brief APNS消息已经分发处理完成
 *
 *  @param manager
 *  @param msg
 *  @param filters filters为0则消息没有接收者,大于零则说明有多个接收者
 */
- (void)apnsManager:(ALAPNSManager *)manager didPublishAPNSMsg:(ALAPNSMsg *)msg filter:(NSArray<ALNodeFilter *>*)filters;


@end





