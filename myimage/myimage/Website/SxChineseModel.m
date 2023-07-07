//
//  SxChineseModel.m
//  myimage
//
//  Created by Galaxy on 2023/7/7.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import "SxChineseModel.h"

@implementation SxChineseModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.CategoryTitleArr = @[@"nude", @"xiuren", @"chokmoson", @"feilin", @"huayang", @"imiss", @"mfstar", @"mistar", @"mygirl", @"tuigirl", @"ugirls", @"xiaoyu", @"yalayi", @"youmei", @"youmi"];
        self.categoryIdsArr = @[@"nude", @"xiuren", @"chokmoson", @"feilin", @"huayang", @"imiss", @"mfstar", @"mistar", @"mygirl", @"tuigirl", @"ugirls", @"xiaoyu", @"yalayi", @"youmei", @"youmi"];
    }
    return self;
}
- (nonnull NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(nonnull CategoryModel *)category {
    return @[].mutableCopy;
}

- (nonnull NSMutableArray *)getImageDetailWithDetailUrl:(nonnull NSString *)detailUrl {
    return @[].mutableCopy;
}

- (nonnull NSMutableArray *)getSearchResultWithPageNum:(NSInteger)pageNum keyword:(nonnull NSString *)keyword {
    return @[].mutableCopy;
}

@end
