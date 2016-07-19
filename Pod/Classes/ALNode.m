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

@end


@implementation ALNodeFilter



@end
