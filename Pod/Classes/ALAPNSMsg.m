//
//  APNSMsg.m
//  DiTravel
//
//  Created by alex520biao on 25/3/15.
//  Copyright (c) 2015年 didi inc. All rights reserved.
//

#import "ALAPNSMsg.h"
#import "ALAPNSTool.h"

@interface ALAPNSMsg ()

/*!
 *  @brief  APNS消息传递到客户端的场景
 */
@property(nonatomic, assign, readwrite) APNSMsgSceneType sceneType;

@property(nonatomic, strong, readwrite) NSDictionary *apnsDict;

@property(nonatomic, assign, readwrite) UIApplicationState applicationState;

@end

@implementation ALAPNSMsg


/*!
 *  @brief  apns启动应用程序
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 *  @return
 */
+(ALAPNSMsg*)apnsMsgWithLaunchOptions:(NSDictionary*)launchOptions{
    //通过apns消息启动应用
    ALAPNSMsg *msg = nil;
    NSDictionary *remoteDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteDict){
        msg = [[ALAPNSMsg alloc] initWithSceneType:APNSMsgSceneType_Launch
                                        apnsDict:remoteDict
                                applicationState:[UIApplication sharedApplication].applicationState];
    }
    return msg;
}

/*!
 *  @brief  其他情况apns消息
 *
 *  @param  remoteDict appdelegate从application:didReceiveRemoteNotification入口参数
 *
 *  @return
 */
+(ALAPNSMsg*)apnsMsgWithDidReceiveRemoteNotification:(NSDictionary*)remoteDict{
    //头文件中有APNSMsgSceneType详细注释
    APNSMsgSceneType sceneType = APNSMsgSceneType_Active;
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        /*
         应用处在后台，并且还在执行代码。
         */
        sceneType = APNSMsgSceneType_Awake;
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
        /*
         UIApplicationStateInactive为当前应用正在前台运行，但是并不接收事件。
         每当应用要从一个状态切换到另一个不同的状态时，中途过渡会短暂停留在此状态。
         唯一在此状态停留时间比较长的情况是：当用户锁屏时，用户拉出通知中心列表时或者系统提示用户去响应某些（诸如电话来电、有未读短信等）事件的时候。
         */
        sceneType = APNSMsgSceneType_Awake;
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        /*
         当前应用正在前台运行，并且接收事件。
         */
        sceneType = APNSMsgSceneType_Active;
    }
    
    ALAPNSMsg *msg = [[ALAPNSMsg alloc] initWithSceneType:sceneType
                                             apnsDict:remoteDict
                                     applicationState:[UIApplication sharedApplication].applicationState];
    return msg;
}

- (instancetype)initWithSceneType:(APNSMsgSceneType)sceneType
                         apnsDict:(NSDictionary*)apnsDict
                 applicationState:(UIApplicationState)state
{
    self = [super init];
    if (self) {
        _sceneType = sceneType;
        _apnsDict = apnsDict;
        _applicationState = state;
    }
    return self;
}

#pragma mark - apnsDict包装快捷方法
/*!
 *  @brief APNS角标
 *
 *  @return
 */
-(NSNumber*)badge{
    NSNumber *badge = nil;
    if (self.apnsDict && [self.apnsDict objectForKey:@"aps"]) {
        badge = [[self.apnsDict objectForKey:@"aps"] objectForKey:@"badge"];
    }
    return badge;
}

/*!
 *  @brief APNS提示音
 *
 *  @return
 */
-(NSString*)sound{
    NSString *sound = nil;
    if (self.apnsDict && [self.apnsDict objectForKey:@"aps"]) {
        sound = [[self.apnsDict objectForKey:@"aps"] objectForKey:@"sound"];
    }
    return sound;
}

-(NSString*)alertTitle{
    NSString *str = nil;
    if (self.apnsDict && [self.apnsDict objectForKey:@"aps"]) {
        id alert = [[self.apnsDict objectForKey:@"aps"] objectForKey:@"alert"];
        if ([alert isKindOfClass:[NSDictionary class]]){
            NSDictionary *dict = (NSDictionary*)alert;
            str = (NSString*)[dict objectForKey:@"title"];
        }
    }
    return str;
}

-(NSString*)alertBody{
    NSString *str = nil;
    if (self.apnsDict && [self.apnsDict objectForKey:@"aps"]) {
        id alert = [[self.apnsDict objectForKey:@"aps"] objectForKey:@"alert"];
        if([alert isKindOfClass:[NSString class]]){
            str = (NSString*)alert;
        }else if ([alert isKindOfClass:[NSDictionary class]]){
            NSDictionary *dict = (NSDictionary*)alert;
            str = (NSString*)[dict objectForKey:@"body"];
        }
    }
    return str;
}

/*!
 *  @brief  获取apns中自定义payLoad部分
 *  @note   payload为自定义key数据
 *
 */
-(NSDictionary*)payload{
    if (self.apnsDict && [self.apnsDict isKindOfClass:[NSDictionary class]]) {
        id payload = [self.apnsDict objectForKey:@"payload"];
        if([payload isKindOfClass:[NSDictionary class]]) {
            return payload;
        }else if ([payload isKindOfClass:[NSString class]]) {
            NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *retPayLoad = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            return retPayLoad;
        }
        return nil;
    }
    return nil;
}

//APNSMsgSceneType转换为NSString
#define APNSMsgSceneType_TO_STRING(enumType)  [NSString stringWithCString:APNSMsgSceneType_CSTR(enumType) encoding:NSASCIIStringEncoding]
#define APNSMsgSceneType_TO_CSTR_CASE(enumType)   case enumType: return(#enumType);
const char *APNSMsgSceneType_CSTR(APNSMsgSceneType type) {
    switch (type) {
            APNSMsgSceneType_TO_CSTR_CASE(APNSMsgSceneType_Launch)
            APNSMsgSceneType_TO_CSTR_CASE(APNSMsgSceneType_Awake)
            APNSMsgSceneType_TO_CSTR_CASE(APNSMsgSceneType_Active)
        default:break;
    }
}

-(NSString*)description{
    NSString *description = [super description];
    if (description) {
        description = [NSString stringWithFormat:@"%@ \n sceneType: %@ \n apns: %@",
                       description,APNSMsgSceneType_TO_STRING(self.sceneType),[self.apnsDict description]];
    }

    return description;
}

@end
