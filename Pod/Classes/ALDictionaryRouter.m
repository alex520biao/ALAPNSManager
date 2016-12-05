//
//  ALDictionaryRouter.m
//  Pods
//
//  Created by alex on 2016/12/3.
//
//

#import "ALDictionaryRouter.h"
#import "ALNode.h"

@implementation ALDictionaryRouter

+(ALDictionaryRouter*)routerWithShouldPublish:(ALDictionaryRouterShouldPublishBlock)shouldPublish
                                 didPublished:(ALDictionaryRouterDidPublishedBlock)didPublished{
    ALDictionaryRouter *router = [[ALDictionaryRouter alloc] init];
    router.shouldPublish = shouldPublish;
    router.didPublished = didPublished;
    return router;
}

#pragma mark - 监听项数据管理
-(ALNode*)rootNode{
    if (!_rootNode) {
        _rootNode = [[ALNode alloc] init];
        _rootNode.rootNode = YES;
    }
    return _rootNode;
}

/*!
 *  @brief 添加一个监听项
 *  @note  相同的observer、相同keyPath、相同value，则覆盖只保留最后一次监听
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 *  @param handler  监听者回调
 */
- (void)subscribePattern:(ALKeyPath *)keyPath
       filterValue:(NSString *)value
          observer:(id)observer
           handler:(ALDictEventHandler)handler{
    
    ALNodeFilter *filter = [[ALNodeFilter alloc] init];
    filter.observer     = observer;
    filter.block        = (ALAPNSMsgHandler)handler;
    filter.filterValue  = value;
    [self.rootNode insertOrUpdate:filter atKeyPath:keyPath];
}

/*!
 *  @brief 删除一个监听项
 *
 *  @param observer 监听者
 *  @param keyPath  keyPath
 *  @param value    监听值
 */
-(void)removeAPNSPattern:(ALKeyPath *)keyPath
             filterValue:(NSString*)value
                observer:(id)observer{
    
    ALNodeFilter *filter = [[ALNodeFilter alloc] init];
    filter.observer     = observer;
    filter.filterValue  = value;
    filter.block        = nil;
    [self.rootNode removeNodeFilter:filter atKeyPath:keyPath];
}


/**
 发布NSDictionary消息
 
 @param dict
 */
- (void)publishDictionary:(NSDictionary *)dict
             withUserInfo:(NSDictionary *)userInfo
                 progress:(ALDictProgressBlcok)progress
                 response:(ALDictResponseBlcok)response{
    ALDictEvent *event = [[ALDictEvent alloc] initWithDict:dict
                                                  progress:progress
                                                  response:response];
    //should默认为YES
    BOOL should = YES;
    if (self.shouldPublish) {
        should = self.shouldPublish(self,event);
    }
    
    //should为NO则直接丢弃此消息
    if(!should){
        return;
    }
    
    //遍历树获得所有监听项
    NSMutableArray<ALKeyPath *> *tempArray = [self.rootNode iteratorRouteNode];
    
    //filters临时存储此消息接收者
    NSMutableArray<ALNodeFilter*> *filters = [[NSMutableArray<ALNodeFilter*> alloc] init];
    
    
    //创建分组异步同步任务
    __block typeof(self)weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    //新线程处理数据,tempArray为所有监听项
    for (int i = 0 ; i<tempArray.count; i++) {
        NSString *keyPath = [tempArray objectAtIndex:i];
        
        //获取keyPath对应的strValue
        NSString *strValue = [event.dict al_stringForKeyPath:keyPath];
        if (strValue) {
            ALNode *node = [self.rootNode nodeForKeyPath:keyPath];
            
            for (int j =0; j<node.nodeFilters.count; j++) {
                ALNodeFilter * filter = [node.nodeFilters objectAtIndex:j];
                //observer不能为nil
                if (filter.observer && filter.filterValue && [strValue isEqualToString:filter.filterValue]) {
                    ALDictEventHandler block = (ALDictEventHandler)filter.block;

                    //使用dispatch_group管理多个异步任务
                    dispatch_group_async(group, queue, ^{                        
                        id result = nil;
                        //执行处理操作
                        if (block) {
                            result = block(event,filter);
                            [filters addObject:filter];
                        }
                        
                        //调用者结果回调
                        if(event.response){
                            event.response(event,filter,result,filter);
                        }
                    });

                }
            }
        }
    }
    
    //分组中的任务都完成后会自动触发下面的方法
    dispatch_group_notify(group, queue, ^{
        //所有任务执行完毕
        if (self.didPublished) {
            self.didPublished(self,event,filters);
        }
    });
}




@end
