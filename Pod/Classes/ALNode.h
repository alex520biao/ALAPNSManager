//
//  ALNode.h
//  Pods
//
//  Created by alex520biao on 16/7/18.
//
//

#import <Foundation/Foundation.h>
#import "APNSManagerDelegate.h"

@class ALNodeFilter;

/*!
 *  @brief 树形结构
 */
@interface ALNode : NSObject

/*!
 *  @brief 是否为根节点
 */
@property (nonatomic, assign) BOOL rootNode;


/*!
 *  @brief 节点名称
 */
@property (nonatomic, copy) NSString *nodeName;

/*!
 *  @brief 当前节点注册监听Filters
 */
@property (nonatomic, strong) NSMutableArray<ALNodeFilter *> *nodeFilters;

/*!
 *  @brief ALNode的子节点
 */
@property (nonatomic, strong) NSMutableDictionary *subNodes;

/*!
 *  @brief 根据子节点名称获取子节点ALNode
 *
 *  @param subNodeName 子节点名称
 *
 *  @return
 */
-(ALNode*)subNodeForName:(NSString*)subNodeName;

/*!
 *  @brief ALNode是否为叶子节点
 *
 *  @return
 */
-(BOOL)leafNode;


@end

/*!
 *  @brief ALNode节点的监听项
 */
@interface ALNodeFilter : NSObject

/*!
 *  @brief 过滤值
 */
@property (nonatomic, copy) NSString *filterValue;

/*!
 *  @brief 监听者
 *  @note  如果监听者释放，则对应的ALNodeFilter即失效
 */
@property (nonatomic, weak) id observer;

/*!
 *  @brief 监听项的事件回调(observer与block必须匹配)
 */
@property (nonatomic, copy) ALAPNSMsgHandler block;

@end
