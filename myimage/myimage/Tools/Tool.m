//
//  Tool.m
//  myimage
//
//  Created by liuqingyuan on 2019/3/1.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//

#import "Tool.h"
#import "NSObject+Tool.h"
@implementation Tool

+(NSString *)getMemonry
{
    NSUInteger size = [[SDImageCache sharedImageCache] totalDiskSize];
    NSString *cache = @"";
    if (size < 1000) {
        cache = @"0.00M";
    } else if (1000 > size && size < 1000 * 1000){
        cache = [NSString stringWithFormat:@"%0.2fk",size/1000.0];
    } else{
        cache = [NSString stringWithFormat:@"%0.2fM",size/1000.0/1000.0];
    }
    return cache;
}

+(NSMutableArray *)getDataWithRegularExpression:(NSString *)RegularExpression content:(NSString *)content {
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:RegularExpression options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&error];
//    NSArray *matches = [reg matchesInString:content options:NSMatchingCompleted range:NSMakeRange(0, [content length])];
    NSArray *matches = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
//        NSLog(@"%@",[content substringWithRange:range]);
        NSString *article = [content substringWithRange:range];
        [resultArr addObject:article];
    }
    return resultArr;
}

+(void)showAlertWithTitle:(NSString *)title Message:(NSString *)message withSureBtnClick:(void (^)(void))sureBtnClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sureBtnClick();
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}

+ (NSString *)filterHTML:(NSString *)html {
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
+ (NSString *)UTFtoGBK:(NSString *)urlStr {
    //GBK编码
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSString *encodeContent = [urlStr stringByAddingPercentEscapesUsingEncoding:enc];
//stringByAddingPercentEncodingWithAllowedCharacters:
//    NSCharacterSet *set = NSCharacterSet
    NSString *encodeContent = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return encodeContent;
}

/// gbk网页内容转utf8
/// @param data 数据
+ (NSData *)getGBKDataWithData:(NSData *)data {
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *postHtmlStr = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSString *utf8HtmlStr = [postHtmlStr stringByReplacingOccurrencesOfString:@"<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    NSData *utf8HtmlData = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
    return utf8HtmlData;
}

@end
