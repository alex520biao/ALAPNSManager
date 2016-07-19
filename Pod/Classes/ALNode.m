//
//  ALNode.m
//  Pods
//
//  Created by alex520biao on 16/7/18.
//
//

#import "ALNode.h"

@implementation ALNode

/*!
 *  @brief ALNode是否为叶子节点
 *
 *  @return
 */
-(BOOL)leafNode{
    BOOL leaf = YES;
    //有子节点则非叶子节点
    if (self.subNodes && self.subNodes.count>0) {
        leaf = NO;
    }
    return leaf;
}

/*!
 *  @brief 根据子节点名称获取子节点ALNode
 *
 *  @param subNodeName 子节点名称
 *
 *  @return
 */
-(ALNode*)subNodeForName:(NSString*)subNodeName{
    ALNode *subNode = nil;
    if (subNodeName && subNodeName.length>0) {
        subNode = [self.subNodes objectForKey:subNodeName];
    }
    return subNode;
}

-(NSMutableArray*)nodeFilters{
    if (!_nodeFilters) {
        _nodeFilters = [NSMutableArray array];
    }
    return _nodeFilters;
}


-(NSMutableDictionary*)subNodes{
    if (!_subNodes) {
        _subNodes = [NSMutableDictionary dictionary];
    }
    return _subNodes;
}


/*!
 *  @brief 获取相同的ALNodeFilter
 *
 *  @param object
 *
 *  @return
 */
-(ALNodeFilter*)equalNodeFilter:(ALNodeFilter*)filter{
    __block ALNodeFilter *equalObj = nil;
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.nodeFilters];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ALNodeFilter *o = (ALNodeFilter*)obj;
        if (filter.observer == o.observer && [o.filterValue isEqualToString:filter.filterValue]) {
            equalObj = o;
            *stop = YES;
        }
    }];
    return equalObj;
}

/*!
 *  @brief 存在则更新，不存在则添加
 *
 *  @param filter
 */
-(void)insertOrUpdate:(ALNodeFilter*)filter{
    ALNodeFilter *equalObj = [self equalNodeFilter:filter];
    if (!equalObj) {
        [self.nodeFilters addObject:filter];
    }else{
        equalObj.observer       = filter.observer;
        equalObj.filterValue    = filter.filterValue;
        equalObj.block      = filter.block;
    }
}


@end


@implementation ALNodeFilter


@end
