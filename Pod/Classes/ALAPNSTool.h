//
//  ALAPNSTool.h
//  Pods
//
//  Created by alex520biao on 16/7/19.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSManagerDelegate.h"

#define iOS8AndAbove                        ([[UIDevice currentDevice].systemVersion floatValue] >= 8.f)

@interface ALAPNSTool : NSObject

#pragma mark - pathComponents数组与keyPath字符串相互转换
/*!
 *  @brief KeyPath字符串截取
 *
 *  @param keyPath
 *
 *  @return 数组pathComponents
 */
+ (NSArray*)pathComponentsFromKeyPath:(ALKeyPath*)keyPath;
/*!
 *  @brief pathList转换为KeyPath字符串
 *
 *  @param list
 *
 *  @return
 */
+(ALKeyPath*)keyPathWithArray:(NSArray*)list;

@end
