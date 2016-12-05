//
//  ALAppDelegate.m
//  ALAPNSManager
//
//  Created by alex520biao on 07/07/2016.
//  Copyright (c) 2016 alex520biao. All rights reserved.
//

#import "ALAppDelegate.h"
#import "ALViewController.h"
#import "ALService.h"
#import <ALAPNSManager/ALAPNSManagerKit.h>

@interface ALAppDelegate ()<ALAPNSManagerDelegate,ALLocNotifiManagerDelegate>
@property(nonatomic,strong)ALAPNSManager *apnsManager;
@property(nonatomic,strong)ALLocNotifiManager *locNotifiManager;
@property(nonatomic,strong)ALService *service;

@end

@implementation ALAppDelegate

-(ALAPNSManager*)apnsManager{
    if (!_apnsManager) {
        _apnsManager = [[ALAPNSManager alloc] init];
        _apnsManager.delegate = self;
    }
    return _apnsManager;
}

-(ALLocNotifiManager*)locNotifiManager{
    if (!_locNotifiManager) {
        _locNotifiManager = [[ALLocNotifiManager alloc] init];
        _locNotifiManager.delegate = self;
    }
    return _locNotifiManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ALViewController *mainViewController = [[ALViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    nav.navigationBarHidden = YES;//是否隐藏导航栏
    nav.navigationBar.barStyle = UIBarStyleBlack;
    self.naviController = nav;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    //添加一个按钮用来测试本地通知
    self.dictEventRouter = [ALDictionaryRouter routerWithShouldPublish:^BOOL(ALDictionaryRouter *router, ALDictEvent *msg) {
        return YES;
    } didPublished:^(ALDictionaryRouter *router, ALDictEvent *msg, NSArray<ALNodeFilter *> *filters) {
        NSLog(@"DidPublished");
    }];
    
    /*!
     *  @brief 注册iOS系统 APNS消息
     */
    [self.apnsManager registerForRemoteNotification];
    
    ALService *service = [[ALService alloc] init];
    service.apnsManager = self.apnsManager;
    service.locNotifiManager = self.locNotifiManager;
    self.service = service;
    [self.service serviceDidLoad];
    

    
#warning 测试APNS启动
    launchOptions = [ALAPNSManager launchOptionsWithRemoteNotification_TestWebPage];
    [self.apnsManager test_APNSMsgWithLaunchOptions:launchOptions];
    
    //正常处理
//    [self.apnsManager handleAPNSMsgWithLaunchOptions:launchOptions];
    
    //接收并处理UILocalNotification
    [self.locNotifiManager handleLocNotifiWithLaunchOptions:launchOptions];
    
    
#warning 测试UILocalNotification启动应用
    [self.locNotifiManager test_LocalNotification:10];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*!
 *  @brief 本地通知
 *
 *  @param application
 *  @param notification
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //接收并处理UILocalNotification消息
    [self.locNotifiManager handleLocNotifiWithDidReceiveRemoteNotification:notification
                                                         applicationStatus:[UIApplication sharedApplication].applicationState];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //接收并存储deviceToken
    [self.apnsManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

//iOS7开始使用application:didReceiveRemoteNotification:fetchCompletionHandler:方法处理
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    //APNS消息处理
//    [self.apnsManager handleAPNSMsgWithDidReceiveRemoteNotification:userInfo];
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED{
    //APNS消息处理
    [self.apnsManager handleAPNSMsgWithDidReceiveRemoteNotification:userInfo];
}

#pragma mark - APNSManagerDelegate
/*!
 *  @brief 是否向将此APNS消息进入发布流程
 *
 *  @param manager
 *  @param msg
 */
- (BOOL)apnsManager:(ALAPNSManager *)manager shouldPublishAPNSMsg:(ALAPNSMsg *)msg{
    

    return YES;
}

/*!
 *  @brief APNS消息已经分发处理完成
 *
 *  @param manager
 *  @param msg
 *  @param filters filters为0则消息没有接收者,大于零则说明有多个接收者
 */
- (void)apnsManager:(ALAPNSManager *)manager didPublishAPNSMsg:(ALAPNSMsg *)msg filter:(NSArray<ALNodeFilter *>*)filters{
    

}

#pragma mark - ALLocNotifiManagerDelegate
/*!
 *  @brief 是否向将此APNS消息进入发布流程
 *
 *  @param manager
 *  @param msg
 */
- (BOOL)locNotifiManager:(ALLocNotifiManager *)manager shouldPublishLocNotifi:(UILocalNotification *)msg{

    return YES;
}

/*!
 *  @brief UILocalNotification已经分发处理完成
 *
 *  @param manager
 *  @param msg
 *  @param filters filters为0则消息没有接收者,大于零则说明有多个接收者
 */
- (void)locNotifiManager:(ALLocNotifiManager *)manager didPublishLocNotifi:(UILocalNotification *)msg filter:(NSArray<ALNodeFilter *>*)filters{


}




@end
