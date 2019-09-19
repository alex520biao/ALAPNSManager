//
//  APNSManager.m
//  Pods
//
//  Created by alex520biao on 15/11/7.
//
//

#import "ALAPNSManager.h"
#import "ALAPNSMsg.h"
#import "ALNode.h"
#import "ALAPNSTool.h"

#define kAPNS_deviceToken    @"APNS_deviceToken"

@interface ALAPNSManager ()

/*!
 *  @brief  deviceToken
 */
@property(nonatomic ,copy, readwrite)NSString * deviceToken;

/*!
 *  @brief APNS消息注册监听树
 */
@property (nonatomic,strong) ALNode *rootNode;


/*!
 *  @brief 启动APNS消息
 *  @note  launAPNSMsg不为空说明当前应用是由APNS启动
 */
@property (nonatomic,strong,readwrite) ALAPNSMsg *launAPNSMsg;

/*!
 *  @brief launAPNSMsg不为空时，launAPNSMsgHandled用于表示启动APNS是否已经分发过
 *  @note  launAPNSMsgHandled NO==启动消息为分发, YES==启动消息已分发，初始为NO
 */
@property (nonatomic,assign,readwrite) BOOL launAPNSMsgHandled;


@end

@implementation ALAPNSManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        //从本地读取
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSString *deviceToken =[defaults objectForKey:kAPNS_deviceToken];
        if(deviceToken){
            _deviceToken = deviceToken;
        }
    }
    return self;
}

 /*!
 *  @brief  默认定义APNS通知
 */
- (void)registerForRemoteNotification {
    RemoteNotificationType types = (RemoteNotificationTypeBadge |
                                    RemoteNotificationTypeSound |
                                    RemoteNotificationTypeAlert);
    [self registerForRemoteNotification:types
                             categories:nil];
}

/*!
 *  @brief  自定义APNS通知提示样式
 *
 *  @param type       APNS提示样式
 *  @param categories iOS8开始支持
 */
- (void)registerForRemoteNotification:(RemoteNotificationType)type
                           categories:(NSSet<UIUserNotificationCategory *> *)categories{
    //8.0以后使用这种方法来注册推送通知
    if (iOS8AndAbove &&[[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        
        UIUserNotificationType userNotificationType = UIUserNotificationTypeNone;
        if ((type & RemoteNotificationTypeBadge)) {
            //累加
            userNotificationType |= UIUserNotificationTypeBadge;
        }
        if ((type & RemoteNotificationTypeSound)) {
            //累加
            userNotificationType |= UIUserNotificationTypeSound;
        }
        if ((type & RemoteNotificationTypeAlert)) {
            //累加
            userNotificationType |= UIUserNotificationTypeAlert;
        }
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationType
                                                                                 categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType remoteNotificationType = UIRemoteNotificationTypeNone;
        if ((type & RemoteNotificationTypeBadge)) {
            //累加
            remoteNotificationType |= UIRemoteNotificationTypeBadge;
        }
        if ((type & RemoteNotificationTypeSound)) {
            //累加
            remoteNotificationType |= UIRemoteNotificationTypeSound;
        }
        if ((type & RemoteNotificationTypeAlert)) {
            //累加
            remoteNotificationType |= UIRemoteNotificationTypeAlert;
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:remoteNotificationType];
    }
}

#pragma mark - deviceToken
/*!
 *  @brief 接收并存储deviceToken
 *
 *  @param deviceToken
 *
 *  @return 是否有变化(有变法则需要发送网络请求将deviceToken提交到push provider推送服务器)
 */
- (BOOL)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [[deviceToken description]
                       stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    
    //deviceToken有变化则需修改本地及提交到服务器
    if(![self.deviceToken isEqualToString:token]){
        self.deviceToken = token;

        //存储于本地
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:self.deviceToken forKey:kAPNS_deviceToken];//设置
        [defaults synchronize];
        
        //返回YES表示deviceToken有变化,需要发送网络请求将deviceToken提交到push provider(业务服务器)
        return YES;
    }
    return NO;
}

/*!
 *  @brief  删除并置空当前deviceToken
 */
- (void)deleteDeviceToken{
    //删除本地deviceToken
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAPNS_deviceToken];
    [defaults synchronize];

    //发送网络请求到push provider(业务服务器)删除deviceToken
    //todo 调用deleteDeviceToken方法时同时进行
}

#pragma mark - 监听项数据管理
-(ALNode*)rootNode{
    if (!_rootNode) {
        _rootNode = [[ALNode alloc] init];
        _rootNode.rootNode = YES;
    }
    return _rootNode;
}

#pragma mark - other
/*!
 *  @brief 是否实现旧方法
 *
 *  @return
 */
-(BOOL)oldMethodDidReceiveRemoteNotification{
    id appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:)]){
        return YES;
    }
    return NO;
}

/*!
 *  @brief  接收并处理启动应用程序时的APNSMsg
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *  @param handle 是否需要继续分发处理
 *
 */
-(void)receivedAPNSMsgWithLaunchOptions:(NSDictionary*)launchOptions needHandle:(BOOL)needHandle{
    //封装
    ALAPNSMsg *msg = [ALAPNSMsg apnsMsgWithLaunchOptions:launchOptions];
    if (msg) {
        //启动apns消息无需分发处理,仅需记录即可
        self.launAPNSMsg = msg;
        self.launAPNSMsgHandled = NO;
    }
    
    //needHandle为YES则需要处理
    if(needHandle){
        dispatch_async(dispatch_get_main_queue(), ^{
            //分发
            [self handleAPNSMsg:msg];
        });
    }
}

//调用系统application_didiReceiveRemoteNotification_fetchCompletionHandler方法
-(void)application_didiReceiveRemoteNotification_fetchCompletionHandler:(NSDictionary*)launchOptions{
    //启动系统会调用application:didReceiveRemoteNotification:remoteDictfetchCompletionHandler:
    NSDictionary *remoteDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate application:[UIApplication sharedApplication] didReceiveRemoteNotification:remoteDict fetchCompletionHandler:^(UIBackgroundFetchResult result) {
        //fetchCompletionHandler无法模拟
    }];
}


#pragma mark - ALAPNSManagerSubProtocol - 实现订阅协议
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
               handler:(ALAPNSMsgHandler)handler{
    
    ALNodeFilter *filter = [[ALNodeFilter alloc] init];
    filter.observer     = observer;
    filter.block        = handler;
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
-(void)removeAPNSPattern:(ALKeyPath *)keyPath
             filterValue:(NSString*)value
                observer:(id)observer{
    
    ALNodeFilter *filter = [[ALNodeFilter alloc] init];
    filter.observer     = observer;
    filter.filterValue  = value;
    filter.block        = nil;
    [self.rootNode removeNodeFilter:filter atKeyPath:keyPath];
}

#pragma mark - ALAPNSManagerPubProtocol  - 实现发布协议
/*!
 *  @brief  接收并处理启动应用程序时的APNSMsg
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 */
-(void)handleAPNSMsgWithLaunchOptions:(NSDictionary*)launchOptions{
    //如果appDelegate未实现旧方法则需要模拟系统从新方法传递apns消息。反之则无需调用
    //appDelegate实现了iOS7新方法，则优先通过通过application:didReceiveRemoteNotification:fetchCompletionHandlerl处理
    if(![self oldMethodDidReceiveRemoteNotification]){
        //launchOptions只记录不处理, needHandle==NO
        [self receivedAPNSMsgWithLaunchOptions:launchOptions needHandle:NO];
        
        //延时调用application:didReceiveRemoteNotification:fetchCompletionHandler:
        [self performSelector:@selector(application_didiReceiveRemoteNotification_fetchCompletionHandler:)
                   withObject:launchOptions
                   afterDelay:0.3];
    }else{
        //只有iOS7以前旧方法，则launchOptionsx需要立即被处理needHandle==YES
        //通过apns消息启动应用
        [self receivedAPNSMsgWithLaunchOptions:launchOptions needHandle:YES];
    }
}

/*!
 *  @brief  接收并处理application:didReceiveRemoteNotification的APNSMsg消息
 *
 *  @param  remoteDict appdelegate从application:didReceiveRemoteNotification入口参数
 *
 */
-(void)handleAPNSMsgWithDidReceiveRemoteNotification:(NSDictionary*)remoteDict{
    ALAPNSMsg *msg = nil;
    //launAPNSMsgHandled为NO
    if (self.launAPNSMsg && !self.launAPNSMsgHandled) {
        //继续分发启动APNS消息 launAPNSMsg
        msg = [[ALAPNSMsg alloc] initWithSceneType:self.launAPNSMsg.sceneType
                                          apnsDict:remoteDict
                                  applicationState:self.launAPNSMsg.applicationState];
        
        //launAPNSMsgHandled标注此消息已经处理
        self.launAPNSMsgHandled = YES;
    }else{
        //非启动APNS消息
        msg = [ALAPNSMsg apnsMsgWithDidReceiveRemoteNotification:remoteDict];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //分发
        [self handleAPNSMsg:msg];
    });
}

/*!
 *  @brief 分发处理APNSMsg
 *
 *  @param msg
 */
-(void)handleAPNSMsg:(ALAPNSMsg*)msg{
    //should默认为YES
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(apnsManager:shouldPublishAPNSMsg:)]) {
        should = [self.delegate apnsManager:self shouldPublishAPNSMsg:msg];
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
        NSString *strValue = [msg.apnsDict al_stringForKeyPath:keyPath];
        if (strValue) {
            ALNode *node = [self.rootNode nodeForKeyPath:keyPath];
            
            for (int j =0; j<node.nodeFilters.count; j++) {
                ALNodeFilter * filter = [node.nodeFilters objectAtIndex:j];
                //observer不能为nil
                if (filter.observer && filter.filterValue && [strValue isEqualToString:filter.filterValue]) {
                    if (filter.block) {
                        filter.block(msg);
                        
                        [filters addObject:filter];
                    }
                }
            }
        }
    }
    
    //发布完成
    if ([self.delegate respondsToSelector:@selector(apnsManager:didPublishAPNSMsg:filter:)]) {
        [self.delegate apnsManager:self
                 didPublishAPNSMsg:msg
                            filter:filters];
    }
}

@end
