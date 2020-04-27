//
//  FileTool.m
//  myimage
//
//  Created by liuqingyuan on 2018-12-18.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "FileTool.h"

@implementation FileTool

+ (NSString *)getDocumentPath {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return documentPath;
}

+ (NSString *)createDocumentWithname:(NSString *)name {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:name];
//    NSLog(@"%@", path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!bCreateDir) {
            NSLog(@"创建文件夹失败！");
            return nil;
        }
        NSLog(@"创建文件夹成功，文件路径%@", path);
        return path;
    } else {
        return path;
    }
}

+(NSString *)getDatabasePathWithDBName:(NSString *)name {
    NSString *documentPath = [self getDocumentPath];
    NSString *path = [NSString stringWithFormat:@"%@/database/%@", documentPath, name];
    return path;
}

+(int)createFileWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        return 1;
    }else{
        if([fileManager createFileAtPath:path contents:nil attributes:nil]){
            return 2;
        }else{
            return 3;
        }
    }
}

+ (BOOL)isValidPNGByImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    //第一种情况：通过[UIImage imageWithData:data];直接生成图片时，如果image为nil，那么imageData一定是无效的
    if (image == nil && imageData != nil) {
        return NO;
    }
    //第二种情况：图片有部分是OK的，但是有部分坏掉了，它将通过第一步校验，那么就要用下面这个方法了。将图片转换成PNG的数据，如果PNG数据能正确生成，那么这个图片就是完整OK的，如果不能，那么说明图片有损坏
    if (imageData == nil) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isValidJPGByImage:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    //第一种情况：通过[UIImage imageWithData:data];直接生成图片时，如果image为nil，那么imageData一定是无效的
    if (image == nil && imageData != nil) {
        return NO;
    }
    //第二种情况：图片有部分是OK的，但是有部分坏掉了，它将通过第一步校验，那么就要用下面这个方法了。将图片转换成PNG的数据，如果PNG数据能正确生成，那么这个图片就是完整OK的，如果不能，那么说明图片有损坏
    if (imageData == nil) {
        return NO;
    } else {
        return YES;
    }
}

@end
