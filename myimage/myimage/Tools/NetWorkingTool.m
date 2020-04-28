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

-(void)downloadingFileWithUrl:(NSString *)urlStr path:(NSString *)path {
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
/* 下载地址 */
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        if(self.downloadProgress){
            self.downloadProgress(downloadProgress.fractionCompleted);
        }
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSInteger codeint = error.code;
        if (codeint == (-999)) {
            NSLog(@"链接超时");
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 提示到前台
                //下载完成
                if (self.downloadCompleted) {
                    self.downloadCompleted();
                }
            });
        }
    }];
    [downloadTask resume];
}

//MARK: 获取网站html内容
+(void)getHtmlWithUrl:(NSString *)urlStr WithData:(NSDictionary * _Nullable)dic success:(void (^)(NSString * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSURL *baseURL = [NSURL URLWithString:urlStr];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Safari/605.1.15",@"Accept":@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}];
    AFHTTPSessionManager *manager=[[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//发起GET请求
    [manager GET:urlStr parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *html = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        success(html);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"错误地址是%@,错误信息是%@",urlStr,error.localizedDescription);
        failure(error);
    }];
}

@end
