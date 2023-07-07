//
//  DataManager.m
//  myimage
//
//  Created by liuqingyuan on 2019/12/31.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//

#import "DataManager.h"
#import "ArticleModel.h"
#import "ImageModel.h"
#import "TFHpple.h"
#import "TwoFourFaModel.h"
#import "SxChineseModel.h"
#import "PiaoLiangModel.h"

@implementation DataManager
/// MARK: 获取写真列表
/// @param websiteModel websiteModel
/// @param PageNum 页码
/// @param category 类型
/// @param success 成功返回
/// @param failure 失败返回
- (void)getDataWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)PageNum category:(CategoryModel *)category success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    if(websiteModel.value == WebsiteType24Fa){
        TwoFourFaModel *model = [[TwoFourFaModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getDataWithPageNum:PageNum category:category];
        success(listArr);
    }else if(websiteModel.value == WebsiteTypeSxChinese){
        SxChineseModel *model = [[SxChineseModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getDataWithPageNum:PageNum category:category];
        success(listArr);
    }else if(websiteModel.value == websiteTypePiaoLiang){
        PiaoLiangModel *model = [[PiaoLiangModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getDataWithPageNum:PageNum category:category];
        success(listArr);
    }
}
/// MARK: 获取写真详情图片列表
/// @param websiteModel websiteModel
/// @param detailUrl 详情地址
/// @param progress 加载进度
/// @param success 成功返回
/// @param failure 失败返回
- (void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void (^)(NSUInteger))progress success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    if (websiteModel.value == WebsiteType24Fa) {
        TwoFourFaModel *model = [[TwoFourFaModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getImageDetailWithDetailUrl:detailUrl];
        success(listArr);
    }else if (websiteModel.value == WebsiteTypeSxChinese) {
        SxChineseModel *model = [[SxChineseModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getImageDetailWithDetailUrl:detailUrl];
        success(listArr);
    }else if (websiteModel.value == websiteTypePiaoLiang) {
        PiaoLiangModel *model = [[PiaoLiangModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getImageDetailWithDetailUrl:detailUrl];
        success(listArr);
    }
}

/// MARK: 站点搜索
/// @param websiteModel websiteModel
/// @param pageNum 页码
/// @param keyword 搜索关键字
/// @param success 成功返回
/// @param failure 失败返回
- (void)getSearchResultWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)pageNum keyword:(NSString *)keyword success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    if (websiteModel.value == WebsiteType24Fa) {
        TwoFourFaModel *model = [[TwoFourFaModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getSearchResultWithPageNum:pageNum keyword:keyword];
        success(listArr);
    }else if (websiteModel.value == WebsiteTypeSxChinese) {
        SxChineseModel *model = [[SxChineseModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getSearchResultWithPageNum:pageNum keyword:keyword];
        success(listArr);
    }else if (websiteModel.value == websiteTypePiaoLiang) {
        PiaoLiangModel *model = [[PiaoLiangModel alloc]init];
        model.urlStr = websiteModel.url;
        model.type = websiteModel.value;
        NSMutableArray *listArr = [model getSearchResultWithPageNum:pageNum keyword:keyword];
        success(listArr);
    }
}

@end
