//
//  Tool.m
//  myimage
//
//  Created by liuqingyuan on 2019/3/1.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//

#import "Tool.h"

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
    NSArray *matches = [reg matchesInString:content options:nil range:NSMakeRange(0, content.length)];
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
//        NSLog(@"%@",[content substringWithRange:range]);
        NSString *article = [content substringWithRange:range];
        [resultArr addObject:article];
    }
    return resultArr;
}

@end
