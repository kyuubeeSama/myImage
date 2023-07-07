//
//  Tool.h
//  myimage
//
//  Created by liuqingyuan on 2019/3/1.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tool : NSObject

+(NSString *)getMemonry;

+(NSMutableArray *)getDataWithRegularExpression:(NSString *)RegularExpression content:(NSString *)content;

+(void)showAlertWithTitle:(nullable NSString *)title Message:(nullable NSString *)message withSureBtnClick:(void(^ __nullable)(void))sureBtnClick;

// 剔除html内容
+ (NSString *)filterHTML:(NSString *)html;
// 网址转换
+ (NSString *)UTFtoGBK:(NSString *)urlStr;
// 网页内容转换
+ (NSData *)getGBKDataWithData:(NSData *)data;
// 替换图片中可能包含的域名地址
+ (NSString *)replaceDomain:(NSString *)webUrl urlStr:(NSString *)urlStr;
@end

NS_ASSUME_NONNULL_END
