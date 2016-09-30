//
//  ALLocNotifiManager+TestCase.m
//  Pods
//
//  Created by liubiao on 16/9/30.
//
//

#import "ALLocNotifiManager+TestCase.h"

@implementation ALLocNotifiManager (TestCase)

#pragma mark - UILocalNotification
-(void)test_LocalNotification:(NSTimeInterval)secs{
    UILocalNotification *notification=[[UILocalNotification alloc]init];
    //    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"HH:mm:ss"];//还有其他格式,如mm:ss,ss,hh:mm:ss，yyyy-MM-dd HH:mm:ss,HH大写表示24小时计算，小写表示12小时计算，
    //    NSDate *now=[formatter dateFromString:@"16:59:00"];//设置每天的十二点通知
    
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:20.0];
    notification.timeZone=[NSTimeZone defaultTimeZone];
    //设置默认时区，另外也可以写一个时区如:[dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss +0800"];//表示东八区
    notification.repeatInterval=2;//通知重复次数
    //如果repeatInterval为零，则表示不重复
    notification.repeatInterval=NSDayCalendarUnit;//设置重复的时间间隔，NSSecondCalendarUnit每秒重复,NSHourCalendarUnit每小时重复,NSDayCalendarUnit每天重复,NSMonthCalendarUnit每月重复
    
    //    NSCalendar *calendar=[NSCalendar currentCalendar];
    //    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    //    notification.repeatCalendar=calendar;//当前日历，使用前最好设置时区等信息以便能够自动同步时间
    
    //设置通知属性
    notification.alertBody=@"这是通知主体啊";//通知主体
    notification.applicationIconBadgeNumber=1;//应用程序图标右上角显示的消息数
    notification.alertAction=@"打开应用";//待机界面的滑动动作提示
    notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
    notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
    //    notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
    notification.userInfo=@{@"xyz":@250,@"user":@"jredu"};//绑定到通知上的其他附加信息
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


@end
