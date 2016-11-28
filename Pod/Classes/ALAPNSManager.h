//
//  APNSManager.h
//  Pods
//
//  Created by alex520biao on 15/11/7.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSManagerDelegate.h"
#import "ALAPNSManagerPubProtocol.h"
#import "ALAPNSManagerSubProtocol.h"

@class ALAPNSMsg;

/*!
 *  @brief  APNS消息提示样式,支持位运算
 */
typedef NS_OPTIONS(NSUInteger, RemoteNotificationType) {
    // the application may not present any UI upon a notification being received
    RemoteNotificationTypeNone    = 0,
    // the application may badge its icon upon a notification being received
    RemoteNotificationTypeBadge   = 1 << 0,
    // the application may play a sound upon a notification being received
    RemoteNotificationTypeSound   = 1 << 1,
    // the application may display an alert upon a notification being received
    RemoteNotificationTypeAlert   = 1 << 2,
};

/*!
 *  @brief  APNS推送管理器: 管理APNS消息的一切事务
 */
@interface ALAPNSManager : NSObject<ALAPNSManagerPubProtocol,ALAPNSManagerSubProtocol>

/*!
 *  @brief ALAPNSManagerDelegate代理
 */
@property (nonatomic, weak) id<ALAPNSManagerDelegate> delegate;

/*!
 *  @brief 启动APNS消息
 */
@property (nonatomic,strong,readonly) ALAPNSMsg *launAPNSMsg;


#pragma mark - register
/*!
 *  @brief  默认定义APNS通知
 *  @note   (RemoteNotificationTypeBadge|RemoteNotificationTypeSound|RemoteNotificationTypeAlert)
 */
- (void)registerForRemoteNotification;

/*!
 *  @brief  自定义APNS通知提示样式
 *
 *  @param type       APNS提示样式
 *  @param categories iOS8开始支持
 */
- (void)registerForRemoteNotification:(RemoteNotificationType)type
                           categories:(NSSet<UIUserNotificationCategory *> *)categories;

#pragma mark - deviceToken
/*!
 *  @brief  deviceToken
 */
@property(nonatomic ,copy, readonly)NSString * deviceToken;

/*!
 *  @brief 接收并存储deviceToken
 *
 *  @param deviceToken
 *
 *  @return 是否有变化(有变法则需要发送网络请求将deviceToken提交到push provider推送服务器)
 */
- (BOOL)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/*!
 *  @brief  删除并置空当前deviceToken
 */
- (void)deleteDeviceToken;

#pragma mark - other
/*!
 *  @brief 是否实现旧方法
 *
 *  @return
 */
-(BOOL)oldMethodDidReceiveRemoteNotification;

/*!
 *  @brief  接收并处理启动应用程序时的APNSMsg
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *  @param handle 是否需要继续分发处理
 *
 */
-(void)receivedAPNSMsgWithLaunchOptions:(NSDictionary*)launchOptions needHandle:(BOOL)needHandle;

#pragma mark - ALAPNSManagerPubProtocol  - 实现发布协议

#pragma mark - ALAPNSManagerSubProtocol  - 实现订阅协议

@end
