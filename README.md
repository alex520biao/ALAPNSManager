# ALAPNSManager

简明扼要的描述功能


## Quick Start

目前都使用cocoapods安装，在Podfile中加入

## 维护者

alex520biao <alex520biao@163.com>

## License

ALAPNSManager is available under the MIT license. See the LICENSE file for more info.


####版本记录
1. tag 0.1.4为较为稳定版本


####已有
1. APNSManager不使用单例,可以创建多实例多处使用
2. 使用KeyPath添加监听项
3. 支持多对多监听关系
4. handleAPNSMsg方法中应该添加回调,将有filter的逐个回调进行处理。

####TODO
1. removeAPNSPattern:observer: 删除observer的所有监听项
2. 监听项需要随observer释放而自释放
3. 封装KeyPath监听管理器，包含rootNode及KeyPath管理接口
4. KeyPath监听管理器所有操作加入队列。rootNode的遍历及其他操作如果放在主线程有可能影响性能。


####修改之后发布新版本
	
	pod spec lint ALAPNSManager.podspec --allow-warnings --verbose
	pod trunk push ALAPNSManager.podspec --verbose
	pod search ALAPNSManager

####APNS使用方法

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
        //接收APNS消息
        [self.apnsManager handleAPNSMsgWithLaunchOptions:launchOptions];
        return YES;
    }

    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED{
        //接收APNS消息
        [self.apnsManager handleAPNSMsgWithDidReceiveRemoteNotification:userInfo];
    }

####测试APNS消息

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
        //接收APNS消息(自定义launchOptions来实现APNS测试)
        launchOptions = [ALAPNSManager launchOptionsWithRemoteNotification_TestWebPage];
        [self.apnsManager test_APNSMsgWithLaunchOptions:launchOptions];
        return YES;
    }

    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED{
        //接收APNS消息
        [self.apnsManager handleAPNSMsgWithDidReceiveRemoteNotification:userInfo];
    }
