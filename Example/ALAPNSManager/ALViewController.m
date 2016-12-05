//
//  ALViewController.m
//  ALAPNSManager
//
//  Created by alex520biao on 07/07/2016.
//  Copyright (c) 2016 alex520biao. All rights reserved.
//

#import "ALViewController.h"
#import <ALAPNSManager/ALAPNSManagerKit.h>
#import "ALDictionaryRouter.h"
#import "ALAppDelegate.h"

@interface ALViewController ()


@end

@implementation ALViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加监听
//    [self.dictEventRouter subscribePattern:@"payload.ty"
//                         filterValue:@"110"
//                            observer:self
//                             handler:^id(ALDictEvent *msg) {
//                                 if (msg.progress) {
//                                     msg.progress(msg,0.5,nil);
//                                 }
//                                 
//                                 if (msg.progress) {
//                                     msg.progress(msg,1,nil);
//                                 }
//                                 
//                                 return @"OK";
//                             }];
    
    ALDictionaryRouter *router = ((ALAppDelegate*)[UIApplication sharedApplication].delegate).dictEventRouter;
    [router subscribePattern:@"payload.ty"
                 filterValue:@"111"
                    observer:self
                     handler:^id(ALDictEvent *msg,ALNodeFilter *filter) {
                         //此Block必须以同步方式执行，获取的数据在block末尾作为返回值返回
                         
                         //执行进度30%
                         sleep(2);
                         //根据数据的处理进度回调progress
                         if (msg.progress) {
                             msg.progress(msg,0.3,filter);
                         }

                         //执行进度30%
                         NSURL *urlString = [NSURL URLWithString:@"http://www.jianshu.com/p/73e00cb16dd1"];
                         NSData *data = [NSData dataWithContentsOfURL:urlString];
                         if (msg.progress) {
                             msg.progress(msg,0.6,filter);
                         }
                         
                         //执行进度30%
                         sleep(2);
                         if (msg.progress) {
                             msg.progress(msg,1,filter);
                         }
                         
                         return data;
                     }];

    
//    NSDictionary *ty = [NSDictionary dictionaryWithObject:@"110" forKey:@"ty"];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:ty forKey:@"payload"];
//    [self.dictEventRouter publishDictionary:dict
//                               withUserInfo:nil
//                                   progress:^(ALDictEvent *event, ALProgress progress, NSDictionary *moreInfo) {
//                                       NSLog(@"");
//                                   } response:^(ALDictEvent *event, id result, NSError *error) {
//                                       NSLog(@"");
//                                   }];
    
    {
        NSDictionary *ty = [NSDictionary dictionaryWithObject:@"111" forKey:@"ty"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:ty forKey:@"payload"];
        [router publishDictionary:dict
                       withUserInfo:nil
                           progress:^(ALDictEvent *event, ALProgress progress, ALNodeFilter *filter) {
                               NSLog(@"ALProgress: %f,filter :%@",progress,filter.observer);
                           } response:^(ALDictEvent *event,ALNodeFilter *filter,id result, NSError *error) {
                               NSLog(@"ALDictEvent response: %@,filter: %@",event.dict,filter.observer);
                           }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
