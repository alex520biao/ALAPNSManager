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
@class ALDictionaryRouter;
@class ALNode;

/*!
 *  @brief Dict消息分发消息
 *
 *  @param dict消息
 *
 *  @return
 */
typedef id (^ALDictEventHandler)(ALDictEvent *msg,ALNodeFilter *filter);


/*!
 *  @brief 是否向将此APNS消息进入发布流程
 *
 *  @param manager
 *  @param msg
 */
typedef BOOL (^ALDictionaryRouterShouldPublishBlock)(ALDictionaryRouter *router,ALDictEvent *msg);

/*!
 *  @brief 是否向将此APNS消息进入发布流程
 *
 *  @param manager
 *  @param msg
 */
typedef void (^ALDictionaryRouterDidPublishedBlock)(ALDictionaryRouter *router,ALDictEvent *msg,NSArray<ALNodeFilter *>*filters);


/**
 *  按照subscribe/publish(订阅/发布)模式实现的Dictionary消息Router
 *  使用KeyPath对Dictionary进行路径匹配(Path Matching),匹配规则为完全匹配
 *  Dictionary的限制: key是NSString类型,value为简单类型或数值类型,即JSON字符串对应的字典。
 *
 */
@interface ALDictionaryRouter : NSObject


/**
 构造ALDictionaryRouter

 @param shouldPublish 拦截需要分发的消息block,此拦截器可用于数据过滤及日志统计
 @param didPublished  接收到此消息的对象集合block,可用于日志统计

 @return
 */
+(ALDictionaryRouter*)routerWithShouldPublish:(ALDictionaryRouterShouldPublishBlock)shouldPublish
                                 didPublished:(ALDictionaryRouterDidPublishedBlock)didPublished;

/*!
 *  @brief APNS消息注册监听树
 */
@property (nonatomic,strong) ALNode *rootNode;

@property (nonatomic, copy) ALDictionaryRouterShouldPublishBlock shouldPublish;
@property (nonatomic, copy) ALDictionaryRouterDidPublishedBlock didPublished;

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
 progress与response通过异步方式回调
 
 response有可能有多个回调,因为有可能多个对象在监听此消息，因此消息发布者有可能会收到多个回应

 @param dict 
 */
- (void)publishDictionary:(NSDictionary *)msg
             withUserInfo:(NSDictionary *)userInfo
                 progress:(ALDictProgressBlcok)progress
                 response:(ALDictResponseBlcok)response;



@end
