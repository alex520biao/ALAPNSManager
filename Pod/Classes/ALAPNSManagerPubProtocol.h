//
//  ALAPNSManagerPubProtocol.h
//  Pods
//
//  @brief ALAPNSManager发布者协议，AppDelegate为APNS消息发布者
//  Created by alex520biao on 15/11/8.
//
//

#import <Foundation/Foundation.h>

@protocol ALAPNSManagerPubProtocol <NSObject>

@optional

#pragma mark - handleAPNSMsg
/*!
 *  @brief  接收并处理启动应用程序时的APNSMsg
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *  @param handle 是否需要继续分发处理
 *
 */
-(void)handleAPNSMsgWithLaunchOptions:(NSDictionary*)launchOptions needHandle:(BOOL)needHandle;



/*!
 *  @brief  接收并处理正常情况下接收的APNSMsg消息
 *
 *  @param  remoteDict appdelegate从application:didReceiveRemoteNotification入口参数
 *
 */
-(void)handleAPNSMsgWithDidReceiveRemoteNotification:(NSDictionary*)remoteDict;


@end





