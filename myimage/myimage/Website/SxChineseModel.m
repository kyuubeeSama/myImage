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
        self.name = @"sxchinesegirlz";
        self.CategoryTitleArr = @[@"nude", @"xiuren", @"chokmoson", @"feilin", @"huayang", @"imiss", @"mfstar", @"mistar", @"mygirl", @"tuigirl", @"ugirls", @"xiaoyu", @"yalayi", @"youmei", @"youmi"];
        self.categoryIdsArr = @[@"nude", @"xiuren", @"chokmoson", @"feilin", @"huayang", @"imiss", @"mfstar", @"mistar", @"mygirl", @"tuigirl", @"ugirls", @"xiaoyu", @"yalayi", @"youmei", @"youmi"];
    }
    return self;
}
- (nonnull NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(nonnull CategoryModel *)category {
    //    拼接域名
    NSString *urlStr = [NSString stringWithFormat:@"%@/category/%@/page/%ld/", self.urlStr, category.value, (long) PageNum];;
    NSString *titleXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@title";//标题
    NSString *detailXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@href";//详情
    NSString *picXpath = @"//*[@id=\"content_box\"]/div/div/article/a/div[1]/img/@src";//封面
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
    NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    NSArray<TFHppleElement *> *picNodeArr = [xpathDoc searchWithXPathQuery:picXpath];
    // 循环获取内容
    for (NSUInteger i = 0; i < titleNodeArr.count; ++i) {
        NSString *title = titleNodeArr[i].text;
        NSString *picPath = picNodeArr[i].text;
        NSString *detail = detailNodeArr[i].text;
        
        // 获取id
        NSArray<NSString *> *array = [detail componentsSeparatedByString:@"/"];
        NSInteger aid = [[array.lastObject stringByReplacingOccurrencesOfString:@".html" withString:@""] intValue];
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
        }
        [resultArr addObject:result];
    }
    return resultArr;
}

- (nonnull NSMutableArray *)getImageDetailWithDetailUrl:(nonnull NSString *)detailUrl {
    NSString *urlStr = detailUrl;
    if (![detailUrl containsString:@"http"] || ![detailUrl containsString:@"https"]) {
        urlStr = [NSString stringWithFormat:@"%@/%@", self.urlStr, detailUrl];
    }
    NSString *imageXPath = @"/html/body/div/div/article/div/div[1]/div[1]/div/div[2]/figure/img/@src";
    NSString *pageNumXPath = @"/html/body/div/div/article/div/div[1]/div[1]/div/div[3]/a";
    NSError *error = nil;
    //TODO:此处发生网络错误，仍然后重复请求，应该针对发生网络错误的时候，及时停止请求，防止进一步消耗内存
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        return @[].mutableCopy;
    }
    // 获取总页码数量
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
    NSArray *pageNumArr = [xpathDoc searchWithXPathQuery:pageNumXPath];
    NSLog(@"本页图片%lu,总页数%lu", (unsigned long) imgNodeArr.count, (unsigned long) pageNumArr.count);
    NSInteger pageNum = pageNumArr.count;
    NSMutableArray *imageArr = @[].mutableCopy;
    dispatch_semaphore_t groupSemaphore = dispatch_semaphore_create(0);
    // 使用group设置同时访问量
    dispatch_group_t group = dispatch_group_create();
    __block NSString *blockUrlStr = urlStr;
    // 使用信号量设置同时可以运行的线程数量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    for (NSUInteger i = 1; i <= pageNum; i++) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            // 地址累加获取所有图片
            blockUrlStr = [NSString stringWithFormat:@"%@/%lu", urlStr, (unsigned long) i];
            NSError *detailError = nil;
            NSData *detailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:blockUrlStr] options:NSDataReadingUncached error:&detailError];
            if (detailError) {
                // 网页加载错误
                NSLog(@"错误信息是%@", error.localizedDescription);
            } else {
                TFHpple *detailXpathDoc = [[TFHpple alloc] initWithHTMLData:detailData];
                NSArray *detailImgNodeArr = [detailXpathDoc searchWithXPathQuery:imageXPath];
                for (TFHppleElement *element in detailImgNodeArr) {
                    ImageModel *model = [[ImageModel alloc] init];
                    NSString *image_url = element.text;
                        image_url = [image_url stringByReplacingOccurrencesOfString:@"sxchinesegirlz.com" withString:@"sxchinesegirlz.one"];
                        NSLog(@"%@", image_url);
                        if ([image_url containsString:@"wp.com"]) {
                        } else {
                            if (![image_url containsString:@"jpeg"]) {
                                NSRange beginRange = [image_url rangeOfString:@"-" options:NSBackwardsSearch];
                                NSRange endRange = [image_url rangeOfString:([image_url containsString:@".jpg"] ? @".jpg" : @".png")];
                                image_url = [image_url stringByReplacingCharactersInRange:NSMakeRange(beginRange.location, endRange.location - beginRange.location) withString:@""];
                            }
                        }
                    model.image_url = [Tool replaceDomain:self.urlStr urlStr:image_url];
                    model.website_id = self.type;
                    [imageArr addObject:model];
                }
            }
            dispatch_semaphore_signal(semaphore);
            dispatch_group_leave(group);
        });
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //操作结束，block返回数据
        dispatch_semaphore_signal(groupSemaphore);
    });
    dispatch_semaphore_wait(groupSemaphore, DISPATCH_TIME_FOREVER);
    return imageArr;
}

- (nonnull NSMutableArray *)getSearchResultWithPageNum:(NSInteger)pageNum keyword:(nonnull NSString *)keyword {
    NSString *urlStr = [NSString stringWithFormat:@"%@/page/%ld/?s=%@", self.urlStr, (long) pageNum, keyword];
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"搜索地址是%@", urlStr);
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        return @[].mutableCopy;
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSString *titleXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@title";
    NSString *detailXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@href";
    NSString *imgXpath = @"//*[@id=\"content_box\"]/div/div/article/a/div[1]/img/@src";
    NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    NSArray<TFHppleElement *> *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXpath];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    for (NSUInteger i = 0; i < titleNodeArr.count; i++) {
        NSString *title = titleNodeArr[i].text;
        title = [Tool filterHTML:title];
        NSString *detail = detailNodeArr[i].text;
        ArticleModel *result = [[ArticleModel alloc] init];
        result.name = title;
        result.detail_url = [Tool replaceDomain:self.urlStr urlStr:detail];
        NSString *imgPath = imgNodeArr[i].text;
        result.img_url = imgPath;
        result.website_id = self.type;
        NSArray<NSString *> *array = [detail componentsSeparatedByString:@"/"];
        result.aid = [[array.lastObject stringByReplacingOccurrencesOfString:@".html" withString:@""] intValue];
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
