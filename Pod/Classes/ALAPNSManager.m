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

#define iOS8AndAbove                        ([[UIDevice currentDevice].systemVersion floatValue] >= 8.f)
#define kAPNS_deviceToken    @"APNS_deviceToken"

static NSString * const ALNODE_NODENAME = @"__ALNODE_NODENAME__";

static NSString * const ALNODE_BLOCK = @"__ALNODE_BLOCK__";

static NSString * const ALNODE = @"__ALNODE__";


//监听者
static NSString * const ALNODE_OBSERVER = @"__ALNODE_OBSERVER__";

//过滤值
static NSString * const ALNODE_FilterValue = @"__ALNODE_FilterValue__";

static NSString * const ALNODE_Filter = @"__ALNODE_Filter__";

//通配符
static NSString * const ALURL_WILDCARD_CHARACTER = @"~";

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
        
        
        _tempArray = [NSMutableArray array];
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
 *  @brief 从self.routes树中查找keyPath对应的节点项node
 *
 *  @param url
 *
 *  @return
 */
- (ALNode *)nodeFromKeyPath:(ALKeyPath *)keyPath{
    ALNode* subNode = self.rootNode;
    NSArray* pathComponents = [self pathComponentsFromKeyPath:keyPath];
    
    // borrowed from HHRouter(https://github.com/Huohua/HHRouter)
    for (NSString* pathComponent in pathComponents) {
        BOOL found = NO;
        
        // 对 key 进行排序，这样可以把 ~ 放到最后
        NSArray *subRoutesKeys =[subNode.subNodes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        for (NSString* key in subRoutesKeys) {
            //根据subNodeName获取subNode
            if ([key isEqualToString:pathComponent] || [key isEqualToString:ALURL_WILDCARD_CHARACTER]) {
                found = YES;
                subNode = [subNode subNodeForName:key];
                break;
            }
        }
        // 如果没有找到该pathComponents对应的node,则直接返回nil
        if (!found) {
            subNode = nil;
            break;
        }
    }
    return subNode;
}


/*!
 *  @brief KeyPath字符串截取
 *
 *  @param keyPath
 *
 *  @return 数组pathComponents
 */
- (NSArray*)pathComponentsFromKeyPath:(ALKeyPath*)keyPath{
    NSArray *pathComponents = [keyPath componentsSeparatedByString:@"."];
    return [pathComponents copy];
}

/*!
 *  @brief pathList转换为KeyPath字符串
 *
 *  @param list
 *
 *  @return
 */
-(NSString*)keyPathWithArray:(NSArray*)list{
    return [list componentsJoinedByString:@"."];
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
    }
    
    //此节点有监听者,则保存此keyPath到tempArray
    if (node.nodeFilters && node.nodeFilters.count>0) {
        NSString *keyPath = [self keyPathWithArray:pathList];
        [tempArray addObject:keyPath];
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
    
    NSArray *pathComponents = [self pathComponentsFromKeyPath:keyPath];
    NSInteger index = 0;
    
    ALNode *node = self.rootNode;
    while (index < pathComponents.count) {
        NSString* pathComponent = pathComponents[index];
        
        //检查子节点是否存在
        if (![node.subNodes objectForKey:pathComponent]) {
            ALNode *subNode = [[ALNode alloc] init];
            subNode.nodeName = pathComponent;
            [node.subNodes setObject:subNode forKey:pathComponent];
        }
        
        node = [node subNodeForName:pathComponent];
        
        //pathComponents数组最后一个则为监听项，增加NodeFilter
        if (index == pathComponents.count-1 && handler && node) {
            ALNodeFilter *filter = [[ALNodeFilter alloc] init];
            filter.observer     = observer;
            filter.block        = handler;
            filter.filterValue  = value;
            //插入或更新
            [node insertOrUpdate:filter];
        }
        
        index++;
    }
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
    
    //分发
    [self handleAPNSMsg:msg];
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
    
    //分发
    [self handleAPNSMsg:msg];
}

/*!
 *  @brief 分发处理APNSMsg
 *
 *  @param msg
 */
-(void)handleAPNSMsg:(ALAPNSMsg*)msg{
    //遍历树获得所有监听项
    NSMutableArray *tempArray = [self iteratorRouteNode];
    
    //self.tempArray为所有监听项
    for (int i = 0 ; i<tempArray.count; i++) {
        NSString *keyPath = [tempArray objectAtIndex:i];
        
        @try {
            //此消息是否满足监听条件一
            id obj = [msg.apnsDict valueForKeyPath:keyPath];
            if (obj && [obj respondsToSelector:@selector(stringValue)]) {
                NSString *strValue = [obj stringValue];
                ALNode *node = [self nodeFromKeyPath:keyPath];
                
                for (int j =0; j<node.nodeFilters.count; j++) {
                    ALNodeFilter * filter = [node.nodeFilters objectAtIndex:j];
                    if (filter.filterValue && [strValue isEqualToString:filter.filterValue]) {
                        if (filter.block) {
                            filter.block(msg);
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
            //异常处理
            //NSLog(@"exception: %@",exception.name);
        }
        
    }
}

#pragma mark - TEST
/*!
 *  @brief 模拟APNS消息启动app所需launchOptions
 *  @note  可在application:didFinishLaunchingWithOptions中给launchOptions赋值用于模拟APNS消息启动app
 *
 *  @return
 */
+(NSMutableDictionary*)launchOptionsWithRemoteNotification_TestWebPage{
    //测试webPage的APNS消息
    NSString *str = @"{\"aps\":{\"alert\":\"your message here.\",\"badge\":9,\"sound\":\"default\"},\"acme1\":\"bar\",\"acme2\":42,\"payload\":{\"lt\":259,\"aid\":\"100333\",\"ty\":100,\"lv\":\"http: //www.hao123.com/\",\"content\":\"\\u8fd9\\u662f\\u6d4b\\u8bd5\\u6d88\\u606f\"}}";
    
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
