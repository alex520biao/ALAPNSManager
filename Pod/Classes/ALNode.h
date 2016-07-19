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
 *  @brief 节点名称(不能重名)
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
 *  @note  只在子节点中查找,不查询后代节点
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

/*!
 *  @brief 获取相同的ALNodeFilter
 *
 *  @param object
 *
 *  @return
 */
-(ALNodeFilter*)equalNodeFilter:(ALNodeFilter*)filter;

/*!
 *  @brief 指定keyPath子节点添加filter(存在则更新，不存在则添加)
 *
 *  @param filter
 *  @param keyPath  从self节点获取keyPath子节点
 */
-(void)insertOrUpdate:(ALNodeFilter*)filter atKeyPath:(ALKeyPath*)keyPath;

/*!
 *  @brief 存在则更新，不存在则添加
 *
 *  @param filter
 */
-(void)insertOrUpdate:(ALNodeFilter*)filter;

/*!
 *  @brief 删除keyPath对应的node的filter
 *
 *  @param filter
 *  @param keyPath 
 */
-(void)removeNodeFilter:(ALNodeFilter *)filter atKeyPath:(ALKeyPath*)keyPath;


/*!
 *  @brief 通过keyPath获取ALNode节点
 *  @note  从node树中查找keyPath对应的节点项node
 *
 *  @param keyPath
 *
 *  @return
 */
-(ALNode*)nodeForKeyPath:(ALKeyPath*)keyPath;

/*!
 *  @brief 根据ALNodel反向查找ALKeyPath
 *
 *  @param node 节点对象
 *
 *  @return
 */
-(ALKeyPath*)keyPathOfNode:(ALNode*)node;

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
