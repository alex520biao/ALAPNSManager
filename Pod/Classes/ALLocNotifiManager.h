//
//  ALLocNotifiManager.h
//  Pods
//
//  Created by alex520biao on 16/9/30.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSManagerDelegate.h"

@class ALLocNotifiManager;

/*!
 *  @brief LocalNotification分发消息
 *
 *  @param 本地通知消息
 *
 *  @return
 */
typedef void (^ALLocalNotificationHandler)(UILocalNotification *localNotification);

@protocol ALLocNotifiManagerDelegate <NSObject>

@optional

/*!
 *  @brief 是否向将此UILocalNotification进入发布流程
 *  @note  此方法可以对UILocalNotification消息进行统一过滤、日志操作等
 *
 *  @param manager
 *  @param msg
 */
- (BOOL)locNotifiManager:(ALLocNotifiManager *)manager shouldPublishLocNotifi:(UILocalNotification *)msg;

/*!
 *  @brief UILocalNotification消息已经分发处理完成
 *
 *  @param manager
 *  @param msg
 *  @param filters filters为0则消息没有接收者,大于零则说明有多个接收者
 */
- (void)locNotifiManager:(ALLocNotifiManager *)manager didPublishLocNotifi:(UILocalNotification *)msg filter:(NSArray<ALNodeFilter *>*)filters;


@end


@interface ALLocNotifiManager : NSObject


/*!
 *  @brief ALLocNotifiManagerDelegate代理
 */
@property (nonatomic, weak) id<ALLocNotifiManagerDelegate> delegate;


#pragma mark - Observer监听注册管理
/*!
 *  @brief 添加一个监听项
 *  @note  相同的observer、相同keyPath、相同value，则覆盖只保留最后一次监听
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath UILocalNotification的userInfo字典中的KeyPath
 *  @param value    监听值
 *  @param handler  监听者回调
 */
- (void)addLocNotifiPattern:(ALKeyPath *)keyPath
                filterValue:(NSString *)value
                   observer:(id)observer
                    handler:(ALLocalNotificationHandler)handler;

/*!
 *  @brief 删除一个监听项
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 */
-(void)removeLocNotifiPattern:(ALKeyPath *)keyPath
                  filterValue:(NSString*)value
                     observer:(id)observer;

#pragma mark - 实现发布协议
/*!
 *  @brief  接收并处理启动应用程序的UILocalNotification
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 */
-(void)handleLocNotifiWithLaunchOptions:(NSDictionary*)launchOptions;

/*!
 *  @brief  接收并处理正常情况下接收的UILocalNotification
 *
 *  @param  locNotifi appdelegate从application:didReceiveLocalNotification入口参数
 *  @param  applicationStatus 应用接收到UILocalNotification时所处状态
 *
 */
-(void)handleLocNotifiWithDidReceiveRemoteNotification:(UILocalNotification*)locNotifi
                                     applicationStatus:(UIApplicationState)applicationStatus;

@end
