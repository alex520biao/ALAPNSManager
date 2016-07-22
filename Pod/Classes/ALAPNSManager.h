//
//  APNSManager.h
//  Pods
//
//  Created by alex520biao on 15/11/7.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSManagerDelegate.h"

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
@interface ALAPNSManager : NSObject

@property (nonatomic, weak) id<ALAPNSManagerDelegate> delegate;


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

#pragma mark - handleAPNSMsg
/*!
 *  @brief  接收并处理启动应用程序时的APNSMsg
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 */
-(void)handleAPNSMsgWithLaunchOptions:(NSDictionary*)launchOptions;


/*!
 *  @brief  接收并处理正常情况下接收的APNSMsg消息
 *
 *  @param  remoteDict appdelegate从application:didReceiveRemoteNotification入口参数
 *
 */
-(void)handleAPNSMsgWithDidReceiveRemoteNotification:(NSDictionary*)remoteDict;

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
