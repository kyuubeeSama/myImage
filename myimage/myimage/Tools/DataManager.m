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

@implementation DataManager

+ (void)getDataWithType:(WebsiteModel *)websiteModel pageNum:(int)PageNum category:(NSString *)category success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr;
    if (websiteModel.value == 1) {
        // 撸女吧
        urlStr = [NSString stringWithFormat:@"%@/category-%@_%d.html", websiteModel.url, category, PageNum];
    } else if (websiteModel.value == 2) {
        // 撸哥吧
        urlStr = [NSString stringWithFormat:@"%@/category-%@_%d.html", websiteModel.url, category, PageNum];
    } else if (websiteModel.value == 3) {
//        24fa
        urlStr = [NSString stringWithFormat:@"%@/mc%@p%d.aspx", websiteModel.url, category, PageNum];
    }
    [NetWorkingTool getHtmlWithUrl:urlStr WithData:nil success:^(NSString *_Nonnull html) {
        NSLog(@"%@", html);
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        if (websiteModel.value == 1 || websiteModel.value == 2) {
            NSString *strRegex = @"multi\">([\\s\\S]+?)<\\/article>";
            NSMutableArray *articleArr = [Tool getDataWithRegularExpression:strRegex content:html];
            for (NSString *article  in articleArr) {
                ArticleModel *model = [[ArticleModel alloc] init];
                NSMutableArray *detailArr = [Tool getDataWithRegularExpression:@"href=\"([\\s\\S]+?)\"" content:article];
                NSString *detail = detailArr[0];
                detail = [detail stringByReplacingOccurrencesOfString:@"href=\"" withString:@""];
                detail = [detail stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                SqliteTool *sqlTool = [SqliteTool sharedInstance];
                ArticleModel *result = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                             where:[NSString stringWithFormat:@"website_id = %d and detail_url = \"%@\"", websiteModel.value, detail]
                                                                             field:@"*"
                                                                             Class:[ArticleModel class]];
                if (result.name == nil) {
                    NSMutableArray *titleArr = [Tool getDataWithRegularExpression:@"title=\"([\\s\\S]+?)\"" content:article];
                    NSString *title = titleArr[0];
                    title = [title stringByReplacingOccurrencesOfString:@"title=\"" withString:@""];
                    title = [title stringByReplacingOccurrencesOfString:@"\"" withString:@""];

                    NSMutableArray *imageArr = [Tool getDataWithRegularExpression:@"src=\"([\\s\\S]+?.jpg)\"" content:article];
                    NSString *imgPath = imageArr[0];
                    imgPath = [imgPath stringByReplacingOccurrencesOfString:@"src=\"" withString:@""];
                    imgPath = [imgPath stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    model.name = title;
                    model.detail_url = [detail stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    model.img_url = [imgPath stringByReplacingOccurrencesOfString:websiteModel.url withString:@""];
                    if ([sqlTool insertTable:@"article"
                                     element:@"website_id,name,detail_url,img_url"
                                       value:[NSString stringWithFormat:@"%d,\"%@\",\"%@\",\"%@\"", websiteModel.value, model.name, model.detail_url, model.img_url]]) {
                        model = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                      where:[NSString
                                                                          stringWithFormat:@"website_id = %d and detail_url = \"%@\"", websiteModel.value, model.detail_url]
                                                                      field:@"*"
                                                                      Class:[ArticleModel class]];
                    }
                } else {
                    model = result;
                }
                [resultArr addObject:model];
            }
            success(resultArr);
        } else if (websiteModel.value == 3) {
//            nl">([\s\S]+?)<\/ul> 获取列表，选择结果第二个arr[1]
            NSString *strRegex = @"nl\">([\\s\\S]+?)<\\/ul>";
//            NSString *content = [Tool getDataWithRegularExpression:strRegex content:html][1];
            NSMutableArray *contentArr = [Tool getDataWithRegularExpression:strRegex content:html];
            NSString *content = contentArr[1];
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
                                                                             where:[NSString stringWithFormat:@"website_id = %d and detail_url = \"%@\"", websiteModel.value, detail]
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

                        }
                    }
                    NSString *detailUrl = [NSString stringWithFormat:@"%@%@", websiteModel.url, detail];
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
                                         element:@"website_id,name,detail_url,img_url"
                                           value:[NSString stringWithFormat:@"%d,\"%@\",\"%@\",\"%@\"", websiteModel.value, model.name, model.detail_url, model.img_url]]) {
                            ArticleModel *newModel = (ArticleModel *) [sqlTool findDataFromTable:@"article"
                                                                          where:[NSString
                                                                              stringWithFormat:@"website_id = %d and detail_url = \"%@\"", websiteModel.value, model.detail_url]
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
        }
    }                      failure:^(NSError *_Nonnull error) {
        failure(error);
    }];
}


+ (void)getImageDetailWithType:(WebsiteModel *)websiteModel detailUrl:(NSString *)detailUrl progress:(void (^)(int page))progress success:(void (^)(NSMutableArray *_Nonnull))success failure:(void (^)(NSError *_Nonnull))failure {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", websiteModel.url, detailUrl];
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

    }
}

@end
