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

#pragma mark - Other
/*!
 *  @brief 获取id类型的stringValue
 *
 *  @param obj  NSString、NSNumber(实现stringValue方法即可)
 *
 *  @return
 */
+(NSString*)stringValueWithObj:(id)obj{
    NSString *strValue = nil;
    if ([obj isKindOfClass:[NSString class]]) {
        strValue = (NSString*)obj;
    }else if(obj && [obj respondsToSelector:@selector(stringValue)]){
        strValue = [obj stringValue];
    }
    return strValue;
}

@end

@implementation NSDictionary (Safe)

- (nullable id)al_valueForKeyPath:(NSString *)keyPath{
    id obj = nil;
    @try {
        obj = [self valueForKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        //未找到此KeyPath路径
        //NSLog(@"exception: %@",exception.name);
    }
    return obj;
}

@end
