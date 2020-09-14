//
//  DataManager.h
//  myimage
//
//  Created by liuqingyuan on 2019/12/31.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//  负责数据的读取操作

#import <Foundation/Foundation.h>
#import "WebsiteModel.h"
#import "CategoryModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

@property(nonatomic,strong)NSMutableArray *imageArr;
// 获取写真列表
-(void)getDataWithType:(WebsiteModel *)websiteModel pageNum:(int)PageNum category:(CategoryModel *)category success:(void(^)(NSMutableArray *array))success failure:(void(^)(NSError *error))failure;
// 获取图片列表
-(void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void(^)(int page))progress success:(void(^)(NSMutableArray *array))success failure:(void(^)(NSError *error))failure;
// 获取搜索结果
-(void)getSearchResultWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)pageNum keyword:(NSString *)keyword success:(void(^)(NSMutableArray *array))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
