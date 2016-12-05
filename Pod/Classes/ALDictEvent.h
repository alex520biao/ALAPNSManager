//
//  ALDictEvent.h
//  Pods
//
//  Created by alex on 2016/12/3.
//
//

#import <Foundation/Foundation.h>

@class ALDictEvent;
@class ALNodeFilter;

/*!
 *  @brief 任务进度: ALProgress类型为CGFloat,值域为[0~1],超出值域赋值无效
 */
typedef CGFloat ALProgress;


/*!
 *  @brief InsideURL处理进度
 *
 *  @param event 消息
 *  @param progress 完成进度百分比
 *  @param moreInfo 当前进度的附加信息
 */
typedef void (^ALDictProgressBlcok)(ALDictEvent *event,ALProgress progress,ALNodeFilter *filter);

/*!
 *  @brief InsideURL处理完成(成功或者异常终止)
 *
 *  @param event 消息
 *  @param result 结果数据对象
 *  @param error  错误对象
 */
typedef void (^ALDictResponseBlcok)(ALDictEvent *event,ALNodeFilter *filter,id result, NSError *error);


@interface ALDictEvent : NSObject

/**
 字典消息
 */
@property (nonatomic, copy, readonly) NSDictionary *dict;

/*!
 *  @brief 发布消息后处理进度block
 */
@property (nonatomic, copy, readonly) ALDictProgressBlcok progress;

/*!
 *  @brief 发布消息后结果回应block
 */
@property (nonatomic, copy, readonly) ALDictResponseBlcok response;

- (instancetype)initWithDict:(NSDictionary *)dict
                    progress:(ALDictProgressBlcok)progress
                    response:(ALDictResponseBlcok)completion;

@end
