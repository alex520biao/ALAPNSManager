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
}

@end
