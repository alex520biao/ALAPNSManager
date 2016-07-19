//
//  ALAPNSTool.m
//  Pods
//
//  Created by alex520biao on 16/7/19.
//
//

#import "ALAPNSTool.h"

@implementation ALAPNSTool

#pragma mark - pathComponents数组与keyPath字符串相互转换
/*!
 *  @brief KeyPath字符串截取
 *
 *  @param keyPath
 *
 *  @return 数组pathComponents
 */
+ (NSArray*)pathComponentsFromKeyPath:(ALKeyPath*)keyPath{
    NSArray *pathComponents = [keyPath componentsSeparatedByString:@"."];
    return [pathComponents copy];
}

/*!
 *  @brief pathList转换为KeyPath字符串
 *
 *  @param list
 *
 *  @return
 */
+(ALKeyPath*)keyPathWithArray:(NSArray*)list{
    return [list componentsJoinedByString:@"."];
}


@end
