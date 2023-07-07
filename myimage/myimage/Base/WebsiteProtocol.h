//
//  WebsiteProtocol.h
//  myimage
//
//  Created by Galaxy on 2023/7/7.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WebsiteProtocol <NSObject>

@required

/// 写真列表
/// - Parameters:
///   - PageNum: 页码
///   - category: 项目类型
-(NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(CategoryModel *)category;

/// 获取图片列表
/// - Parameter detailUrl: 项目地址
-(NSMutableArray *)getImageDetailWithDetailUrl:(NSString *)detailUrl;

/// 获取搜索结果
/// - Parameters:
///   - pageNum: 页码
///   - keyword: 关键字
-(NSMutableArray *)getSearchResultWithPageNum:(NSInteger)pageNum keyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
