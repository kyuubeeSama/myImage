//
//  ElitebabesModel.m
//  myimage
//
//  Created by Galaxy on 2023/7/27.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import <hpple/TFHpple.h>

@implementation ElitebabesModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"elitebabes";
        self.CategoryTitleArr = @[@"默认"];
        self.categoryIdsArr = @[@"0"];
    }
    return self;
}
- (nonnull NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(nonnull CategoryModel *)category {
    //    拼接域名
    NSString *urlStr = [NSString stringWithFormat:@"%@/archive/page/%ld/", self.urlStr, (long) PageNum];
    NSString *detailXpath = @"//*[@id=\"content\"]/ul[1]/li/figure/a/@href";//详情
    NSString *picXpath = @"//*[@id=\"content\"]/ul[1]/li/figure/a/img/@src";//封面
    NSString *titleXpath = @"//*[@id=\"content\"]/ul[1]/li/figure/a/@title";
    NSLog(@"网址是%@", urlStr);
    // 获取数据
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        return @[].mutableCopy;
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    NSArray<TFHppleElement *> *picNodeArr = [xpathDoc searchWithXPathQuery:picXpath];
    NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
    // 循环获取内容
    for (NSUInteger i = 0; i < detailNodeArr.count; ++i) {
        NSString *title = titleNodeArr[i].text;
        NSString *picPath = picNodeArr[i].text;
        NSString *detail = detailNodeArr[i].text;
        if (![detail containsString:self.urlStr]){
            continue;
        }
        // 获取id
        int aid = 0;
        detail = [Tool replaceDomain:self.urlStr urlStr:detail];
        // 存数据库
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                     where:[NSString stringWithFormat:@"website_id = %lu and detail_url = '%@'", (unsigned long)self.type, detail]
                                                                     field:@"*"
                                                                     Class:[ArticleModel class]];
        if (result.name == nil) {
            result.name = title;
            result.detail_url = detail;
            result.img_url = picPath;
            result.aid = aid;
            NSLog(@"标题是%@,详情是%@,图片地址是%@", title, detail, picPath);
            if ([sqlTool insertTable:@"article"
                             element:@"website_id,category_id,name,detail_url,img_url,aid"
                               value:[NSString stringWithFormat:@"%lu,%d,'%@','%@','%@',%ld", (unsigned long)self.type, category.category_id, result.name, result.detail_url, result.img_url, (long)result.aid]
                               where:nil]) {
                result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                               where:[NSString
                                                                       stringWithFormat:@"website_id = %lu and detail_url = '%@'", (unsigned long)self.type, result.detail_url]
                                                               field:@"*"
                                                               Class:[ArticleModel class]];
            }
        } else {
            if (result.category_id == 0) {
                // 需要更新类型，搜索的数据结果是没有分类类型的
                [sqlTool updateTable:@"article"
                               where:[NSString stringWithFormat:@"website_id=%lu and detail_url='%@'", (unsigned long)self.type, detail]
                               value:[NSString stringWithFormat:@"category_id=%d", category.category_id]];
            }
            if (result.aid == 0) {
                // 更新aid
                [sqlTool updateTable:@"article"
                               where:[NSString stringWithFormat:@"website_id=%lu and detail_url='%@'", (unsigned long)self.type, detail]
                               value:[NSString stringWithFormat:@"aid=%ld", (long)aid]];
            }
        }
        [resultArr addObject:result];
    }
    return resultArr;
}

- (nonnull NSMutableArray *)getImageDetailWithDetailUrl:(nonnull NSString *)detailUrl {
    NSString *urlStr = detailUrl;
    if (![detailUrl containsString:@"http"] || ![detailUrl containsString:@"https"]) {
        urlStr = [NSString stringWithFormat:@"%@%@", self.urlStr, detailUrl];
    }
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        return @[].mutableCopy;
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSString *imageXPath = @"//*[@id=\"content\"]/ul[1]/li/a/@href";
    NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
    NSLog(@"本页图片%lu", (unsigned long) imgNodeArr.count);
    NSMutableArray *imageArr = @[].mutableCopy;
    for (TFHppleElement *element in imgNodeArr) {
        ImageModel *model = [[ImageModel alloc] init];
        NSString *image_url = element.text;
        model.image_url = [Tool replaceDomain:self.urlStr urlStr:image_url];
        model.website_id = self.type;
        [imageArr addObject:model];
    }
    return imageArr;
}

- (nonnull NSMutableArray *)getSearchResultWithPageNum:(NSInteger)pageNum keyword:(nonnull NSString *)keyword {
    return @[].mutableCopy;
}
@end
