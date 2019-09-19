//
//  UILocalNotification+ALExtensions.h
//  Pods
//
//  Created by alex520biao on 16/5/5. Maintain by alex520biao
//
//

#import <UIKit/UIKit.h>

/*!
 *  @brief UILocalNotification触发方式
 *  @note  此属性仅在launch为NO时生效
 */
typedef NS_ENUM(NSInteger, ALLocNotifiTriggerMode) {
    //未知
    ALLocNotifiTriggerMode_Unkonw,
    //用户从消息中心或本地消息提示点击触发
    ALLocNotifiTriggerMode_UserClick,
    //计时器触发
    ALLocNotifiTriggerMode_Timer
};

@interface UILocalNotification (ALExtensions)

/*!
 *  @brief launch为YES,则此本地通过启动应用
 */
@property (nonatomic, assign) BOOL launch;

/*!
 *  @brief  客户端接收到UILocalNotification时应用所处瞬间状态
 *  @note   用户通过UILocalNotification启动应用及应用处于后台时用户点击本地通知唤起应用到前台,这两种场景al_applicationStatus均为UIApplicationStateInactive
 *          如果al_applicationStatus为UIApplicationStateActive,则说明应用处于前台时接收到UILocalNotification(并非用户点击系统本地通知提示)
 */
@property (nonatomic, assign) UIApplicationState al_applicationStatus;

/*!
 *  @brief 应用接收到UILocalNotification的时间
 */
@property (nonatomic, strong) NSDate *receiveDate;

/*!
 *  @brief 获取UILocalNotification的触发方式
 *  @note  判断fireDate与当前时间的时间差. 如果时间差非常小说明是系统timer触发，如果有一定时间差则说明是用户从消息提示及消息中心点击进入
 *  @return
 */
-(ALLocNotifiTriggerMode)triggerMode;

/*!
 *  @brief 格式化输出ALExtensions信息
 *  @note  方便test、log等操作
 *
 *  @return
 */
-(NSString*)al_extenDescription;





@end
