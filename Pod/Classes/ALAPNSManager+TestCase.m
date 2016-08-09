//
//  ALAPNSManager+TestCase.m
//  Pods
//
//  Created by alex520biao on 16/7/19.
//
//

#import "ALAPNSManager+TestCase.h"

@implementation ALAPNSManager (TestCase)

#pragma mark - TEST
/*!
 *  @brief 模拟APNS消息启动app所需launchOptions
 *  @note  可在application:didFinishLaunchingWithOptions中给launchOptions赋值用于模拟APNS消息启动app
 *
 *  @return
 */
+(NSMutableDictionary*)launchOptionsWithRemoteNotification_TestWebPage{
    //测试webPage的APNS消息
    NSString *str = @"{\"aps\":{\"alert\":\"your message here.\",\"badge\":9,\"sound\":\"default\"},\"acme1\":\"bar\",\"acme2\":42,\"payload\":{\"lt\":259,\"aid\":\"100333\",\"ty\":100,\"lv\":\"http://www.hao123.com/\",\"content\":\"\\u8fd9\\u662f\\u6d4b\\u8bd5\\u6d88\\u606f\"}}";
    
    NSMutableDictionary *launchOptions = [ALAPNSManager launchOptionsWithRemoteJSON:str];
    return launchOptions;
}

/*!
 *  @brief  根据remoteJSON构造launchOptions
 *
 *  @param remoteJSON
 *
 *  @return
 */
+(NSMutableDictionary*)launchOptionsWithRemoteJSON:(NSString*)remoteJSON{
    NSMutableDictionary *launchOptions = nil;
    if(remoteJSON){
        NSData* remoteData = [remoteJSON dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableDictionary *remoteDict = [NSJSONSerialization JSONObjectWithData:remoteData
                                                                          options:NSJSONReadingMutableLeaves
                                                                            error:&error];
        
        if(remoteDict && !error){
            launchOptions = [NSMutableDictionary dictionaryWithObject:remoteDict
                                                               forKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        }
    }
    return launchOptions;
}

@end
