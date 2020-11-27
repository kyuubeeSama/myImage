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

@implementation DataManager


/// 获取写真列表
/// @param websiteModel websiteModel
/// @param PageNum 页码
/// @param category 类型
/// @param success 成功返回
/// @param failure 失败返回
- (void)getDataWithType:(WebsiteModel *)websiteModel pageNum:(int)PageNum category:(CategoryModel *)category success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr;
    if (websiteModel.value == 1) {
        // 撸女吧
        urlStr = [NSString stringWithFormat:@"%@/category-%@_%d.html", websiteModel.url, category.value, PageNum];
    } else if (websiteModel.value == 2) {
        // 撸哥吧
        urlStr = [NSString stringWithFormat:@"%@/category-%@_%d.html", websiteModel.url, category.value, PageNum];
    } else if (websiteModel.value == 3) {
        //        24fa
        urlStr = [NSString stringWithFormat:@"%@/mc%@p%d.aspx", websiteModel.url, category.value, PageNum];
    }else if (websiteModel.value == 4){
        // 趣事百科
        urlStr = [NSString stringWithFormat:@"%@/%@%d.html",websiteModel.url,category.value,PageNum];
    }else if (websiteModel.value == 5){
//        sxchinesegirlz
        urlStr = [NSString stringWithFormat:@"%@/category/%@/page/%d/",websiteModel.url,category.value,PageNum];
    }else if(websiteModel.value == 6){
        //漂亮网红网
        urlStr = [NSString stringWithFormat:@"%@/jin/caitup/%@_%d.html",websiteModel.url,category.value,PageNum];
    }
    NSLog(@"网址是%@",urlStr);
    NSData *data = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:urlStr]];
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (websiteModel.value == 4) {
        NSData *utf8HtmlData = [self getGBKDataWithData:data];
        TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:utf8HtmlData];
        NSString *titleXpath = @"/html/body/section/div/div/article/header/h2/a";
        NSString *detailXpath = @"/html/body/section/div/div/article/header/h2/a/@href";
        NSString *picXpath = @"/html/body/section/div/div/article/p[2]/a/span/span/img/@src";
        NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
        NSArray<TFHppleElement *> *picNodeArr = [xpathDoc searchWithXPathQuery:picXpath];
        for (int i = 0; i < titleNodeArr.count; ++i) {
            NSString *title = titleNodeArr[i].text;
            NSString *picPath = picNodeArr[i].text;
            NSString *detail = detailNodeArr[i].text;
            NSLog(@"标提是%@,详情是%@,图片地址是%@",title,detail,picPath);
            // 存数据库
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                         where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                         field:@"*"
                                                                         Class:[ArticleModel class]];
            if (result.name == nil) {
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
    } else if(websiteModel.value == 3){
//        24fa
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        NSString *titleXpath = @"/html/body/ul[3]/li/a";
        NSString *detailXpath = @"/html/body/ul[3]/li/a/@href";
        NSArray<TFHppleElement *> *titleNodeArr = [doc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [doc searchWithXPathQuery:detailXpath];
        for (int i = 0; i < titleNodeArr.count; ++i) {
            NSString *title = titleNodeArr[i].text;
            NSString *detail = detailNodeArr[i].text;
            NSLog(@"封面是%@,详情是%@",title,detail);
            ArticleModel *model = [[ArticleModel alloc] init];
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                         where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                         field:@"*"
                                                                         Class:[ArticleModel class]];
            if (result.name == nil) {
                NSString *detailUrl = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detail];
                NSData *detailData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:detailUrl]];
                TFHpple *detailDoc = [[TFHpple alloc] initWithHTMLData:detailData];
                NSString *picXpath = @"//*[@id=\"content\"]/div/img[1]/@src";
                NSArray<TFHppleElement *> *picNodeArr = [detailDoc searchWithXPathQuery:picXpath];
                model.name = title;
                model.detail_url = detail;
                model.img_url = picNodeArr[0].text;
                if ([sqlTool insertTable:@"article"
                                 element:@"website_id,category_id,name,detail_url,img_url"
                                   value:[NSString stringWithFormat:@"%d,%d,\"%@\",'%@','%@'", websiteModel.value, category.category_id, model.name, model.detail_url, model.img_url]
                                   where:nil]) {
                    ArticleModel *newModel = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                                   where:[NSString
                                                                                           stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, model.detail_url]
                                                                                   field:@"*"
                                                                                   Class:[ArticleModel class]];
                    [resultArr addObject:newModel];
                }
            }else {
                if (result.category_id == 0) {
                    // 需要更新类型
                    [sqlTool updateTable:@"article" where:[NSString stringWithFormat:@"website_id=%d and detail_url='%@'",websiteModel.value,detail] value:[NSString stringWithFormat:@"category_id=%d",category.category_id]];
                }
                model = result;
                [resultArr addObject:model];
                if (resultArr.count == titleNodeArr.count){
                    success(resultArr);
                }
            }
        }
        success(resultArr);
    } else if(websiteModel.value == 5){
        TFHpple *xpathDoc = [[TFHpple alloc]initWithHTMLData:data];
        NSString *titleXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@title";
        NSString *detailXpath = @"//*[@id=\"content_box\"]/div/div/article/a/@href";
        NSString *picXpath = @"//*[@id=\"content_box\"]/div/div/article/a/div[1]/img/@src";
        NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
        NSArray<TFHppleElement *> *picNodeArr = [xpathDoc searchWithXPathQuery:picXpath];
        for (NSUInteger i=0; i<titleNodeArr.count; i++) {
            ArticleModel *model = [[ArticleModel alloc] init];
            NSString *title = titleNodeArr[i].text;
            NSString *imgPath = picNodeArr[i].text;
            NSString *detail = detailNodeArr[i].text;
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                         where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                         field:@"*"
                                                                         Class:[ArticleModel class]];
            if (result.name == nil) {
                model.name = title;
                model.detail_url = [detail stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                model.img_url = [imgPath stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                if ([sqlTool insertTable:@"article"
                                 element:@"website_id,category_id,name,detail_url,img_url"
                                   value:[NSString stringWithFormat:@"%d,%d,'%@','%@','%@'", websiteModel.value,category.category_id, model.name, model.detail_url, model.img_url]
                                   where:nil]) {
                    model = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                  where:[NSString
                                                                         stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, model.detail_url]
                                                                  field:@"*"
                                                                  Class:[ArticleModel class]];
                }
            } else {
                model = result;
            }
            [resultArr addObject:model];
        }
        success(resultArr);
    } else if(websiteModel.value == 6){
        NSData *utf8HtmlData = [self getGBKDataWithData:data];
        TFHpple *doc = [[TFHpple alloc]initWithHTMLData:utf8HtmlData];
        NSString *titleXpath = @"//*[@id=\"list\"]/ul/li/a/@title";
        NSString *detailXpath = @"//*[@id=\"list\"]/ul/li/a/@href";
        NSString *imgXpath = @"//*[@id=\"list\"]/ul/li/a/img/@src";
        NSArray<TFHppleElement *> *titleNodeArr = [doc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [doc searchWithXPathQuery:detailXpath];
        NSArray<TFHppleElement *> *imgNodeArr = [doc searchWithXPathQuery:imgXpath];
        for (NSUInteger i=0; i<titleNodeArr.count; i++) {
            ArticleModel *model = [[ArticleModel alloc]init];
            NSString *detail = detailNodeArr[i].text;
            NSString *title = titleNodeArr[i].text;
            NSString *imgPath = imgNodeArr[i].text;
//            NSLog(@"标题是%@ 封面是%@ 详情是%@",title,imgPath,detail);
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                         where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                         field:@"*"
                                                                         Class:[ArticleModel class]];
            if (result.name == nil) {
                model.name = title;
                model.detail_url = [detail stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                model.img_url = [imgPath stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                if ([sqlTool insertTable:@"article"
                                 element:@"website_id,category_id,name,detail_url,img_url"
                                   value:[NSString stringWithFormat:@"%d,%d,'%@','%@','%@'", websiteModel.value,category.category_id, model.name, model.detail_url, model.img_url]
                                   where:nil]) {
                    model = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                  where:[NSString
                                                                         stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, model.detail_url]
                                                                  field:@"*"
                                                                  Class:[ArticleModel class]];
                }
            } else {
                model = result;
            }
            [resultArr addObject:model];
        }
        success(resultArr);
    } else{
        // lunv和luge
            TFHpple *doc = [[TFHpple alloc]initWithHTMLData:data];
            NSString *titleXpath = @"//*[@id=\"container\"]/main/article/div/a/@title";
            NSString *detailXpath = @"//*[@id=\"container\"]/main/article/div/a/@href";
            NSString *imgXpath = @"//*[@id=\"container\"]/main/article/div/a/img/@src";
            NSArray<TFHppleElement *> *titleNodeArr = [doc searchWithXPathQuery:titleXpath];
            NSArray<TFHppleElement *> *detailNodeArr = [doc searchWithXPathQuery:detailXpath];
            NSArray<TFHppleElement *> *imgNodeArr = [doc searchWithXPathQuery:imgXpath];
            for (NSUInteger i=0; i<titleNodeArr.count; i++) {
                ArticleModel *model = [[ArticleModel alloc] init];
                NSString *detail = detailNodeArr[i].text;
                NSString *title = titleNodeArr[i].text;
                NSString *imgPath = imgNodeArr[i].text;
                SqliteTool *sqlTool = [SqliteTool sharedInstance];
                ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                             where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detail]
                                                                             field:@"*"
                                                                             Class:[ArticleModel class]];
                if (result.name == nil) {
                    model.name = title;
                    model.detail_url = [detail stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    model.img_url = [imgPath stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    if ([sqlTool insertTable:@"article"
                                     element:@"website_id,category_id,name,detail_url,img_url"
                                       value:[NSString stringWithFormat:@"%d,%d,'%@','%@','%@'", websiteModel.value,category.category_id, model.name, model.detail_url, model.img_url]
                                       where:nil]) {
                        model = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                      where:[NSString
                                                                             stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, model.detail_url]
                                                                      field:@"*"
                                                                      Class:[ArticleModel class]];
                    }
                } else {
                    model = result;
                }
                [resultArr addObject:model];
            }
        success(resultArr);
    }
}

- (void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void (^)(int page))progress success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr = detailUrl;
    if (![detailUrl containsString:@"http"] || ![detailUrl containsString:@"https"]) {
        urlStr = [NSString stringWithFormat:@"%@/%@", websiteModel.url, detailUrl];
    }
    if (websiteModel.value == 1) {
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
            // 获取页码
            NSMutableArray *pageArr = [Tool getDataWithRegularExpression:@"<li><a href=\"([\\s\\S]+?)\">" content:html];
            NSMutableArray *imgListArr = [[NSMutableArray alloc] init];
            for (int i = 0; i <= pageArr.count; i++) {
                ImageModel *model = [[ImageModel alloc] init];
                NSString *relDetailUrl = [NSString stringWithFormat:@"%@?page=%d", urlStr, i + 1];
                [NetWorkingTool getHtmlWithUrl:relDetailUrl WithData:nil success:^(NSString *html) {
                    progress(i + 1);
                    NSMutableArray *imgAreaArr = [Tool getDataWithRegularExpression:@"article-content([\\s\\S]+?)<\\/a>" content:html];
                    NSMutableArray *imgArr = [Tool getDataWithRegularExpression:@"src=\"([\\s\\S]+?)\"" content:imgAreaArr[0]];
                    NSString *imgUrl = imgArr[0];
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    model.image_url = [imgUrl stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    model.website_id = websiteModel.website_id;
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
    } else if (websiteModel.value == 2) {
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
            // 获取页码
            NSMutableArray *pageArr = [Tool getDataWithRegularExpression:@"<li><a href=\"([\\s\\S]+?)\">" content:html];
            NSMutableArray *imgListArr = [[NSMutableArray alloc] init];
            for (int i = 0; i <= pageArr.count; i++) {
                ImageModel *model = [[ImageModel alloc] init];
                model.website_id = websiteModel.value;
                NSString *relDetailUrl = [NSString stringWithFormat:@"%@?page=%d", urlStr, i + 1];
                [NetWorkingTool getHtmlWithUrl:relDetailUrl WithData:nil success:^(NSString *html) {
                    NSMutableArray *imgAreaArr = [Tool getDataWithRegularExpression:@"article-content([\\s\\S]+?)<\\/a>" content:html];
                    NSMutableArray *imgArr = [Tool getDataWithRegularExpression:@"src=\"([\\s\\S]+?)\"" content:imgAreaArr[0]];
                    NSString *imgUrl = imgArr[0];
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    model.image_url = [imgUrl stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    NSLog(@"图片地址是%@", model.image_url);
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
    }else if(websiteModel.value == 3){
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
            // 获取页码
            // 获取页码  pager">([\s\S]+?)\/table> 之后加  <a([\s\S]+?)<\/a>
            // 根据页码for循环
            // 获取每页的图片
            NSMutableArray *pageContentArr = [Tool getDataWithRegularExpression:@"pager\">([\\s\\S]+?)\\/table>" content:html];
            NSMutableArray *pageArr = [Tool getDataWithRegularExpression:@"<a([\\s\\S]+?)<\\/a>" content:pageContentArr[0]];
            NSMutableArray *imgListArr = [[NSMutableArray alloc] init];
            for (int i = 0; i <= pageArr.count; i++) {
                NSString *relDetailUrl = [urlStr stringByReplacingOccurrencesOfString:@".aspx" withString:[NSString stringWithFormat:@"p%d.aspx",i+1]];
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
    }else if (websiteModel.value == 4 || websiteModel.value == 5 || websiteModel.value == 6){
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
/// @param value 站点id
/// @param pageNum 页码
/// @param success 成功block
/// @param failure 失败block
-(void)getImageWithUrl:(NSString *)url withWebsiteValue:(int)value withPageNum:(int)pageNum success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure{
    NSString *urlStr = url;
    if (value == 4) {
        if (pageNum != 1) {
            urlStr = [url stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%d.html",pageNum]];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        NSData *utf8HtmlData = [self getGBKDataWithData:data];
        TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:utf8HtmlData];
        NSString *imageXPath = @"/html/body/section/div/div/article/p[position()>1]/img/@src";
        NSArray *imageNodeArr = [xpathDoc searchWithXPathQuery:imageXPath];
        for( TFHppleElement *element in imageNodeArr){
            NSLog(@"%@",element.text);
            ImageModel *model = [[ImageModel alloc]init];
            model.image_url = element.text;
            model.website_id = value;
            [self.imageArr addObject:model];
        }
        // 获取下一页信息
        NSString *nextXpath = @"//*[@class=\"next-page\"]";
        NSArray *nextNodeArr = [xpathDoc searchWithXPathQuery:nextXpath];
    //    NSLog(@"%d",nextNodeArr.count);
        if (nextNodeArr.count>0){
            // 有下一页
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:value withPageNum:pageNum success:success failure:failure];
        }else{
            // 没有下一页
            success(self.imageArr);
        }
    }else if(value == 5){
        urlStr = [NSString stringWithFormat:@"%@/%d",urlStr,pageNum];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        NSLog(@"详情是%@",urlStr);
        TFHpple *xpathDoc = [[TFHpple alloc]initWithHTMLData:data];
        NSString *imgXPath = @"//*[@id=\"post-160224\"]/div[2]/div/div[2]/figure/img/@src";
        NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXPath];
        for (TFHppleElement *element in imgNodeArr) {
            NSLog(@"%@",element.text);
            ImageModel *model = [[ImageModel alloc]init];
            model.image_url = element.text;
            model.website_id = value;
            [self.imageArr addObject:model];
        }
        //TODO:判断是否有下一页
        NSString *nextXpath = @"/html/body/div/div/article/div/div[1]/div[2]/div/div[3]/a/span/span";
        NSArray *nextNodeArr = [xpathDoc searchWithXPathQuery:nextXpath];
        TFHppleElement *lastElement = nextNodeArr.lastObject;
        NSLog(@"最后一个值是%@",lastElement.text);
        if ([lastElement.text isEqualToString:@"Next"]) {
            //                有下一页
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:value withPageNum:pageNum success:success failure:failure];
        }else{
            success(self.imageArr);
        }
    }else if(value == 6){
        if (pageNum != 1) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%d.html",pageNum]];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        NSLog(@"详情是%@",urlStr);
        NSData *utfHtmlData = [self getGBKDataWithData:data];
        TFHpple *xpathDoc = [[TFHpple alloc]initWithHTMLData:utfHtmlData];
        NSString *imgXPath = @"//*[@id=\"picg\"]/p/a/img/@src";
        NSArray *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXPath];
        for (TFHppleElement *element in imgNodeArr) {
            NSLog(@"%@",element.text);
            ImageModel *model = [[ImageModel alloc]init];
            model.image_url = element.text;
            model.website_id = value;
            [self.imageArr addObject:model];
        }
        // 获取下一页
        NSString *htmlContent = [[NSString alloc] initWithData:utfHtmlData encoding:NSUTF8StringEncoding];
        if ([htmlContent containsString:@"下一页"]) {
            pageNum += 1;
            [self getImageWithUrl:url withWebsiteValue:value withPageNum:pageNum success:success failure:failure];
        }else{
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

// 搜索
-(void)getSearchResultWithType:(WebsiteModel *)websiteModel pageNum:(NSInteger)pageNum keyword:(NSString *)keyword success:(void (^)(NSMutableArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    NSString *urlStr;
    NSMutableArray *resultArr = [[NSMutableArray alloc]init];
    if (websiteModel.value == 1) {
        // 撸女吧
    }else if (websiteModel.value == 2){
        // 撸哥吧
    }else if(websiteModel.value == 3){
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
            for (int i = 0; i < articleArr.count; i++) {
                NSString *article = articleArr[(NSUInteger) i];
                // 标题： \/i>([\s\S]+?)<  加 title="([\s\S]+?)"  加">([\s\S]+?)</a>
                // 详情地址：href="([\s\S]+?)"
                // 封面:   首先拼接地址，今日详情，获取详情图片区域  content">([\s\S]+?)<\/article>,获取图片src="([\s\S]+?)"取第一张[0]
                NSLog(@"当前执行到第%d次循环", i);
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
    }else if(websiteModel.value == 4){
        // 趣事百科
        //    https://so.azs2019.com/serch.php?keyword=%E8%D6%C4%BE&page=1
        urlStr = [NSString stringWithFormat:@"https://so.azs2019.com/serch.php?keyword=%@&page=%ld",keyword,(long)pageNum];
        urlStr = [self UTFtoGBK:urlStr];
    }
    
    if (websiteModel.value == 4) {
        NSData *data = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:urlStr]];
        NSData *utf8HtmlData = [self getGBKDataWithData:data];
        TFHpple *xpathDoc = [[TFHpple alloc] initWithHTMLData:utf8HtmlData];
        NSString *titleXpath = @"/html/body/section/div/div/article/header/h2/a/@title";
        NSString *detailXpath = @"/html/body/section/div/div/article/header/h2/a/@href";
        NSString *imgXpath = @"/html/body/section/div/div/article/p[2]/a/span/span/img/@src";
        NSArray<TFHppleElement *> *titleNodeArr = [xpathDoc searchWithXPathQuery:titleXpath];
        NSArray<TFHppleElement *> *detailNodeArr = [xpathDoc searchWithXPathQuery:detailXpath];
        NSArray<TFHppleElement *> *imgNodeArr = [xpathDoc searchWithXPathQuery:imgXpath];
        for (int i = 0; i < titleNodeArr.count; ++i) {
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
    }else{
        NSLog(@"%@",urlStr);
        [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString * _Nonnull html) {
            // 获取搜索结果
            NSLog(@"%@",html);
            NSMutableArray *resultArr = [[NSMutableArray alloc]init];
            if (websiteModel.value == 1) {
                
            }else if(websiteModel.value == 4){
                // 趣事百科
                NSString *articleRegex = @"<article([\\s\\S]+?)article>";
                NSMutableArray *articleArr = [Tool getDataWithRegularExpression:articleRegex content:html];
                for (NSString *article in articleArr) {
                    // 获取标题
                    //            title="([\s\S]+?)"
                    NSString *titleRegex = @"title=\"([\\s\\S]+?)\"";
                    NSString *titleStr = [Tool getDataWithRegularExpression:titleRegex content:article][0];
                    titleStr = [titleStr stringByReplacingOccurrencesOfString:@"title=\"" withString:@""];
                    titleStr = [titleStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    // 获取封面
                    //src="([\s\S]+?)"
                    NSString *picRegex = @"src=\"([\\s\\S]+?)\"";
                    NSString *picStr = [Tool getDataWithRegularExpression:picRegex content:article][0];
                    picStr = [picStr stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                    picStr = [picStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    // 详情
                    //            href="([\s\S]+?)"  array[1]
                    NSString *detailRegex = @"href=\"([\\s\\S]+?)\"";
                    NSString *detailStr = [Tool getDataWithRegularExpression:detailRegex content:article][1];
                    detailStr = [detailStr stringByReplacingOccurrencesOfString:@"href=\"" withString:@""];
                    detailStr = [detailStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    SqliteTool *sqlTool = [SqliteTool sharedInstance];
                    ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                                 where:[NSString stringWithFormat:@"website_id = %d and detail_url = '%@'", websiteModel.value, detailStr]
                                                                                 field:@"*"
                                                                                 Class:[ArticleModel class]];
                    if (result.name == nil) {
                        result.name = titleStr;
                        result.detail_url = detailStr;
                        result.img_url = picStr;
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
        } failure:^(NSError * _Nonnull error) {
            failure(error);
        }];
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
