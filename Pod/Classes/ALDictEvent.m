//
//  ALDictEvent.m
//  Pods
//
//  Created by alex on 2016/12/3.
//
//

#import "ALDictEvent.h"

@implementation ALDictEvent

- (instancetype)initWithDict:(NSDictionary *)dict
                    progress:(ALDictProgressBlcok)progress
                    response:(ALDictResponseBlcok)response{
    self = [super init];
    if (self) {
        _dict        = dict;
        _progress   = progress;
        _response = response;
    }
    return self;
}


@end
