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
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    
    //NO
    [self.apnsManager addAPNSPattern:@"payload"
                         filterValue:@"100"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    
    //NO
    [self.apnsManager addAPNSPattern:@"payload"
                         filterValue:@"101"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    
    //NO
    [self.apnsManager addAPNSPattern:@"payload.lt.ABC"
                         filterValue:@"100"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    //YES
    [self.apnsManager addAPNSPattern:@"payload.lt"
                         filterValue:@"259"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    
    //YES
    [self.apnsManager addAPNSPattern:@"payload.lt"
                         filterValue:@"259"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    
    
    //keyPath与value完全相等
    //NO
    [self.apnsManager addAPNSPattern:@"payload.ty"
                         filterValue:@"100"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
    
    [self.apnsManager addAPNSPattern:@"payload.ty"
                         filterValue:@"100"
                            observer:self
                             handler:^id(ALAPNSMsg *msg) {
                                 NSLog(@"");
                                 return nil;
                             }];
}

@end
