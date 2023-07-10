//
//  TwoFourFaModel.m
//  myimage
//
//  Created by Galaxy on 2023/7/7.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import "TwoFourFaModel.h"
#import "ArticleModel.h"
#import "ImageModel.h"
@implementation TwoFourFaModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"24fa";
        self.CategoryTitleArr = @[@"美女", @"欧美"];
        self.categoryIdsArr = @[@"49", @"71"];
    }
    return self;
}

- (nonnull NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(nonnull CategoryModel *)category {
    //    拼接域名
    NSString *urlStr = [NSString stringWithFormat:@"%@/mc%@p%ld.aspx", self.urlStr, category.value, (long) PageNum];
    NSString *titleXpath = @"/html/body/ul[3]/li/a";;//标题
    NSString *detailXpath = @"/html/body/ul[3]/li/a/@href";//详情
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
    // 循环获取内容
    for (NSUInteger i = 0; i < titleNodeArr.count; ++i) {
        NSString *title = titleNodeArr[i].text;
        NSString *picPath = @"";
        NSString *detail = detailNodeArr[i].text;

        // 获取id
        NSString *idStr = [detail stringByReplacingOccurrencesOfString:@"c49.aspx" withString:@""];
        NSInteger aid = [[idStr stringByReplacingOccurrencesOfString:@"mn" withString:@""] intValue];
        detail = [Tool replaceDomain:self.urlStr urlStr:detail];
        // 存数据库
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                     where:[NSString stringWithFormat:@"website_id = %ld and detail_url = '%@'", (long)self.type, detail]
                                                                     field:@"*"
                                                                     Class:[ArticleModel class]];
        if (result.name == nil) {
                // 24fa的图片字段无法获取，需要在详情中获取第一张图
                NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", self.urlStr, detail];
                NSData *detailData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:detailUrl]];
                TFHpple *detailDoc = [[TFHpple alloc] initWithHTMLData:detailData];
                NSString *picXpath = @"//*[@id=\"content\"]/div/img[1]/@src";
                NSArray<TFHppleElement *> *picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
                if ([picNodeArr count]) {
                    picPath = picNodeArr[0].text;
                } else {
                    // 详情图片有2种获取方法
                    picXpath = @"//*[@id=\"content\"]/p/img/@src";
                    picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
                    if ([picNodeArr count]) {
                        picPath = picNodeArr[0].text;
                    }
                }
                if ([NSString MyStringIsNULL:title]) {
                    NSString *contentTitleXPath = @"/html/body/section[1]/header/h1";
                    NSArray<TFHppleElement *> *contentTitleNodeArr = [detailDoc searchWithXPathQuery:contentTitleXPath];
                    if ([contentTitleNodeArr count]) {
                        title = contentTitleNodeArr[0].text;
                    }
                }
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
        urlStr = [NSString stringWithFormat:@"%@/%@", self.urlStr, detailUrl];
    }
    NSString *imageXPath = @"/html/body/section[1]/article/div/img/@src";
    NSString *pageNumXPath = @"/html/body/section[1]/table/tr/td/div/ul/li/a/@href";
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
    pageNum -= 1;
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
            blockUrlStr = [urlStr stringByReplacingOccurrencesOfString:@".aspx" withString:[NSString stringWithFormat:@"p%lu.aspx", i]];
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
    NSString *urlStr;
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    urlStr = [NSString stringWithFormat:@"%@/mSearch.aspx?page=%ld&keyword=%@&where=title", self.urlStr, (long) pageNum, keyword];
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
    NSString *titleXpath = @"/html/body/section/article/ul/li/h4/a";
    NSString *detailXpath = @"/html/body/section/article/ul/li/h4/a/@href";
    NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    for (NSUInteger i = 0; i < titleNodeArr.count; i++) {
        NSString *title = titleNodeArr[i].text;
        title = [Tool filterHTML:title];
        NSString *detail = detailNodeArr[i].text;
        if (self.type == WebsiteType24Fa && ![detail containsString:@"c49"]) {
            continue;
        }
        ArticleModel *result = [[ArticleModel alloc] init];
        result.name = title;
        result.detail_url = [Tool replaceDomain:self.urlStr urlStr:detail];
        NSString *picPath = @"";
        NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", self.urlStr, detail];
        NSData *detailData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:detailUrl]];
        NSString *htmlStr = [[NSString alloc] initWithData:detailData encoding:NSUTF8StringEncoding];
        TFHpple *detailDoc = [[TFHpple alloc] initWithHTMLData:detailData];
        NSString *picXpath = @"//*[@id=\"content\"]/div/img[1]/@src";
        NSArray<TFHppleElement *> *picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
        if ([picNodeArr count]) {
            picPath = picNodeArr[0].text;
        } else {
            picXpath = @"//*[@id=\"content\"]/p/img/@src";
            picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
            if ([picNodeArr count]) {
                picPath = picNodeArr[0].text;
            }
        }
        result.img_url = picPath;
        result.website_id = self.type;
        NSString *idStr = [detail stringByReplacingOccurrencesOfString:@"c49.aspx" withString:@""];
        result.aid = [[idStr stringByReplacingOccurrencesOfString:@"mn" withString:@""] intValue];
        if ([sqlTool insertTable:@"article"
                         element:@"website_id,category_id,name,detail_url,img_url,aid"
                           value:[NSString stringWithFormat:@"%lu,0,'%@','%@','%@',%ld", self.type, result.name, result.detail_url, result.img_url, (long)(unsigned long)result.aid]
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
