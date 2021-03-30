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
    lunv = 1,
    luge = 2,
    twofourfa = 3,
    qushibaike = 4,
    sxchinesegirlz = 5,
    piaoliangwanghong = 6,
} websiteType;

@implementation DataManager


/// 获取写真列表
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
    if (websiteModel.value == lunv || websiteModel.value == luge) {
        // 撸女吧 & 撸哥吧
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
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (websiteModel.value == qushibaike || websiteModel.value == piaoliangwanghong) {
        // 需要将GBK转换为可识别类型
        data = [self getGBKDataWithData:data];
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
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
        NSLog(@"标提是%@,详情是%@,图片地址是%@", title, detail, picPath);
        // 获取id
        int aid = [self getArticleIdWithWebsiteValue:websiteModel.value urlStr:detail];
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
                }
            }
            result.name = title;
            result.detail_url = detail;
            result.img_url = picPath;
            result.aid = aid;
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

/// 获取写真详情图片列表
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
    if (websiteModel.value == lunv || websiteModel.value == luge) {
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
            NSMutableArray *pageArr = [Tool getDataWithRegularExpression:@"<li><a href=\"([\\s\\S]+?)\">" content:html];
            NSMutableArray *imgListArr = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i <= pageArr.count; i++) {
                ImageModel *model = [[ImageModel alloc] init];
                NSString *relDetailUrl = [NSString stringWithFormat:@"%@?page=%lu", urlStr, i + 1];
                [NetWorkingTool getHtmlWithUrl:relDetailUrl WithData:nil success:^(NSString *html) {
                    progress(i + 1);
                    NSMutableArray *imgAreaArr = [Tool getDataWithRegularExpression:@"article-content([\\s\\S]+?)<\\/a>" content:html];
                    NSMutableArray *imgArr = [Tool getDataWithRegularExpression:@"src=\"([\\s\\S]+?)\"" content:imgAreaArr[0]];
                    NSString *imgUrl = imgArr[0];
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    model.image_url = [imgUrl stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    model.website_id = websiteModel.value;
                    [imgListArr addObject:model];
                    if (imgListArr.count == pageArr.count + 1) {
                        success(imgListArr);
                    }
                }                      failure:^(NSError *error) {
                    failure(error);
                }];
            }
        }                      failure:^(NSError *_Nonnull error) {
            failure(error);
        }];
    } else if (websiteModel.value == twofourfa) {
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
            // 获取页码
            // 获取页码  pager">([\s\S]+?)\/table> 之后加  <a([\s\S]+?)<\/a>
            // 根据页码for循环
            // 获取每页的图片
            NSMutableArray *pageContentArr = [Tool getDataWithRegularExpression:@"pager\">([\\s\\S]+?)\\/table>" content:html];
            NSMutableArray *pageArr = [[NSMutableArray alloc] init];
            if ([pageContentArr count]) {
                pageArr = [Tool getDataWithRegularExpression:@"<a([\\s\\S]+?)<\\/a>" content:pageContentArr[0]];
            } else {
//                如果只有1页
                [pageArr addObject:@""];
            }
            NSMutableArray *imgListArr = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i <= pageArr.count; i++) {
                NSString *relDetailUrl = [urlStr stringByReplacingOccurrencesOfString:@".aspx" withString:[NSString stringWithFormat:@"p%lu.aspx", i + 1]];
                [NetWorkingTool getHtmlWithUrl:relDetailUrl WithData:nil success:^(NSString *html) {
                    progress(i + 1);
                    NSString *contentRegex = @"content\">([\\s\\S]+?)<\\/article>";
                    NSString *detailStr = [Tool getDataWithRegularExpression:contentRegex content:html][0];
                    NSString *imgRegex = @"src=\"([\\s\\S]+?)\"";
                    NSMutableArray *imgArr = [Tool getDataWithRegularExpression:imgRegex content:detailStr];
                    for (NSString *imgPath in imgArr) {
                        NSString *imgStr;
                        imgStr = [imgPath stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                        imgStr = [imgStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        ImageModel *model = [[ImageModel alloc] init];
                        model.image_url = imgStr;
                        model.website_id = websiteModel.value;
                        [imgListArr addObject:model];
                    }
                    success(imgListArr);
                }                      failure:^(NSError *error) {
                    failure(error);
                }];
            }
        }                      failure:^(NSError *_Nonnull error) {
            failure(error);
        }];
    } else if (websiteModel.value == qushibaike || websiteModel.value == sxchinesegirlz || websiteModel.value == piaoliangwanghong) {
        [self getImageWithUrl:urlStr withWebsiteValue:websiteModel.value withPageNum:1 success:success failure:failure];
    }
}

- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [[NSMutableArray alloc] init];
    }
    return _imageArr;
}

/// 递归获取每页详情
/// @param url 详情地址
/// @param websiteType 站点类型
/// @param pageNum 页码
/// @param success 成功block
/// @param failure 失败block
- (void)getImageWithUrl:(NSString *)url withWebsiteValue:(websiteType)websiteType withPageNum:(NSInteger)pageNum success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr = url;
    NSString *imageXPath = @"";
    NSString *nextXpath = @"";
    if (websiteType == qushibaike || websiteType == piaoliangwanghong) {
        if (pageNum != 1) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%ld.html", (long) pageNum]];
        }
        if (websiteType == qushibaike) {
            imageXPath = @"/html/body/section/div/div/article/p[position()>1]/img/@src";
            nextXpath = @"//*[@class=\"next-page\"]";
        } else {
            imageXPath = @"//*[@id=\"picg\"]/p/a/img/@src";
        }
    } else if (websiteType == sxchinesegirlz) {
        urlStr = [NSString stringWithFormat:@"%@/%ld", urlStr, (long) pageNum];
        imageXPath = @"/html/body/div/div/article/div/div[1]/div[1]/div[2]/div[2]/figure/img/@src";
        nextXpath = @"/html/body/div/div/article/div/div[1]/div[2]/div/div[3]/a/span/span";
    }
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@", error.localizedDescription);
        failure(error);
    }
    if (websiteType == qushibaike || websiteType == piaoliangwanghong) {
        data = [self getGBKDataWithData:data];
    }
    TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
    for (TFHppleElement *element in imgNodeArr) {
        ImageModel *model = [[ImageModel alloc] init];
        model.image_url = element.text;
        model.website_id = (int) websiteType;
        [self.imageArr addObject:model];
    }
    if (websiteType == piaoliangwanghong) {
        NSString *htmlContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([htmlContent containsString:@"下一页"]) {
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:websiteType withPageNum:pageNum success:success failure:failure];
        } else {
            success(self.imageArr);
        }
    } else if (websiteType == sxchinesegirlz) {
        NSString *htmlContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([htmlContent containsString:@"class=\"currenttext\">Next</span>"]) {
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:websiteType withPageNum:pageNum success:success failure:failure];
        } else {
            success(self.imageArr);
        }
    } else {
        NSArray *nextNodeArr = [xpathDoc searchWithXPathQuery:nextXpath];
        if (nextNodeArr.count > 0) {
            // 有下一页
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:websiteType withPageNum:pageNum success:success failure:failure];
        } else {
            // 没有下一页
            success(self.imageArr);
        }
    }
}

/// gbk网页内容转utf8
/// @param data 数据
- (NSData *)getGBKDataWithData:(NSData *)data {
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *postHtmlStr = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSString *utf8HtmlStr = [postHtmlStr stringByReplacingOccurrencesOfString:@"<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    NSData *utf8HtmlData = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
    return utf8HtmlData;
}

/// 站点搜索(搜索结果不存入数据库)
/// @param websiteModel websiteModel
/// @param pageNum 页码
/// @param keyword 搜索关键字
/// @param success 成功返回
/// @param failure 失败返回
- (void)getSearchResultWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)pageNum keyword:(NSString *)keyword success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr;
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (websiteModel.value == piaoliangwanghong) {
        // 无搜索功能
        success([[NSMutableArray alloc]init]);
    } else {
        if (websiteModel.value == lunv || websiteModel.value == luge) {
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
            urlStr = [self UTFtoGBK:urlStr];
        }
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
        if (error) {
            // 网页加载错误
            NSLog(@"错误信息是%@", error.localizedDescription);
            failure(error);
        }
        if (websiteModel.value == qushibaike) {
            data = [self getGBKDataWithData:data];
        }
        TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:data];
        NSString *titleXpath = @"";
        NSString *detailXpath = @"";
        NSString *imgXpath = @"";
        if (websiteModel.value == lunv || websiteModel.value == luge) {
            titleXpath = @"//*[@id=\"container\"]/main/article/div/a/@title";
            detailXpath = @"//*[@id=\"container\"]/main/article/div/a/@href";
            imgXpath = @"//*[@id=\"container\"]/main/article/div/a/img/@src";
        } else if (websiteModel.value == twofourfa) {
            //FIXME:此处获取的标题不争取
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
        }
        NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
        NSArray<TFHppleElement *> *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXpath];
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        for (NSUInteger i = 0; i < titleNodeArr.count; i++) {
            NSString *title = titleNodeArr[i].text;
            title = [self filterHTML:title];
            NSString *detail = detailNodeArr[i].text;
            if (websiteModel.value == twofourfa && ![detail containsString:@"c49"]) {
                continue;
            }
            ArticleModel *result = [[ArticleModel alloc] init];
            result.name = title;
            result.detail_url = detail;
            if (websiteModel.value == twofourfa) {
                NSString *picPath = @"";
                NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detail];
                NSData *detailData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:detailUrl]];
                TFHpple *detailDoc = [[TFHpple alloc] initWithHTMLData:detailData];
                NSString *picXpath = @"//*[@id=\"content\"]/div/img[1]/@src";
                NSArray<TFHppleElement *> *picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
                if ([picNodeArr count]) {
                    picPath = picNodeArr[0].text;
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
}

- (NSString *)filterHTML:(NSString *)html {
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    while ([scanner isAtEnd] == NO) {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    NSArray *currentArr = @[@"&quot;", @"&amp;", @"&lt;", @"&gt;", @"&nbsp;"];
    NSArray *withArr = @[@"\"", @"&", @"<", @">", @" "];
    for (NSUInteger i = 0; i < currentArr.count; i++) {
        html = [html stringByReplacingOccurrencesOfString:currentArr[i] withString:withArr[i]];
    }
//    NSString * regEx = @"<([^>]*)>";
//    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}

/// 网页地址utf格式转gbk格式
/// @param urlStr 网页地址
- (NSString *)UTFtoGBK:(NSString *)urlStr {
    //GBK编码
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *encodeContent = [urlStr stringByAddingPercentEscapesUsingEncoding:enc];
    return encodeContent;
}

@end
//449
