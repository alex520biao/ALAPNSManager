//
//  ALAPNSManager+TestCase.h
//  Pods
//
//  Created by alex520biao on 16/7/19.
//
//

#import <ALAPNSManager/ALAPNSManager.h>

@interface ALAPNSManager (TestCase)

#pragma mark - TEST
/*!
 *  @brief 模拟APNS消息启动app所需launchOptions
 *  @note  可在application:didFinishLaunchingWithOptions中给launchOptions赋值用于模拟APNS消息启动app
 *
 *  @return
 */
+(NSMutableDictionary*)launchOptionsWithRemoteNotification_TestWebPage;

/*!
 *  @brief  根据remoteJSON构造launchOptions
 *
 *  @param remoteJSON 格式必须是APNS标准格式
 *
 *  @return
 */
+(NSMutableDictionary*)launchOptionsWithRemoteJSON:(NSString*)remoteJSON;


/*!
 *  @brief 测试APNS启动应用
 *
 *  @param launchOptions
 *  @param apnsManager
 */
-(void)test_APNSMsgWithLaunchOptions:(NSDictionary*)launchOptions;



@end
