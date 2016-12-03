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


@interface ALViewController ()

@property(nonatomic,strong)ALDictionaryRouter *dictEventRouter;

@end

@implementation ALViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //添加一个按钮用来测试本地通知
    ALDictionaryRouter *router = [[ALDictionaryRouter alloc] init];
    self.dictEventRouter = router;
    
    //添加监听
    [self.dictEventRouter subscribePattern:@"payload.ty"
                         filterValue:@"110"
                            observer:self
                             handler:^id(ALDictEvent *msg) {
                                 if (msg.progress) {
                                     msg.progress(msg,0.5,nil);
                                 }
                                 
                                 if (msg.progress) {
                                     msg.progress(msg,1,nil);
                                 }
                                 
                                 return @"OK";
                             }];
    
    [self.dictEventRouter subscribePattern:@"payload.ty"
                         filterValue:@"111"
                            observer:self
                             handler:^id(ALDictEvent *msg) {
                                 if (msg.progress) {
                                     msg.progress(msg,0.5,nil);
                                 }
                                 
                                 if (msg.progress) {
                                     msg.progress(msg,1,nil);
                                 }
                                 
                                 return @"OK";
                             }];

    
    NSDictionary *ty = [NSDictionary dictionaryWithObject:@"110" forKey:@"ty"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:ty forKey:@"payload"];
    [self.dictEventRouter publishDictionary:dict
                               withUserInfo:nil
                                   progress:^(ALDictEvent *event, ALProgress progress, NSDictionary *moreInfo) {
                                       NSLog(@"");
                                   } response:^(ALDictEvent *event, id result, NSError *error) {
                                       NSLog(@"");
                                   }];
    
    {
        NSDictionary *ty = [NSDictionary dictionaryWithObject:@"111" forKey:@"ty"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:ty forKey:@"payload"];
        [self.dictEventRouter publishDictionary:dict
                                   withUserInfo:nil
                                       progress:^(ALDictEvent *event, ALProgress progress, NSDictionary *moreInfo) {
                                           NSLog(@"");
                                       } response:^(ALDictEvent *event, id result, NSError *error) {
                                           NSLog(@"");
                                       }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
