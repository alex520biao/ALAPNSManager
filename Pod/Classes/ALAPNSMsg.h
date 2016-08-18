//
//  APNSMsg.h
//  DiTravel
//
//  Created by alex520biao on 25/3/15.
//  Copyright (c) 2015年 didi inc. All rights reserved.
//

/*!
 *  @brief  APNS消息传递到客户端的场景
 *  @note   区分apns到达客户端的不同场景,客户端需要进行不同的处理。
 */
typedef NS_ENUM(NSInteger, APNSMsgSceneType) {
    /* 
     应用未运行Notrunning时,用户通过apns消息启动应用。
     处理方式: 客户端需要直接打开消息对应结果页面。
     */
    APNSMsgSceneType_Launch,
    
    /*
     应用处于后台Background、挂起Suspended状态、前台非激活Inactive状态时,用户通过apns消息唤醒/调起应用到前台Active。
     处理方式: 客户端需要直接开发消息对应结果页面。
     */
    APNSMsgSceneType_Awake,
    
    /*
     应用处于前台活跃Active状态,客户端直接收到apns消息
     处理方式: 客户端需要根据当前应用页面和用户行为灵活处理。即可以直接开启消息内容页面,也可以使用可取消弹框、本地通知、其他自定义UI表现方式等非强制性提示手段,用户自行选择是否开启消息对应内容页面。
     */
    APNSMsgSceneType_Active
};

/*!
 *  @brief  APNSMsg用户封装系统APNS消息内容及相关信息
 *  @note   APNSMsg封装利于apns消息的分发及处理
 */
@interface ALAPNSMsg : NSObject

/*!
 *  @brief  apns启动应用程序
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 *  @return
 */
+(ALAPNSMsg*)apnsMsgWithLaunchOptions:(NSDictionary*)launchOptions;


/*!
 *  @brief  其他情况apns消息
 *
 *  @param  remoteDict appdelegate从application:didReceiveRemoteNotification入口参数
 *
 *  @return
 */
+(ALAPNSMsg*)apnsMsgWithDidReceiveRemoteNotification:(NSDictionary*)remoteDict;


- (instancetype)initWithSceneType:(APNSMsgSceneType)sceneType
                         apnsDict:(NSDictionary*)apnsDict
                 applicationState:(UIApplicationState)state;

#pragma mark - APNS相关参数
/*!
 *  @brief  APNS消息传递到客户端的场景
 */
@property(nonatomic, assign, readonly) APNSMsgSceneType sceneType;

/*!
 *  @brief  客户端从从application:didReceiveRemoteNotification接收到apns消息时的应用状态
 */
@property(nonatomic, assign, readonly) UIApplicationState applicationState;

/*!
 *  @brief  apns原始NSDictionary
 *  @note   appdelegate从application:didFinishLaunchingWithOptions启动参数
 *  @note   appdelegate从application:didReceiveRemoteNotification入口参数
 */
@property(nonatomic, strong, readonly) NSDictionary *apnsDict;

#pragma mark - apnsDict包装快捷方法
/*!
 *  @brief APNS角标
 *
 *  @return
 */
-(NSNumber*)badge;

/*!
 *  @brief APNS提示音
 *
 *  @return
 */
-(NSString*)sound;

/*!
 *  @brief  获取apns的消息标题
 *
 *  @return alertTitle的KeyPath为: aps.alert.title
 */
-(NSString*)alertTitle;

/*!
 *  @brief  获取apns的消息体
 *  @note   alertBody的KeyPath为: aps.alert.body
 *
 *  @return
 */
-(NSString*)alertBody;

/*!
 *  @brief  获取apns中自定义payload部分: payload兼容NSDictionary和NSString
 *  @note   payload为自定义key数据  payload的KeyPath为: aps.payload
 *
 */
-(NSDictionary*)payload;


#pragma mark - 重写description
/*!
 *  @brief ALAPNSMsg
 *
 *  @return APNS消息描述
 */
-(NSString*)description;

@end
