//
//  ImgCategoryListViewController.h
//  myimage
//
//  Created by Galaxy on 2021/2/21.
//  Copyright © 2021 liuqingyuan. All rights reserved.
//  具体分类下的列表

#import "BaseViewController.h"
#import "WebsiteModel.h"
#import "CategoryModel.h"
#import "JXCategoryView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImgCategoryListViewController : BaseViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, strong) CategoryModel *categoryModel;
@property (nonatomic, strong) WebsiteModel *webModel;
// 页码
@property(nonatomic, assign) NSInteger pageNum;
// 是否是跳页
@property(nonatomic,assign) BOOL isJump;

@end

NS_ASSUME_NONNULL_END
