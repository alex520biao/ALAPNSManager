//
//  UILocalNotification+ALExtensions.m
//  Pods
//
//  Created by alex520biao on 16/5/5. Maintain by alex520biao
//
//

#import "UILocalNotification+ALExtensions.h"
#import <objc/runtime.h>

@implementation UILocalNotification (ALExtensions)

#pragma mark - 实现launch
@dynamic launch;
- (BOOL)launch{
    NSNumber *number = objc_getAssociatedObject(self, @selector(launch));
    if (number) {
        return [number boolValue];
    }
    return NO;
}

-(void)setLaunch:(BOOL)launch{
    [self willChangeValueForKey:NSStringFromSelector(@selector(launch))]; // KVO
    objc_setAssociatedObject(self, @selector(launch), [NSNumber numberWithBool:launch], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(launch))]; // KVO
}

#pragma mark - 实现applicationStatus
@dynamic al_applicationStatus;
-(void)setAl_applicationStatus:(UIApplicationState)applicationStatus{
    [self willChangeValueForKey:NSStringFromSelector(@selector(al_applicationStatus))]; // KVO
    objc_setAssociatedObject(self, @selector(al_applicationStatus), [NSNumber numberWithInteger:applicationStatus], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(al_applicationStatus))]; // KVO
}

- (UIApplicationState)al_applicationStatus{
    NSNumber *number = objc_getAssociatedObject(self, @selector(al_applicationStatus));
    if (!number) {
        return UIApplicationStateActive;
    }
    return [number integerValue];
}

#pragma mark - 实现receiveDate
@dynamic receiveDate;
- (NSDate *)receiveDate{
    return objc_getAssociatedObject(self, @selector(receiveDate));
}

-(void)setReceiveDate:(NSDate *)receiveDate{
    [self willChangeValueForKey:NSStringFromSelector(@selector(receiveDate))]; // KVO
    objc_setAssociatedObject(self, @selector(receiveDate), receiveDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(receiveDate))]; // KVO
}

/*!
 *  @brief 获取UILocalNotification的触发方式
 *  @note  判断fireDate与当前时间的时间差. 如果时间差非常小说明是系统timer触发，如果有一定时间差则说明是用户从消息提示及消息中心点击进入
 *
 *  @return
 */
-(ALLocNotifiTriggerMode)triggerMode{
    ALLocNotifiTriggerMode triggerMode = ALLocNotifiTriggerMode_Unkonw;
    if(!self.receiveDate){
        triggerMode = ALLocNotifiTriggerMode_Unkonw;
    }else{
        NSTimeInterval secs = fabs([self.receiveDate timeIntervalSinceDate:self.fireDate]);
        if (secs >0.5) {
            //用户点击触发
            triggerMode = ALLocNotifiTriggerMode_UserClick;
        }else{
            //timer触发
            triggerMode = ALLocNotifiTriggerMode_Timer;
        }
    }
    return triggerMode;
}


@end
