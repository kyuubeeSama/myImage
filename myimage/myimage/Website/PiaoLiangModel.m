//
//  PiaoLiangModel.m
//  myimage
//
//  Created by Galaxy on 2023/7/7.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import "PiaoLiangModel.h"

@implementation PiaoLiangModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.CategoryTitleArr = @[@"性感美女", @"精品套图", @"高清套图", @"无圣光", @"日韩套图", @"内衣丝袜", @"萌妹萝莉"];
        self.categoryIdsArr = @[@"1", @"18", @"24", @"25", @"2", @"9", @"11"];
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
