//
//  ALAPNSTool.h
//  Pods
//
//  Created by alex520biao on 16/7/19.
//
//

#import <Foundation/Foundation.h>
#import "ALAPNSManagerDelegate.h"

/*!
 * 枚举转换为NSString
 * C宏中的＃表示将之后的传入参数当作字符串处理
 * enumType为枚举值,返回NSString
 */
#define ALENUM_TO_STRING(enumType)   [NSString stringWithCString:#enumType encoding:NSASCIIStringEncoding]

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

#pragma mark - Other
/*!
 *  @brief 获取id类型的stringValue
 *
 *  @param obj  NSString、NSNumber(实现stringValue方法即可)
 *
 *  @return
 */
+(NSString*)stringValueWithObj:(id)obj;

@end


@interface NSDictionary (Safe)
/*!
 *  @brief safe  valueForKeyPath方法
 *
 *  @param keyPath
 *
 *  @return
 */
- (nullable id)al_valueForKeyPath:(NSString *)keyPath;

- (NSString*)al_stringForKeyPath:(NSString *)keyPath;

@end