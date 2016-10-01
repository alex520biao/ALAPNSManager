//
//  ALLocNotifiManager+TestCase.h
//  Pods
//
//  Created by liubiao on 16/9/30.
//
//

#import <ALAPNSManager/ALLocNotifiManager.h>

/*!
 *  @brief 本地通知测试
 */
@interface ALLocNotifiManager (TestCase)

#pragma mark - UILocalNotification

#if DEBUG

-(void)test_LocalNotification:(NSTimeInterval)secs;

#endif



@end
