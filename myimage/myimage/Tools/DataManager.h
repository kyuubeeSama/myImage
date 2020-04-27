//
//  DataManager.h
//  myimage
//
//  Created by liuqingyuan on 2019/12/31.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//  负责数据的读取操作

#import <Foundation/Foundation.h>
#import "WebsiteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+(void)getDataWithType:(WebsiteModel *)websiteModel pageNum:(int)PageNum category:(NSString *)category success:(void(^)(NSMutableArray *array))success failure:(void(^)(NSError *error))failure;

+(void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void(^)(int page))progress success:(void(^)(NSMutableArray *array))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
