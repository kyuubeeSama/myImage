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
        urlStr = [NSString stringWithFormat:@"%@/category-%@_%ld.html", websiteModel.url, category.value, (long)PageNum];
        titleXpath = @"//*[@id=\"container\"]/main/article/div/a/@title";
        detailXpath = @"//*[@id=\"container\"]/main/article/div/a/@href";
        picXpath = @"//*[@id=\"container\"]/main/article/div/a/img/@src";
    } else if (websiteModel.value == twofourfa) {
        //        24fa
        urlStr = [NSString stringWithFormat:@"%@/mc%@p%ld.aspx", websiteModel.url, category.value, (long)PageNum];
        titleXpath = @"/html/body/ul[3]/li/a";
        detailXpath = @"/html/body/ul[3]/li/a/@href";
    }else if (websiteModel.value == qushibaike){
        // 趣事百科
        urlStr = [NSString stringWithFormat:@"%@/%@%ld.html",websiteModel.url,category.value,(long)PageNum];
        titleXpath = @"/html/body/section/div/div/article/header/h2/a";
        detailXpath = @"/html/body/section/div/div/article/header/h2/a/@href";
        picXpath = @"/html/body/section/div/div/article/p[2]/a/span/span/img/@src";
    }else if (websiteModel.value == sxchinesegirlz){
//        sxchinesegirlz
        urlStr = [NSString stringWithFormat:@"%@/category/%@/page/%ld/",websiteModel.url,category.value,(long)PageNum];
        titleXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@title";
        detailXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@href";
        picXpath = @"//*[@id=\"content_box\"]/div/div/article/a/div[1]/img/@src";
    }else if(websiteModel.value == piaoliangwanghong){
        //漂亮网红网
        urlStr = [NSString stringWithFormat:@"%@/jin/caitup/%@_%ld.html",websiteModel.url,category.value,(long)PageNum];
        titleXpath = @"//*[@id=\"list\"]/ul/li/a/@title";
        detailXpath = @"//*[@id=\"list\"]/ul/li/a/@href";
        picXpath = @"//*[@id=\"list\"]/ul/li/a/img/@src";
    }
    NSLog(@"网址是%@",urlStr);
    // 获取数据
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@",error.localizedDescription);
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
        NSLog(@"标提是%@,详情是%@,图片地址是%@",title,detail,picPath);
        // 存数据库
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
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
                picPath = picNodeArr[0].text;
            }
            result.name = title;
            result.detail_url = detail;
            result.img_url = picPath;
            if ([sqlTool insertTable:@"article"
                             element:@"website_id,category_id,name,detail_url,img_url"
                               value:[NSString stringWithFormat:@"%d,%d,'%@','%@','%@'", websiteModel.value,category.category_id, result.name, result.detail_url, result.img_url]
                               where:nil]) {
                result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                               where:[NSString
                                                                      stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, result.detail_url]
                                                               field:@"*"
                                                               Class:[ArticleModel class]];
            }
        }else{
            if (result.category_id == 0) {
                // 需要更新类型
                [sqlTool updateTable:@"article"
                               where:[NSString stringWithFormat:@"website_id=%d and detail_url='%@'",websiteModel.value,detail]
                               value:[NSString stringWithFormat:@"category_id=%d",category.category_id]];
            }
        }
        [resultArr addObject:result];
    }
    success(resultArr);
}

/// 获取写真详情图片列表
/// @param websiteModel websiteModel
/// @param detailUrl 详情地址
/// @param progress 加载进度
/// @param success 成功返回
/// @param failure 失败返回
-(void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void (^)(NSUInteger))progress success:(void (^)(NSMutableArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
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
    }else if(websiteModel.value == twofourfa){
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
            // 获取页码
            // 获取页码  pager">([\s\S]+?)\/table> 之后加  <a([\s\S]+?)<\/a>
            // 根据页码for循环
            // 获取每页的图片
            NSMutableArray *pageContentArr = [Tool getDataWithRegularExpression:@"pager\">([\\s\\S]+?)\\/table>" content:html];
            NSMutableArray *pageArr = [Tool getDataWithRegularExpression:@"<a([\\s\\S]+?)<\\/a>" content:pageContentArr[0]];
            NSMutableArray *imgListArr = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i <= pageArr.count; i++) {
                NSString *relDetailUrl = [urlStr stringByReplacingOccurrencesOfString:@".aspx" withString:[NSString stringWithFormat:@"p%lu.aspx",i+1]];
                [NetWorkingTool getHtmlWithUrl:relDetailUrl WithData:nil success:^(NSString *html) {
                    progress(i + 1);
                    NSString *contentRegex = @"content\">([\\s\\S]+?)<\\/article>";
                    NSString *detailStr = [Tool getDataWithRegularExpression:contentRegex content:html][0];
                    NSString *imgRegex = @"src=\"([\\s\\S]+?)\"";
                    NSMutableArray *imgArr = [Tool getDataWithRegularExpression:imgRegex content:detailStr];
                    for (NSString *imgPath in imgArr){
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
    }else if (websiteModel.value == qushibaike || websiteModel.value == sxchinesegirlz || websiteModel.value == piaoliangwanghong){
        [self getImageWithUrl:urlStr withWebsiteValue:websiteModel.value withPageNum:1 success:success failure:failure];
    }
}

-(NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [[NSMutableArray alloc]init];
    }
    return _imageArr;
}

/// 递归获取每页详情
/// @param url 详情地址
/// @param websiteType 站点类型
/// @param pageNum 页码
/// @param success 成功block
/// @param failure 失败block
-(void)getImageWithUrl:(NSString *)url withWebsiteValue:(websiteType)websiteType withPageNum:(NSInteger)pageNum success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure{
    NSString *urlStr = url;
    NSString *imageXPath = @"";
    NSString *nextXpath = @"";
    if (websiteType == qushibaike || websiteType == piaoliangwanghong) {
        if (pageNum != 1) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%ld.html",(long)pageNum]];
        }
        if (websiteType == qushibaike) {
            imageXPath = @"/html/body/section/div/div/article/p[position()>1]/img/@src";
            nextXpath = @"//*[@class=\"next-page\"]";
        }else{
            imageXPath = @"//*[@id=\"picg\"]/p/a/img/@src";
        }
    }else if(websiteType == sxchinesegirlz){
        urlStr = [NSString stringWithFormat:@"%@/%ld",urlStr,(long)pageNum];
        imageXPath = @"/html/body/div/div/article/div/div[1]/div[2]/div/div[2]/figure/img/@src";
        nextXpath = @"/html/body/div/div/article/div/div[1]/div[2]/div/div[3]/a/span/span";
    }
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&error];
    if (error) {
        // 网页加载错误
        NSLog(@"错误信息是%@",error.localizedDescription);
        failure(error);
    }
    if (websiteType == qushibaike || websiteType == piaoliangwanghong) {
        data = [self getGBKDataWithData:data];
    }
    TFHpple *xpathDoc = [[TFHpple alloc]initWithHTMLData:data];
    NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
    for (TFHppleElement *element in imgNodeArr) {
        NSLog(@"%@",element.text);
        ImageModel *model = [[ImageModel alloc]init];
        model.image_url = element.text;
        model.website_id = (int)websiteType;
        [self.imageArr addObject:model];
    }
    if (websiteType == piaoliangwanghong) {
        NSString *htmlContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([htmlContent containsString:@"下一页"]) {
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:websiteType withPageNum:pageNum success:success failure:failure];
        }else{
            success(self.imageArr);
        }
    }else{
        NSArray *nextNodeArr = [xpathDoc searchWithXPathQuery:nextXpath];
        if (nextNodeArr.count>0){
            // 有下一页
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:websiteType withPageNum:pageNum success:success failure:failure];
        }else{
            // 没有下一页
            success(self.imageArr);
        }
    }
}

/// gbk网页内容转utf8
/// @param data 数据
-(NSData *)getGBKDataWithData:(NSData *)data{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *postHtmlStr = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSString *utf8HtmlStr = [postHtmlStr stringByReplacingOccurrencesOfString:@"<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    NSData *utf8HtmlData = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
    return utf8HtmlData;
}

/// 站点搜索
/// @param websiteModel websiteModel
/// @param pageNum 页码
/// @param keyword 搜索关键字
/// @param success 成功返回
/// @param failure 失败返回
-(void)getSearchResultWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)pageNum keyword:(NSString *)keyword success:(void (^)(NSMutableArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    NSString *urlStr;
    NSMutableArray *resultArr = [[NSMutableArray alloc]init];
    if (websiteModel.value == lunv) {
        // 撸女吧
    }else if (websiteModel.value == luge){
        // 撸哥吧
    }else if(websiteModel.value == twofourfa){
        // 24fa
        //       http://www.24fa.cc/mSearch.aspx?page=1&keyword=%E6%9F%9A%E6%9C%A8&where=title
        urlStr = [NSString stringWithFormat:@"%@/mSearch.aspx?page=%ld&keyword=%@&where=title",websiteModel.url,(long)pageNum,keyword];
        // 链接中含有汉字，需要格式化
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString * _Nonnull html) {
            NSMutableArray *resultArr = [[NSMutableArray alloc]init];
            NSLog(@"%@",html);
            //            nl">([\s\S]+?)<\/ul> 获取列表，选择结果第二个arr[1]
            NSString *strRegex = @"article([\\s\\S]+?)<\\/article>";
            //            NSString *content = [Tool getDataWithRegularExpression:strRegex content:html][1];
            NSMutableArray *contentArr = [Tool getDataWithRegularExpression:strRegex content:html];
            NSString *content = contentArr[0];
            // 获取具体的内容  li>([\s\S]+?)<\/li>
            NSString *articleRegex = @"li>([\\s\\S]+?)<\\/li>";
            NSMutableArray *articleArr = [Tool getDataWithRegularExpression:articleRegex content:content];
            for (NSUInteger i = 0; i < articleArr.count; i++) {
                NSString *article = articleArr[i];
                // 标题： \/i>([\s\S]+?)<  加 title="([\s\S]+?)"  加">([\s\S]+?)</a>
                // 详情地址：href="([\s\S]+?)"
                // 封面:   首先拼接地址，今日详情，获取详情图片区域  content">([\s\S]+?)<\/article>,获取图片src="([\s\S]+?)"取第一张[0]
                NSLog(@"当前执行到第%lu次循环", (unsigned long)i);
                ArticleModel *model = [[ArticleModel alloc] init];
                NSMutableArray *detailArr = [Tool getDataWithRegularExpression:@"href=\"([\\s\\S]+?)\"" content:article];
                NSString *detail = detailArr[0];
                detail = [detail stringByReplacingOccurrencesOfString:@"href=\"" withString:@""];
                detail = [detail stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                SqliteTool *sqlTool = [SqliteTool sharedInstance];
                ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                             where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                             field:@"*"
                                                                             Class:[ArticleModel class]];
                if (result.name == nil) {
                    NSString *title;
                    NSMutableArray *titleArr = [Tool getDataWithRegularExpression:@"title=\"([\\s\\S]+?)\"" content:article];
                    if (titleArr.count>0){
                        title = titleArr[0];
                        title = [title stringByReplacingOccurrencesOfString:@"title=\"" withString:@""];
                        title = [title stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    }else{
                        titleArr = [Tool getDataWithRegularExpression:@"/i>([\\s\\S]+?)<" content:article];
                        if (titleArr.count>0){
                            title = titleArr[0];
                            title = [title stringByReplacingOccurrencesOfString:@"/i>" withString:@""];
                            title = [title stringByReplacingOccurrencesOfString:@"<" withString:@""];
                        }else{
                            titleArr = [Tool getDataWithRegularExpression:@"\">([\\s\\S]+?)</a>" content:article];
                            title = titleArr[0];
                            title = [title stringByReplacingOccurrencesOfString:@"\">" withString:@""];
                            title = [title stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
                            title = [title stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
                            title = [title stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
                        }
                    }
                    NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detail];
                    [NetWorkingTool getHtmlWithUrl:detailUrl WithData:nil success:^(NSString *html) {
                        NSString *contentRegex = @"content\">([\\s\\S]+?)<\\/article>";
                        NSString *detailStr = [Tool getDataWithRegularExpression:contentRegex content:html][0];
                        NSString *imgRegex = @"src=\"([\\s\\S]+?)\"";
                        NSString *imgPath = [Tool getDataWithRegularExpression:imgRegex content:detailStr][0];
                        imgPath = [imgPath stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                        imgPath = [imgPath stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        model.name = title;
                        model.detail_url = detail;
                        model.img_url = imgPath;
                        if ([sqlTool insertTable:@"article"
                                         element:@"website_id,category_id,name,detail_url,img_url"
                                           value:[NSString stringWithFormat:@"%d,0,\"%@\",'%@','%@'", websiteModel.value, model.name, model.detail_url, model.img_url]
                                           where:nil]) {
                            ArticleModel *newModel = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                                           where:[NSString
                                                                                                  stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, model.detail_url]
                                                                                           field:@"*"
                                                                                           Class:[ArticleModel class]];
                            [resultArr addObject:newModel];
                        }
                        if (resultArr.count == articleArr.count){
                            success(resultArr);
                        }
                        
                    }                      failure:nil];
                } else {
                    model = result;
                    [resultArr addObject:model];
                    if (resultArr.count == articleArr.count){
                        success(resultArr);
                    }
                }
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }else if(websiteModel.value == qushibaike){
        // 趣事百科
        //    https://so.azs2019.com/serch.php?keyword=%E8%D6%C4%BE&page=1
        urlStr = [NSString stringWithFormat:@"https://so.azs2019.com/serch.php?keyword=%@&page=%ld",keyword,(long)pageNum];
        urlStr = [self UTFtoGBK:urlStr];
        NSData *data = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:urlStr]];
        NSData *utf8HtmlData = [self getGBKDataWithData:data];
        TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:utf8HtmlData];
        NSString *titleXpath = @"/html/body/section/div/div/article/header/h2/a/@title";
        NSString *detailXpath = @"/html/body/section/div/div/article/header/h2/a/@href";
        NSString *imgXpath = @"/html/body/section/div/div/article/p[2]/a/span/span/img/@src";
        NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
        NSArray<TFHppleElement *> *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXpath];
        for (NSUInteger i = 0; i < titleNodeArr.count; ++i) {
            NSString *title = titleNodeArr[i].text;
            NSString *detail = detailNodeArr[i].text;
            NSString *imgPath = imgNodeArr[i].text;
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                         where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                         field:@"*"
                                                                         Class:[ArticleModel class]];
            if (result.name == nil) {
                result.name = title;
                result.detail_url = detail;
                result.img_url = imgPath;
                if ([sqlTool insertTable:@"article"
                                 element:@"website_id,category_id,name,detail_url,img_url"
                                   value:[NSString stringWithFormat:@"%d,0,'%@','%@','%@'", websiteModel.value, result.name, result.detail_url, result.img_url]
                                   where:nil]) {
                    result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                   where:[NSString
                                                                           stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, result.detail_url]
                                                                   field:@"*"
                                                                   Class:[ArticleModel class]];
                }
            }
            [resultArr addObject:result];
        }
        success(resultArr);
    }
}


/// 网页地址utf格式转gbk格式
/// @param urlStr 网页地址
-(NSString *)UTFtoGBK:(NSString *)urlStr{
    //GBK编码
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *encodeContent = [urlStr stringByAddingPercentEscapesUsingEncoding:enc];
    return encodeContent;
}

@end
