//
//  NSString+Extension.h
//  xiaoshoubao
//
//  Created by MD101 on 15/9/11.
//  Copyright (c) 2015年 yaocheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Extension)

/* 计算文本大小 */
- (CGSize)sizeWithFont:(UIFont *)font;
/* 计算文本大小 */
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (NSMutableAttributedString *)covertToAttributedStringWithFont:(NSInteger)font lineSpace:(NSInteger)lineSpace titleColor:(UIColor *)titleColor;

+ (NSString *)getParamValueFromUrl:(NSString *)url paramName:(NSString *)paramName;

+ (BOOL)MyStringIsNULL:(NSString *)string;

@end
