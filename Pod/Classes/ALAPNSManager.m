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
 *  @brief 用于临时存储当前存在监听者的KeyPath集合,有新消息来时则可以遍历检查此集合满足条件则进行监听响应
 */
@property (nonatomic) NSMutableArray *tempArray;


@end

@implementation ALAPNSManager

+ (instancetype) sharedInstance{
    static ALAPNSManager * __sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] init];
    });
    return __sharedInstance;
}

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

/*!
 *  @brief 遍历树获得所有监听项
 *
 *  @return 当前所有监听项
 */
-(NSMutableArray*)iteratorRouteNode{
    //获取所有存在监听项的节点
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self iteratorDictionary:self.rootNode
                   tempArray:tempArray
                       array:[NSMutableArray array]];
    return tempArray;
}

/*!
 *  @brief 递归查询存在block的KeyPath
 *
 *  @param dict      查询的当前节点
 *  @param tempArray 保存所有监听项
 *  @param pathList  临时路径数组
 */
-(void)iteratorDictionary:(ALNode*)node tempArray:(NSMutableArray*)tempArray array:(NSMutableArray*)pathList{
    //非根节点且nodeName不为空，保存nodeName到pathList中
    if (!node.rootNode && node.nodeName) {
        [pathList addObject:node.nodeName];
        
        //此节点有监听者,则保存此keyPath到tempArray
        if (node.nodeFilters && node.nodeFilters.count>0) {
            NSString *keyPath = [ALAPNSTool keyPathWithArray:pathList];
            [tempArray addObject:keyPath];
        }
    }
    
    //非叶子节点
    if (![node leafNode]) {
        [node.subNodes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //obj为node节点
            if ([obj isKindOfClass:[ALNode class]]) {
                ALNode *subNode = (ALNode*)obj;
                if (subNode.nodeName && subNode.nodeName.length>0) {
                    //递归查询子节点,需要新建pathList数组
                    NSMutableArray *list = [NSMutableArray arrayWithArray:pathList];
                    [self iteratorDictionary:subNode tempArray:tempArray array:list];
                }
            }
        }];
    }
}

#pragma mark - Observer监听注册管理
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

#pragma mark - handleAPNSMsg
/*!
 *  @brief  接收并处理启动应用程序时的APNSMsg
 *
 *  @param launchOptions appdelegate从application:didFinishLaunchingWithOptions启动参数
 *
 */
-(void)handleAPNSMsgWithLaunchOptions:(NSDictionary*)launchOptions{
    //封装
    ALAPNSMsg *msg = [ALAPNSMsg apnsMsgWithLaunchOptions:launchOptions];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //分发
        [self handleAPNSMsg:msg];
    });
}

/*!
 *  @brief  接收并处理正常情况下接收的APNSMsg消息
 *
 *  @param  remoteDict appdelegate从application:didReceiveRemoteNotification入口参数
 *
 */
-(void)handleAPNSMsgWithDidReceiveRemoteNotification:(NSDictionary*)remoteDict{
    //封装
    ALAPNSMsg *msg = [ALAPNSMsg apnsMsgWithDidReceiveRemoteNotification:remoteDict];
    
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
    NSMutableArray *tempArray = [self iteratorRouteNode];
    
    //filters临时存储此消息接收者
    NSMutableArray<ALNodeFilter*> *filters = [[NSMutableArray<ALNodeFilter*> alloc] init];
    
    //self.tempArray为所有监听项
    for (int i = 0 ; i<tempArray.count; i++) {
        NSString *keyPath = [tempArray objectAtIndex:i];
        
        @try {
            //此消息是否满足监听条件一
            id obj = [msg.apnsDict valueForKeyPath:keyPath];
            NSString *strValue = nil;
            if ([obj isKindOfClass:[NSString class]]) {
                strValue = (NSString*)obj;
            }else if(obj && [obj respondsToSelector:@selector(stringValue)]){
                strValue = [obj stringValue];
            }
            
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
        @catch (NSException *exception) {
            //未找到此KeyPath路径
            //NSLog(@"exception: %@",exception.name);
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
