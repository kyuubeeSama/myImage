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

typedef enum : NSUInteger {
    tuao = 1,
    luge = 2,
    twofourfa = 3,
    qushibaike = 4,
    sxchinesegirlz = 5,
    piaoliangwanghong = 6,
    lunv = 7
} websiteType;

@implementation DataManager


/// MARK: 获取写真列表
/// @param websiteModel websiteModel
/// @param PageNum 页码
/// @param category 类型
/// @param success 成功返回
/// @param failure 失败返回
- (void)getDataWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)PageNum category:(CategoryModel *)category success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    //    拼接域名
    NSString *urlStr;
    NSString *titleXpath = @"";//标题
    NSString *detailXpath = @"";//详情
    NSString *picXpath = @"";//封面
    if (websiteModel.value == tuao || websiteModel.value == luge || websiteModel.value == lunv) {
        // 凸凹吧 & 撸哥吧
        urlStr = [NSString stringWithFormat:@"%@/category-%@_%ld.html", websiteModel.url, category.value, (long) PageNum];
        titleXpath = @"//*[@id=\"container\"]/main/article/div/a/@title";
        detailXpath = @"//*[@id=\"container\"]/main/article/div/a/@href";
        picXpath = @"//*[@id=\"container\"]/main/article/div/a/img/@src";
    } else if (websiteModel.value == twofourfa) {
        //        24fa
        urlStr = [NSString stringWithFormat:@"%@/mc%@p%ld.aspx", websiteModel.url, category.value, (long) PageNum];
        titleXpath = @"/html/body/ul[3]/li/a";
        detailXpath = @"/html/body/ul[3]/li/a/@href";
    } else if (websiteModel.value == qushibaike) {
        // 趣事百科
        urlStr = [NSString stringWithFormat:@"%@/%@%ld.html", websiteModel.url, category.value, (long) PageNum];
        titleXpath = @"/html/body/section/div/div/article/header/h2/a";
        detailXpath = @"/html/body/section/div/div/article/header/h2/a/@href";
        picXpath = @"/html/body/section/div/div/article/p[2]/a/span/span/img/@src";
    } else if (websiteModel.value == sxchinesegirlz) {
        //        sxchinesegirlz
        urlStr = [NSString stringWithFormat:@"%@/category/%@/page/%ld/", websiteModel.url, category.value, (long) PageNum];
        titleXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@title";
        detailXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@href";
        picXpath = @"//*[@id=\"content_box\"]/div/div/article/a/div[1]/img/@src";
    } else if (websiteModel.value == piaoliangwanghong) {
        //漂亮网红网
        urlStr = [NSString stringWithFormat:@"%@/jin/caitup/%@_%ld.html", websiteModel.url, category.value, (long) PageNum];
        titleXpath = @"//*[@id=\"list\"]/ul/li/a/@title";
        detailXpath = @"//*[@id=\"list\"]/ul/li/a/@href";
        picXpath = @"//*[@id=\"list\"]/ul/li/a/img/@src";
    }
    NSLog(@"网址是%@", urlStr);
    // 获取数据
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        failure(error);
        return;
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (websiteModel.value == qushibaike || websiteModel.value == piaoliangwanghong) {
        // 需要将GBK转换为可识别类型
        data = [Tool getGBKDataWithData:data];
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    // 获取漂亮网红图的搜索地址
    if (websiteModel.value == piaoliangwanghong) {
        NSString *searchXPath = @"//*[@id=\"search\"]/center/form/@action";
        NSArray <TFHppleElement *> *searchNodeArr = [xpathDoc searchWithXPathQuery:searchXPath];
        if ([searchNodeArr count]) {
            // 存在搜索地址
            // 获取搜索地址域名地址
            NSString *domainUrlStr = [Tool getDataWithRegularExpression:@"((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)" content:searchNodeArr[0].content][0];
            // 将该地址存起来
            [[NSUserDefaults standardUserDefaults]setObject:domainUrlStr forKey:@"plwhtSearchUrlStr"];
        }
    }
    NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    NSArray<TFHppleElement *> *picNodeArr = [xpathDoc searchWithXPathQuery:picXpath];
    // 循环获取内容
    for (NSUInteger i = 0; i < titleNodeArr.count; ++i) {
        NSString *title = titleNodeArr[i].text;
        NSString *picPath = @"";
        if (websiteModel.value != twofourfa) {
            picPath = picNodeArr[i].text;
        }
        NSString *detail = detailNodeArr[i].text;
        
        // 获取id
        int aid = [self getArticleIdWithWebsiteValue:websiteModel.value urlStr:detail];
        detail = [self replaceDomain:websiteModel urlStr:detail];
        // 存数据库
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        // 当前流程是，先查询是否存在，存在去判断是否需要更新分类，如果不存在，就存储，存储完后返回
        // 推荐修改流程：使用replace，如果存在就更新，如果不存在就插入，缺点是遇到24fa这种不带封面的，需要每次都去详情获取封面
        ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                     where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                     field:@"*"
                                                                     Class:[ArticleModel class]];
        if (result.name == nil) {
            if (websiteModel.value == twofourfa) {
                // 24fa的图片字段无法获取，需要在详情中获取第一张图
                NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detail];
                NSData *detailData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:detailUrl]];
                TFHpple *detailDoc = [[TFHpple alloc] initWithHTMLData:detailData];
                NSString *picXpath = @"//*[@id=\"content\"]/div/img[1]/@src";
                NSArray<TFHppleElement *> *picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
                if ([picNodeArr count]) {
                    picPath = picNodeArr[0].text;
                }else{
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
            }
            result.name = title;
            result.detail_url = detail;
            result.img_url = picPath;
            result.aid = aid;
            NSLog(@"标题是%@,详情是%@,图片地址是%@", title, detail, picPath);
            if ([sqlTool insertTable:@"article"
                             element:@"website_id,category_id,name,detail_url,img_url,aid"
                               value:[NSString stringWithFormat:@"%d,%d,'%@','%@','%@',%d", websiteModel.value, category.category_id, result.name, result.detail_url, result.img_url,result.aid]
                               where:nil]) {
                result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                               where:[NSString
                                                                      stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, result.detail_url]
                                                               field:@"*"
                                                               Class:[ArticleModel class]];
            }
        } else {
            if (result.category_id == 0) {
                // 需要更新类型，搜索的数据结果是没有分类类型的
                [sqlTool updateTable:@"article"
                               where:[NSString stringWithFormat:@"website_id=%d and detail_url='%@'", websiteModel.value, detail]
                               value:[NSString stringWithFormat:@"category_id=%d", category.category_id]];
            }
            if (result.aid == 0 && websiteModel.value != sxchinesegirlz) {
                // 更新aid
                [sqlTool updateTable:@"article"
                               where:[NSString stringWithFormat:@"website_id=%d and detail_url='%@'", websiteModel.value, detail]
                               value:[NSString stringWithFormat:@"aid=%d", aid]];
            }
        }
        [resultArr addObject:result];
    }
    success(resultArr);
}
// 获取数据id
-(int)getArticleIdWithWebsiteValue:(int)value urlStr:(NSString *)detail{
    int aid = 0;
    if (value == twofourfa) {
        //            mn80542c49.aspx
        NSString *idStr = [detail stringByReplacingOccurrencesOfString:@"c49.aspx" withString:@""];
        aid = [[idStr stringByReplacingOccurrencesOfString:@"mn" withString:@""] intValue];
    } else if (value != sxchinesegirlz) {
        //            /jin/caitu/20211217/117394.html
        NSArray<NSString *> *array = [detail componentsSeparatedByString:@"/"];
        aid = [[array.lastObject stringByReplacingOccurrencesOfString:@".html" withString:@""] intValue];
    }
    return aid;
}

/// MARK: 获取写真详情图片列表
/// @param websiteModel websiteModel
/// @param detailUrl 详情地址
/// @param progress 加载进度
/// @param success 成功返回
/// @param failure 失败返回
- (void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void (^)(NSUInteger))progress success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr = detailUrl;
    if (![detailUrl containsString:@"http"] || ![detailUrl containsString:@"https"]) {
        urlStr = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detailUrl];
    }
    if (websiteModel.value == qushibaike) {
        [self getImageWithUrl:urlStr withWebsiteValue:websiteModel withPageNum:1 success:success failure:failure];
    }else{
        NSString *imageXPath = @"";
        NSString *pageNumXPath = @"";
        if (websiteModel.value == tuao || websiteModel.value == luge || websiteModel.value == lunv) {
            imageXPath = @"/html/body/div/main/article/div[2]/a/p/img/@src";
            pageNumXPath = @"//*[@id=\"dm-fy\"]/li/a";
        }else if(websiteModel.value == twofourfa){
            imageXPath = @"/html/body/section[1]/article/div/img/@src";
            // 长度需要-1
            pageNumXPath = @"/html/body/section[1]/table/tr/td/div/ul/li/a/@href";
        }else if(websiteModel.value == sxchinesegirlz){
            // MARK:此处可能存在两种获取方式
            imageXPath = @"/html/body/div/div/article/div/div[1]/div[1]/div/div[2]/figure/img/@src";
            // 长度足够
            pageNumXPath = @"/html/body/div/div/article/div/div[1]/div[1]/div/div[3]/a";
        }else if(websiteModel.value == piaoliangwanghong){
            imageXPath = @"//*[@id=\"picg\"]/p/a/img/@src";
            pageNumXPath = @"/html/body/div[4]/div[2]/p/b/a";
        }
        
        NSError *error = nil;
        //TODO:此处发生网络错误，仍然后重复请求，应该针对发生网络错误的时候，及时停止请求，防止进一步消耗内存
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
        if (websiteModel.value == qushibaike || websiteModel.value == piaoliangwanghong) {
            data = [Tool getGBKDataWithData:data];
        }
        if (error) {
            // 网页加载错误
            NSLog(@"错误信息是%@", error.localizedDescription);
            failure(error);
            return;
        }
        // 获取总页码数量
        TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
        NSArray *pageNumArr = [xpathDoc searchWithXPathQuery:pageNumXPath];
        NSLog(@"本页图片%lu,总页数%lu",(unsigned long)imgNodeArr.count,(unsigned long)pageNumArr.count);
        NSInteger pageNum = pageNumArr.count;
        if (websiteModel.value == twofourfa) {
            pageNum -= 1;
        }
        // 创建group
        if (websiteModel.value == luge) {
            // luge图片最后一页会跳转到其他地方，所以这里要少一个页码
            pageNum --;
        }
        // 使用group设置同时访问量
        dispatch_group_t group = dispatch_group_create();
        __block NSString *blockUrlStr = urlStr;
        // 使用信号量设置同时可以运行的线程数量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
        for (NSUInteger i=1; i<=pageNum; i++) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_enter(group);
            dispatch_async(queue, ^{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                // 地址累加获取所有图片
                if (websiteModel.value == piaoliangwanghong && i != 1) {
                    blockUrlStr = [urlStr stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%ld.html",i]];
                }else if(websiteModel.value == sxchinesegirlz){
                    blockUrlStr = [NSString stringWithFormat:@"%@/%lu",urlStr,(unsigned long)i];
                }else if(websiteModel.value == tuao || websiteModel.value == luge || websiteModel.value == lunv){
                    blockUrlStr = [NSString stringWithFormat:@"%@?page=%lu", urlStr, i];
                }else if(websiteModel.value == twofourfa){
                    blockUrlStr = [urlStr stringByReplacingOccurrencesOfString:@".aspx" withString:[NSString stringWithFormat:@"p%lu.aspx", i]];
                }
                NSError *detailError = nil;
                NSData *detailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:blockUrlStr] options:NSDataReadingUncached error:&detailError];
                if (detailError) {
                    // 网页加载错误
                    NSLog(@"错误信息是%@", error.localizedDescription);
                    failure(detailError);
                }else{
                    if (websiteModel.value == piaoliangwanghong) {
                        detailData = [Tool getGBKDataWithData:detailData];
                    }
                    TFHpple *detailXpathDoc = [[TFHpple alloc] initWithHTMLData:detailData];
                    NSArray *detailImgNodeArr = [detailXpathDoc searchWithXPathQuery:imageXPath];
                    for (TFHppleElement *element in detailImgNodeArr) {
                        ImageModel *model = [[ImageModel alloc] init];
                        NSString *image_url = element.text;
                        if (websiteModel.value == sxchinesegirlz) {
                            image_url = [image_url stringByReplacingOccurrencesOfString:@"sxchinesegirlz.com" withString:@"sxchinesegirlz.one"];
                            NSLog(@"%@",image_url);
                            if ([image_url containsString:@"wp.com"]) {
                            }else{
                                if (![image_url containsString:@"jpeg"]) {
                                    NSRange beginRange = [image_url rangeOfString:@"-" options:NSBackwardsSearch];
                                   NSRange endRange = [image_url rangeOfString:([image_url containsString:@".jpg"]?@".jpg":@".png")];
                                   image_url = [image_url stringByReplacingCharactersInRange:NSMakeRange(beginRange.location, endRange.location-beginRange.location) withString:@""];
                                }
                            }
                        }
                        model.image_url = [self replaceDomain:websiteModel urlStr:image_url];
                        model.website_id = websiteModel.value;
                        [self.imageArr addObject:model];
                    }
                }
                dispatch_semaphore_signal(semaphore);
                dispatch_group_leave(group);
            });
        }
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //TODO:对已获取的文件进行排序
            
            //操作结束，block返回数据
            success(self.imageArr);
        });
    }
}

- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [[NSMutableArray alloc] init];
    }
    return _imageArr;
}

/// MARK: 递归获取每页详情
/// @param url 详情地址
/// @param websiteModel 站点m odel
/// @param pageNum 页码
/// @param success 成功block
/// @param failure 失败block
- (void)getImageWithUrl:(NSString *)url withWebsiteValue:(WebsiteModel *)websiteModel withPageNum:(NSInteger)pageNum success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr = url;
    NSString *imageXPath = @"";
    NSString *nextXpath = @"";
    if (websiteModel.value == qushibaike) {
        if (pageNum != 1) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%ld.html", (long) pageNum]];
        }
        imageXPath = @"/html/body/section/div/div/article/p[position()>1]/img/@src";
        nextXpath = @"//*[@class=\"next-page\"]";
    }
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        failure(error);
        return;
    }
    if (websiteModel.value == qushibaike) {
        data = [Tool getGBKDataWithData:data];
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
    for (TFHppleElement *element in imgNodeArr) {
        ImageModel *model = [[ImageModel alloc] init];
        model.image_url = [self replaceDomain:websiteModel urlStr:element.text];
        model.website_id = websiteModel.value;
        [self.imageArr addObject:model];
    }
    NSArray *nextNodeArr = [xpathDoc searchWithXPathQuery:nextXpath];
    if (nextNodeArr.count > 0) {
        // 有下一页
        pageNum += 1;
        [self getImageWithUrl:url withWebsiteValue:websiteModel withPageNum:pageNum success:success failure:failure];
    } else {
        // 没有下一页
        success(self.imageArr);
    }
}

/// MARK: 站点搜索
/// @param websiteModel websiteModel
/// @param pageNum 页码
/// @param keyword 搜索关键字
/// @param success 成功返回
/// @param failure 失败返回
- (void)getSearchResultWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)pageNum keyword:(NSString *)keyword success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr;
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (websiteModel.value == piaoliangwanghong) {
        urlStr = [NSString stringWithFormat:@"%@/s.asp?page=%ld&keyword=%@",websiteModel.url,(long)pageNum,keyword];
        urlStr = [Tool UTFtoGBK:urlStr];
    } else if (websiteModel.value == tuao || websiteModel.value == luge || websiteModel.value == lunv) {
        urlStr = [NSString stringWithFormat:@"%@/search.php?q=%@&page=%ld", websiteModel.url, keyword, (long) pageNum];
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else if (websiteModel.value == twofourfa) {
        urlStr = [NSString stringWithFormat:@"%@/mSearch.aspx?page=%ld&keyword=%@&where=title", websiteModel.url, (long) pageNum, keyword];
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else if (websiteModel.value == sxchinesegirlz) {
        urlStr = [NSString stringWithFormat:@"%@/page/%ld/?s=%@", websiteModel.url, (long) pageNum, keyword];
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else if (websiteModel.value == qushibaike) {
        urlStr = [NSString stringWithFormat:@"https://so.azs2019.com/serch.php?keyword=%@&page=%ld", keyword, (long) pageNum];
        urlStr = [Tool UTFtoGBK:urlStr];
    }
    NSLog(@"搜索地址是%@",urlStr);
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        failure(error);
        return;
    }
    if (websiteModel.value == qushibaike || websiteModel.value == piaoliangwanghong) {
        data = [Tool getGBKDataWithData:data];
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSString *titleXpath = @"";
    NSString *detailXpath = @"";
    NSString *imgXpath = @"";
    if (websiteModel.value == tuao || websiteModel.value == luge || websiteModel.value == lunv) {
        titleXpath = @"//*[@id=\"container\"]/main/article/div/a/@title";
        detailXpath = @"//*[@id=\"container\"]/main/article/div/a/@href";
        imgXpath = @"//*[@id=\"container\"]/main/article/div/a/img/@src";
    } else if (websiteModel.value == twofourfa) {
        //FIXME:此处获取的标题不正确
        titleXpath = @"/html/body/section/article/ul/li/h4/a";
        detailXpath = @"/html/body/section/article/ul/li/h4/a/@href";
    } else if (websiteModel.value == qushibaike) {
        titleXpath = @"/html/body/section/div/div/article/header/h2/a/@title";
        detailXpath = @"/html/body/section/div/div/article/header/h2/a/@href";
        imgXpath = @"/html/body/section/div/div/article/p[2]/a/span/span/img/@src";
    } else if (websiteModel.value == sxchinesegirlz) {
        titleXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@title";
        detailXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@href";
        imgXpath = @"//*[@id=\"content_box\"]/div/div/article/a/div[1]/img/@src";
    }else if(websiteModel.value == piaoliangwanghong){
        titleXpath = @"//*[@id=\"list\"]/ul/li/div/a/@title";
        detailXpath = @"//*[@id=\"list\"]/ul/li/div/a/@href";
        imgXpath = @"//*[@id=\"list\"]/ul/li/a/img/@src";
    }
    NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
    NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
    NSArray<TFHppleElement *> *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXpath];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    for (NSUInteger i = 0; i < titleNodeArr.count; i++) {
        NSString *title = titleNodeArr[i].text;
        title = [Tool filterHTML:title];
        NSString *detail = detailNodeArr[i].text;
        // 剔除24fa中无关的结果
        if (websiteModel.value == twofourfa && ![detail containsString:@"c49"]) {
            continue;
        }
        ArticleModel *result = [[ArticleModel alloc] init];
        result.name = title;
        if (websiteModel.value == qushibaike) {
            result.detail_url = detail;
        }else{
            result.detail_url = [self replaceDomain:websiteModel urlStr:detail];
        }
        if (websiteModel.value == twofourfa) {
            NSString *picPath = @"";
            NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detail];
            NSData *detailData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:detailUrl]];
            NSString *htmlStr = [[NSString alloc] initWithData:detailData encoding:NSUTF8StringEncoding];
            TFHpple *detailDoc = [[TFHpple alloc] initWithHTMLData:detailData];
            NSString *picXpath = @"//*[@id=\"content\"]/div/img[1]/@src";
            NSArray<TFHppleElement *> *picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
            if ([picNodeArr count]) {
                picPath = picNodeArr[0].text;
            }else{
                picXpath = @"//*[@id=\"content\"]/p/img/@src";
                picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
                if ([picNodeArr count]) {
                    picPath = picNodeArr[0].text;
                }
            }
            result.img_url = picPath;
        } else {
            NSString *imgPath = imgNodeArr[i].text;
            result.img_url = imgPath;
        }
        result.website_id = websiteModel.value;
        result.aid = [self getArticleIdWithWebsiteValue:websiteModel.value urlStr:detail];
        if ([sqlTool insertTable:@"article"
                         element:@"website_id,category_id,name,detail_url,img_url,aid"
                           value:[NSString stringWithFormat:@"%d,0,'%@','%@','%@',%d", websiteModel.value, result.name, result.detail_url, result.img_url,result.aid]
                           where:[NSString stringWithFormat:@"select * from article where detail_url = '%@'", result.detail_url]]) {
            result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                           where:[NSString
                                                                  stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, result.detail_url]
                                                           field:@"*"
                                                           Class:[ArticleModel class]];
        }
        [resultArr addObject:result];
    }
    success(resultArr);
}

// 替换图片中可能包含的域名地址
-(NSString *)replaceDomain:(WebsiteModel *)model urlStr:(NSString *)urlStr{
    if ([urlStr containsString:model.url]) {
        urlStr = [urlStr stringByReplacingOccurrencesOfString:model.url withString:@""];
    }
    return urlStr;
}

@end
