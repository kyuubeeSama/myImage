//
//  AmetartModel.m
//  myimage
//
//  Created by Galaxy on 2023/7/10.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import "AmetartModel.h"

@implementation AmetartModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"ametart";
        self.CategoryTitleArr = @[@"默认"];
        self.categoryIdsArr = @[@"0"];
    }
    return self;
}
- (nonnull NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(nonnull CategoryModel *)category {
    //    拼接域名
    NSString *urlStr = [NSString stringWithFormat:@"%@/?s=%ld", self.urlStr, (long) PageNum];
    NSString *detailXpath = @"/html/body/div[2]/div/div[2]/div/a/@href";//详情
    NSString *picXpath = @"/html/body/div[2]/div/div[2]/div/a/img/@src";//封面
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
    // 循环获取内容
    for (NSUInteger i = 0; i < detailNodeArr.count; ++i) {
        NSString *title = @"相册名";
        NSString *picPath = picNodeArr[i].text;
        NSString *detail = detailNodeArr[i].text;
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
    NSString *imageXPath = @"/html/body/div[2]/div/div[2]/div/a/@href";
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        return @[].mutableCopy;
    }
    // 获取总页码数量
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
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
    NSString *urlStr = [NSString stringWithFormat:@"%@/search/?s=%ld&q=%@", self.urlStr, (long) pageNum, keyword];
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSLog(@"搜索地址是%@", urlStr);
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        return @[].mutableCopy;
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSString *detailXpath = @"/html/body/div[2]/div/div[1]/div/a/@href";
    NSString *imgXpath = @"/html/body/div[2]/div/div[1]/div/a/img/@src";
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    NSArray<TFHppleElement *> *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXpath];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    for (NSUInteger i = 0; i < imgNodeArr.count; i++) {
        NSString *detail = detailNodeArr[i].text;
        ArticleModel *result = [[ArticleModel alloc] init];
        result.detail_url = [Tool replaceDomain:self.urlStr urlStr:detail];
        NSString *imgPath = imgNodeArr[i].text;
        result.img_url = imgPath;
        result.website_id = self.type;
        result.name = @"相册名";
        result.aid = 0;
        if ([sqlTool insertTable:@"article"
                         element:@"website_id,category_id,name,detail_url,img_url,aid"
                           value:[NSString stringWithFormat:@"%lu,0,'%@','%@','%@',%ld", (unsigned long)self.type, result.name, result.detail_url, result.img_url, (long)result.aid]
                           where:[NSString stringWithFormat:@"select * from article where detail_url = '%@'", result.detail_url]]) {
            result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                           where:[NSString
                                                                  stringWithFormat:@"website_id = %lu and detail_url = '%@'", (unsigned long)self.type, result.detail_url]
                                                           field:@"*"
                                                           Class:[ArticleModel class]];
        }
        [resultArr addObject:result];
    }
    return resultArr;
}
@end
