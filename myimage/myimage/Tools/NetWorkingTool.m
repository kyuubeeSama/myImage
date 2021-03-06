//
//  NetWorkingTool.m
//  myimage
//
//  Created by liuqingyuan on 2018-12-18.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "NetWorkingTool.h"

@implementation NetWorkingTool

+ (AFHTTPSessionManager *)makeBaseManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:40.0f];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/css", @"text/xml", @"text/plain", @"application/javascript", @"application/x-www-form-urlencoded", @"image/*", nil];
    return manager;
}

+(void)downloadingFileWithUrl:(NSString *)urlStr savePath:(NSString *)savePath downloadProgress:(void (^)(NSProgress *))progress success:(void (^)(void))success failure:(void (^)(NSError *))failure{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        progress(downloadProgress);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:savePath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            success();
        }else{
            failure(error);
        }
    }];
    [downloadTask resume];
}

//MARK: 获取网站html内容
+(void)getHtmlWithUrl:(NSString *)urlStr WithData:(nullable NSDictionary *)dic success:(void (^)(NSString *))success failure:(nullable void (^)(NSError *))failure {
    NSURL *baseURL = [NSURL URLWithString:urlStr];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Safari/605.1.15",@"Accept":@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}];
    [config setHTTPAdditionalHeaders:@{@"Connection":@"Keep-Alive",
                                       @"Accept":@"text/html, application/xhtml+xml, */*",
                                       @"Accept-Language":@"en-US,en;q=0.8,zh-Hans-CN;q=0.5,zh-Hans;q=0.3",
                                       @"User-Agent":@"Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko"}];
    AFHTTPSessionManager *manager=[[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //发起GET请求
    [manager GET:urlStr parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *html = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([NSString MyStringIsNULL:html]) {
            
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            // 使用如下方法 将获取到的数据按照gbkEncoding的方式进行编码，结果将是正常的汉字
            html = [[NSString alloc]initWithData:responseObject encoding:gbkEncoding];
        }
        success(html);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"错误地址是%@,错误信息是%@",urlStr,error.localizedDescription);
        failure(error);
    }];
}

@end
