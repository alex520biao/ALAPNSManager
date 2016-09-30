//
//  ALLocNotifiManager+TestCase.h
//  Pods
//
//  Created by liubiao on 16/9/30.
//
//

#import <ALAPNSManager/ALLocNotifiManager.h>

@interface ALLocNotifiManager (TestCase)

#pragma mark - UILocalNotification

-(void)test_LocalNotification:(NSTimeInterval)secs;

@end
