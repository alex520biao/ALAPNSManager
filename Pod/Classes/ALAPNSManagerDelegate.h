//
//  APNSManagerDelegate.h
//  Pods
//
//  Created by alex520biao on 15/11/8.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSTool.h"

@class ALAPNSMsg;
@class ALAPNSManager;
@class ALNodeFilter;

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





