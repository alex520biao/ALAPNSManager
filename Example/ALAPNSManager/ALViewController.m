//
//  ALViewController.m
//  ALAPNSManager
//
//  Created by alex520biao on 07/07/2016.
//  Copyright (c) 2016 alex520biao. All rights reserved.
//

#import "ALViewController.h"
#import <ALAPNSManager/ALAPNSManagerKit.h>

@interface ALViewController ()

@end

@implementation ALViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
