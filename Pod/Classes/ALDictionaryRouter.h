//
//  ALDictionaryRouter.h
//  Pods
//
//  Created by alex on 2016/12/3.
//
//

#import <Foundation/Foundation.h>
#import "ALNode.h"
#import "ALDictEvent.h"

/*!
 *  @brief Dict消息分发消息
 *
 *  @param dict消息
 *
 *  @return
 */
typedef id (^ALDictEventHandler)(ALDictEvent *msg);


@class ALNode;

@interface ALDictionaryRouter : NSObject

/*!
 *  @brief APNS消息注册监听树
 */
@property (nonatomic,strong) ALNode *rootNode;

/*!
 *  @brief 订阅一个监听项
 *  @note  相同的observer、相同keyPath、相同value，则覆盖只保留最后一次监听
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 *  @param handler  监听者回调
 */
- (void)subscribePattern:(ALKeyPath *)keyPath
       filterValue:(NSString *)value
          observer:(id)observer
           handler:(ALDictEventHandler)handler;

/*!
 *  @brief 取消一个监听项
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 */
-(void)removeAPNSPattern:(ALKeyPath *)keyPath
             filterValue:(NSString*)value
                observer:(id)observer;


/**
 发布NSDictionary消息
 completed异步回调
 
 completed有可能有多个回调,因为有可能多个对象在监听此消息，因此消息发布者有可能会收到多个回应

 @param dict 
 */
- (void)publishDictionary:(NSDictionary *)msg
             withUserInfo:(NSDictionary *)userInfo
                 progress:(ALDictProgressBlcok)progress
                 response:(ALDictResponseBlcok)response;



@end
