//
//  ALLocNotifiManager.m
//  Pods
//
//  Created by alex520biao on 16/9/30.
//
//

#import "ALLocNotifiManager.h"
#import "ALNode.h"
#import "ALNode.h"
#import "ALAPNSTool.h"
#import "UILocalNotification+ALExtensions.h"

@interface ALLocNotifiManager ()

/*!
 *  @brief APNS消息注册监听树
 */
@property (nonatomic,strong) ALNode *rootNode;

/*!
 *  @brief 启动应用的本地通知UILocalNotification
 */
@property (nonatomic,strong) UILocalNotification *launLocNotifi;

@end

@implementation ALLocNotifiManager

#pragma mark - 监听项数据管理
-(ALNode*)rootNode{
    if (!_rootNode) {
        _rootNode = [[ALNode alloc] init];
        _rootNode.rootNode = YES;
    }
    return _rootNode;
}


#pragma mark - Observer监听注册管理
/*!
 *  @brief 添加一个监听项
 *  @note  ALNodeFilter完全相同: 即相同observer、相同keyPath、相同value，则覆盖只保留最后一次监听
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 *  @param handler  监听者回调
 */
- (void)addLocNotifiPattern:(ALKeyPath *)keyPath
                filterValue:(NSString *)value
                   observer:(id)observer
                    handler:(ALLocalNotificationHandler)handler{
    ALNodeFilter *filter = [[ALNodeFilter alloc] init];
    filter.observer     = observer;
    filter.block        = (ALAPNSMsgHandler)handler;
    filter.filterValue  = value;
    [self.rootNode insertOrUpdate:filter atKeyPath:keyPath];
}

/*!
 *  @brief 删除一个监听项
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 */
-(void)removeLocNotifiPattern:(ALKeyPath *)keyPath
                  filterValue:(NSString*)value
                     observer:(id)observer{
    
    ALNodeFilter *filter = [[ALNodeFilter alloc] init];
    filter.observer     = observer;
    filter.filterValue  = value;
    filter.block        = nil;
    [self.rootNode removeNodeFilter:filter atKeyPath:keyPath];
}

/*!
 *  @brief  接收并处理启动应用程序时的UILocalNotification
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 */
-(void)handleLocNotifiWithLaunchOptions:(NSDictionary*)launchOptions{
    UILocalNotification *locNotifi = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locNotifi) {
        //记录UILocalNotification到达客户端时应用所处状态
        locNotifi.al_applicationStatus = [UIApplication sharedApplication].applicationState;
        //UILocalNotification启动应用
        locNotifi.launch = YES;
        //记录应用接收到消息的时间戳
        locNotifi.receiveDate = [NSDate date];
        self.launLocNotifi = locNotifi;
        
        //分发
        [self handleLocNotifi:locNotifi];
    }
}

/*!
 *  @brief  接收并处理正常情况下接收的UILocalNotification
 *
 *  @param  locNotifi appdelegate从application:didReceiveLocalNotification入口参数
 *  @param  applicationStatus 应用接收到UILocalNotification时所处状态
 *
 */
-(void)handleLocNotifiWithDidReceiveRemoteNotification:(UILocalNotification*)locNotifi applicationStatus:(UIApplicationState)applicationStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        locNotifi.al_applicationStatus = applicationStatus;
        //记录应用接收到消息的时间戳
        locNotifi.receiveDate = [NSDate date];

        //分发
        [self handleLocNotifi:locNotifi];
    });
}

/*!
 *  @brief 分发处理LocNotifi
 *
 *  @param msg
 */
-(void)handleLocNotifi:(UILocalNotification*)msg{
    //should默认为YES
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(locNotifiManager:shouldPublishLocNotifi:)]) {
        should = [self.delegate locNotifiManager:self shouldPublishLocNotifi:msg];
    }
    
    //should为NO则直接丢弃此消息
    if(!should){
        return;
    }

    //遍历树获得所有监听项
    NSMutableArray<ALKeyPath *> *tempArray = [self.rootNode iteratorRouteNode];
    
    //filters临时存储此消息接收者
    NSMutableArray<ALNodeFilter*> *filters = [[NSMutableArray<ALNodeFilter*> alloc] init];
    
    //tempArray为所有监听项
    for (int i = 0 ; i<tempArray.count; i++) {
        NSString *keyPath = [tempArray objectAtIndex:i];
        
        //获取keyPath对应的strValue
        NSString *strValue = [msg.userInfo al_stringForKeyPath:keyPath];
        if (strValue) {
            ALNode *node = [self.rootNode nodeForKeyPath:keyPath];
            
            for (int j =0; j<node.nodeFilters.count; j++) {
                ALNodeFilter * filter = [node.nodeFilters objectAtIndex:j];
                //observer不能为nil
                if (filter.observer && filter.filterValue && [strValue isEqualToString:filter.filterValue]) {
                    ALLocalNotificationHandler block = (ALLocalNotificationHandler)filter.block;
                    if (block) {
                        block(msg);
                        
                        [filters addObject:filter];
                    }
                }
            }
        }
    }
    
    //发布完成
    if ([self.delegate respondsToSelector:@selector(locNotifiManager:didPublishLocNotifi:filter:)]) {
        [self.delegate locNotifiManager:self
                    didPublishLocNotifi:msg
                                 filter:filters];
    }
}



@end
