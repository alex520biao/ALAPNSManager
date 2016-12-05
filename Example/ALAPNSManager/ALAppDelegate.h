//
//  ALAppDelegate.h
//  ALAPNSManager
//
//  Created by alex520biao on 07/07/2016.
//  Copyright (c) 2016 alex520biao. All rights reserved.
//

@import UIKit;
#import "ALDictionaryRouter.h"

@interface ALAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


/*!
 *  @brief 底层导航控制器
 */
@property (strong, nonatomic) UINavigationController *naviController;

@property(nonatomic,strong)ALDictionaryRouter *dictEventRouter;

@end
