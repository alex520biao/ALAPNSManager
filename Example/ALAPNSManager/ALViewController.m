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
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"xxxx.att"
                                     filterValue:@"100"
                                         handler:^id(ALAPNSMsg *msg) {
                                             NSLog(@"");
                                             return nil;
                                         }];
    
    //NO
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload"
                                     filterValue:@"100"
                                         handler:^id(ALAPNSMsg *msg) {
                                            NSLog(@"");
                                            return nil;
                                         }];
    
    //NO
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload"
                                     filterValue:@"101"
                                         handler:^id(ALAPNSMsg *msg) {
                                             NSLog(@"");
                                             return nil;
                                         }];

    //NO
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload.lt.ABC"
                                     filterValue:@"100"
                                         handler:^id(ALAPNSMsg *msg) {
                                             NSLog(@"");
                                             return nil;
                                         }];
    //YES
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload.lt"
                                     filterValue:@"259"
                                         handler:^id(ALAPNSMsg *msg) {
                                             NSLog(@"");
                                             return nil;
                                         }];

    //YES
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload.lt"
                                     filterValue:@"259"
                                         handler:^id(ALAPNSMsg *msg) {
                                             NSLog(@"");
                                             return nil;
                                         }];

    //NO
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload.ty"
                                     filterValue:@"100"
                                         handler:^id(ALAPNSMsg *msg) {
                                             NSLog(@"");
                                             return nil;
                                         }];
    
    [self.apnsManager addAPNSPatternWithObserver:self
                                         keyPath:@"payload.ty"
                                     filterValue:@"100"
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
