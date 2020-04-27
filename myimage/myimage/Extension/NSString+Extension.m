//
//  NSString+Extension.m
//  xiaoshoubao
//
//  Created by MD101 on 15/9/11.
//  Copyright (c) 2015年 yaocheng. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)


- (CGSize)sizeWithFont:(UIFont *)font{
//    NSDictionary *att = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSDictionary *att = @{NSFontAttributeName:font};
    return [self sizeWithAttributes:att];
}


- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
//    NSDictionary *att = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSDictionary *att = @{NSFontAttributeName:font};
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:att context:nil].size;
}

- (NSMutableAttributedString *)covertToAttributedStringWithFont:(NSInteger)font lineSpace:(NSInteger)lineSpace titleColor:(UIColor *)titleColor{
    NSMutableAttributedString *tempAstr = [[NSMutableAttributedString alloc] initWithString:self];
    [tempAstr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font] range:NSMakeRange(0, self.length)];
    [tempAstr addAttribute:NSForegroundColorAttributeName value:titleColor range:NSMakeRange(0, self.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = lineSpace;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    [tempAstr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, self.length)];
    return tempAstr;
    
}

+ (NSString *)getParamValueFromUrl:(NSString *)url paramName:(NSString *)paramName
{
    if (![paramName hasSuffix:@"="]) {
        paramName = [NSString stringWithFormat:@"%@=", paramName];
    }
    NSString *str = nil;
    NSRange   start = [url rangeOfString:paramName];
    if (start.location != NSNotFound) {
        // confirm that the parameter is not a partial name match
        unichar  c = '?';
        if (start.location != 0) {
            c = [url characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#') {
            NSRange     end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
            NSUInteger  offset = start.location + start.length;
            str = end.location == NSNotFound ?[url substringFromIndex:offset] : [url substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByRemovingPercentEncoding];
        }
    }
    return str;
}


@end
