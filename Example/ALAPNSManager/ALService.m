//
//  ALService.m
//  ALAPNSManager
//
//  Created by alex520biao on 16/7/19.
//  Copyright © 2016年 alex520biao. All rights reserved.
//

#import "ALService.h"
#import "ALDictionaryRouter.h"
#import "ALAppDelegate.h"

@implementation ALService


/*!
 *  @brief service加载完成(子类需要重写)
 */
- (void)serviceDidLoad{
    //NO
    [self.apnsManager addAPNSPattern:@"xxxx.att"
                         filterValue:@"100"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    //NO
    [self.apnsManager addAPNSPattern:@"payload"
                         filterValue:@"100"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    //NO
    [self.apnsManager addAPNSPattern:@"payload"
                         filterValue:@"101"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    //NO
    [self.apnsManager addAPNSPattern:@"payload.lt.ABC"
                         filterValue:@"100"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    //YES
    [self.apnsManager addAPNSPattern:@"payload.lt"
                         filterValue:@"259"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    //YES
    [self.apnsManager addAPNSPattern:@"payload.lt"
                         filterValue:@"259"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    
    //keyPath与value完全相等
    //NO
    [self.apnsManager addAPNSPattern:@"payload.ty"
                         filterValue:@"100"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    [self.apnsManager addAPNSPattern:@"payload.ty"
                         filterValue:@"100"
                            observer:self
                             handler:^void(ALAPNSMsg *msg) {
                                 NSLog(@"");
                             }];
    
    //针对本地通知的userInfo做订阅
    [self.locNotifiManager addLocNotifiPattern:@"xyz"
                                   filterValue:@"250"
                                      observer:self
                                       handler:^(UILocalNotification *localNotification) {
                                           NSLog(@"LocNotifi 发布成功");
                                           
                                           UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:[localNotification logExtenDescription]
                                                                                             message:localNotification.alertBody
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                           [alertView show];

                                           //UILocalNotification启动应用
                                           if(localNotification.launch){
                                               //......
                                           }else{
                                               //其他场景接收到UILocalNotification
                                               if(localNotification.al_applicationStatus == UIApplicationStateActive){
                                                   //......
                                               }
                                               else if(localNotification.al_applicationStatus == UIApplicationStateInactive){
                                                   //......
                                               }
                                               else if(localNotification.al_applicationStatus == UIApplicationStateBackground){
                                                   //......
                                               }
                                           }
                                       }];
    
    //针对本地通知的userInfo做订阅
    [self.locNotifiManager addLocNotifiPattern:@"xyz"
                                   filterValue:@"251"
                                      observer:self
                                       handler:^(UILocalNotification *localNotification) {
                                           NSLog(@"LocNotifi 发布成功");
                                       }];

    ALDictionaryRouter *router = ((ALAppDelegate*)[UIApplication sharedApplication].delegate).dictEventRouter;
    [router subscribePattern:@"payload.ty"
                 filterValue:@"111"
                    observer:self
                     handler:^id(ALDictEvent *msg,ALNodeFilter *filter) {
                         //此Block必须以同步阻塞方式执行，获取的数据在block末尾作为返回值返回
                         
                         //执行进度30%
                         sleep(2);
                         //根据数据的处理进度回调progress
                         if (msg.progress) {
                             //当前线程为同步线程需要切换到主线程回调
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 msg.progress(msg,0.3,filter);
                             });
                         }
                         
                         //执行进度30%
                         NSURL *urlString = [NSURL URLWithString:@"http://www.jianshu.com/p/73e00cb16dd1"];
                         NSData *data = [NSData dataWithContentsOfURL:urlString];
                         if (msg.progress) {
                             //当前线程为同步线程需要切换到主线程回调
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 msg.progress(msg,0.6,filter);
                             });
                         }
                         
                         //执行进度30%
                         sleep(2);
                         if (msg.progress) {
                             //当前线程为同步线程需要切换到主线程回调
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 msg.progress(msg,1,filter);
                             });
                         }
                         
                         return data;                         
                     }];

}

@end
