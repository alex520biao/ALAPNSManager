//
//  ALNode.m
//  Pods
//
//  Created by alex520biao on 16/7/18.
//
//

#import "ALNode.h"
#import "ALAPNSTool.h"

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
 *  @brief 指定keyPath子节点添加filter(存在则更新，不存在则添加)
 *
 *  @param filter
 *  @param keyPath  从self节点获取keyPath子节点
 */
-(void)insertOrUpdate:(ALNodeFilter*)filter atKeyPath:(ALKeyPath*)keyPath{
    NSArray *pathComponents = [ALAPNSTool pathComponentsFromKeyPath:keyPath];
    ALNode *node = self;
    
    for (int i=0; i<pathComponents.count; i++) {
        NSString* pathComponent = pathComponents[i];
        
        //检查子节点是否存在
        if (![node.subNodes objectForKey:pathComponent]) {
            ALNode *subNode = [[ALNode alloc] init];
            subNode.nodeName = pathComponent;
            [node.subNodes setObject:subNode forKey:pathComponent];
        }
        
        node = [node subNodeForName:pathComponent];
        
        //pathComponents数组最后一个则为监听项，增加NodeFilter
        if (i == pathComponents.count-1 && filter.block && node) {
            //插入或更新
            [node insertOrUpdate:filter];
        }
    }
}

-(void)removeNodeFilter:(ALNodeFilter *)filter atKeyPath:(ALKeyPath*)keyPath{
    NSArray *pathComponents = [ALAPNSTool pathComponentsFromKeyPath:keyPath];
    
    ALNode *node = self;
    for (int i = 0; i<pathComponents.count; i++) {
        NSString* pathComponent = pathComponents[i];
        
        //此pathComponent没有查询到节点
        if (![node.subNodes objectForKey:pathComponent]) {
            node = nil;
            break;
        }else{
            node = [node subNodeForName:pathComponent];
        }
    }
        
    __block ALNodeFilter *found = nil;
    [node.nodeFilters enumerateObjectsUsingBlock:^(ALNodeFilter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.observer == filter.observer && [obj.filterValue isEqualToString:filter.filterValue]) {
            found = obj;
            *stop = YES;
        }
    }];
    if (found) {
        [node.nodeFilters removeObject:found];
    }
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

/*!
 *  @brief 通过keyPath获取ALNode节点
 *
 *  @param keyPath
 *
 *  @return
 */
-(ALNode*)nodeForKeyPath:(ALKeyPath*)keyPath{
    ALNode* subNode = self;
    NSArray* pathComponents = [ALAPNSTool pathComponentsFromKeyPath:keyPath];
    
    // borrowed from HHRouter(https://github.com/Huohua/HHRouter)
    for (NSString* pathComponent in pathComponents) {
        BOOL found = NO;
        
        // 对 key 进行排序，这样可以把 ~ 放到最后
        NSArray *subRoutesKeys =[subNode.subNodes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        for (NSString* key in subRoutesKeys) {
            //根据subNodeName获取subNode
            if ([key isEqualToString:pathComponent]) {
                found = YES;
                subNode = [subNode subNodeForName:key];
                break;
            }
        }
        // 如果某一级pathComponents对应的node,则说明节点不存在无需向下查找了
        if (!found) {
            subNode = nil;
            break;
        }
    }
    return subNode;
}

/*!
 *  @brief 根据ALNodel反向查找ALKeyPath
 *
 *  @param node 节点对象
 *
 *  @return 相对KeyPath
 */
-(ALKeyPath*)keyPathOfNode:(ALNode*)node{
    ALKeyPath *keyPath = [self iteratorDictionary:node array:[NSMutableArray array]];
    return keyPath;
}

/*!
 *  @brief 递归查找节点
 *
 *  @param queryNode 要查询的节点
 *  @param pathList self对应的node节点在树中的路径
 *
 *  @return
 */
-(ALKeyPath*)iteratorDictionary:(ALNode*)queryNode array:(NSMutableArray*)pathList{
    __block BOOL found = NO;
    __block ALKeyPath *keyPath = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:self.subNodes];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableArray *list = [NSMutableArray arrayWithArray:pathList];

        ALNode *sub = (ALNode*)obj;
        if (sub && sub.nodeName) {
            [list addObject:[sub.nodeName copy]];
        }
        
        if (sub == queryNode) {
            found = YES;
            keyPath = [ALAPNSTool keyPathWithArray:list];
        }else{
            keyPath = [sub iteratorDictionary:queryNode array:list];
        }
        
        //已经找到
        if (found) {
            *stop = YES;
        }
    }];
    
    return  keyPath;
}

#pragma mark - New
/*!
 *  @brief 遍历树获得带有监听项的ALNode的KeyPath数组
 *
 *  @return 当前所有监听项
 */
-(NSMutableArray<ALKeyPath *>*)iteratorRouteNode{
    //获取所有存在监听项的节点
    NSMutableArray<ALKeyPath *> *tempArray = [[NSMutableArray alloc] init];
    [self iteratorDictionary:self
                   tempArray:tempArray
                       array:[NSMutableArray array]];
    return tempArray;
}

/*!
 *  @brief 递归查询存在block的KeyPath
 *
 *  @param dict      查询的当前节点
 *  @param tempArray 保存所有监听项
 *  @param pathList  临时路径数组
 */
-(void)iteratorDictionary:(ALNode*)node tempArray:(NSMutableArray*)tempArray array:(NSMutableArray*)pathList{
    //非根节点且nodeName不为空，保存nodeName到pathList中
    if (!node.rootNode && node.nodeName) {
        [pathList addObject:node.nodeName];
        
        //此节点有监听者,则保存此keyPath到tempArray
        if (node.nodeFilters && node.nodeFilters.count>0) {
            NSString *keyPath = [ALAPNSTool keyPathWithArray:pathList];
            [tempArray addObject:keyPath];
        }
    }
    
    //非叶子节点
    if (![node leafNode]) {
        [node.subNodes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //obj为node节点
            if ([obj isKindOfClass:[ALNode class]]) {
                ALNode *subNode = (ALNode*)obj;
                if (subNode.nodeName && subNode.nodeName.length>0) {
                    //递归查询子节点,需要新建pathList数组
                    NSMutableArray *list = [NSMutableArray arrayWithArray:pathList];
                    [self iteratorDictionary:subNode tempArray:tempArray array:list];
                }
            }
        }];
    }
}


@end


@implementation ALNodeFilter


@end
