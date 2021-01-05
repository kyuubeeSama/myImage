//
//  FileTool.h
//  myimage
//
//  Created by liuqingyuan on 2018-12-18.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface QYFileModel : NSObject

@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *size;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *filetype;
@property(nonatomic, copy) NSString *fileurl;
@property(nonatomic, strong) PHAsset *set;
@property (nonatomic, assign) BOOL has_upload;
-(void)getImageAndInfoComplete:(void(^)(void))complete;

@end

@interface FileTool : NSObject

+(NSString *)getDocumentPath;
+(NSString *)createDocumentWithname:(NSString *)name;
+(NSString *)getDatabasePathWithDBName:(NSString *)name;
///1：文件已存在 2.文件创建失败 3.文件创建成功
+(int)createFileWithPath:(NSString *)path;
+ (BOOL)isValidPNGByImage:(UIImage *)image;
+ (BOOL)isValidJPGByImage:(UIImage *)image;
+ (NSString *)createFilePathWithName:(NSString *)name;

-(NSMutableArray *)getLocalImage;
// 删除本地文件
+(BOOL)deleteLocalFileWithPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
