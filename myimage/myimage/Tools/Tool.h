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

@end

NS_ASSUME_NONNULL_END
