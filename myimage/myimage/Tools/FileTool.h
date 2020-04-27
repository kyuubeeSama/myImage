//
//  FileTool.h
//  myimage
//
//  Created by liuqingyuan on 2018-12-18.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface FileTool : NSObject

+(NSString *)getDocumentPath;
+(NSString *)createDocumentWithname:(NSString *)name;
+(NSString *)getDatabasePathWithDBName:(NSString *)name;
///1：文件已存在 2.文件创建失败 3.文件创建成功
+(int)createFileWithPath:(NSString *)path;
+ (BOOL)isValidPNGByImage:(UIImage *)image;
+ (BOOL)isValidJPGByImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
