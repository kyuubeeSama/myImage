//
//  SexyAsianModel.m
//  myimage
//
//  Created by Galaxy on 2023/7/10.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import "SexyAsianModel.h"

@implementation SexyAsianModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"sexyAsianGirl";
        self.CategoryTitleArr = @[@"默认"];
        self.categoryIdsArr = @[@"0"];
    }
    return self;
}
- (nonnull NSMutableArray *)getDataWithPageNum:(NSInteger)PageNum category:(nonnull CategoryModel *)category {
    //    拼接域名
    NSString *urlStr = [NSString stringWithFormat:@"%@/?page=%ld", self.urlStr, (long) PageNum];;
    NSString *titleXpath = @"/html/body/div/div[1]/div/div[2]/a/h2";//标题
    NSString *detailXpath = @"/html/body/div/div[1]/div/div[1]/a/@href";//详情
    NSString *picXpath = @"/html/body/div/div[1]/div/div[1]/a/img/@src";//封面
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
    NSString *imageXPath = @"/html/body/div/article/div[2]/img/@src";
    NSString *pageNumXPath = @"/html/body/div/article/div[2]/div[2]/a/@href";
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
    NSArray *pageNumArr = [xpathDoc searchWithXPathQuery:pageNumXPath];
    NSLog(@"总页数%lu", (unsigned long) pageNumArr.count);
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
            blockUrlStr = [NSString stringWithFormat:@"%@?page=%ld", urlStr, (unsigned long) i];
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
    return @[].mutableCopy;
}
@end
