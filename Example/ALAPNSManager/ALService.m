//
//  ALService.m
//  ALAPNSManager
//
//  Created by alex520biao on 16/7/19.
//  Copyright © 2016年 alex520biao. All rights reserved.
//

#import "ALService.h"

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

}

@end
