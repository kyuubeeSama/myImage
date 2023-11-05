//
//  FileTool.m
//  myimage
//
//  Created by liuqingyuan on 2018-12-18.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "FileTool.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation QYFileModel

-(void)getImageAndInfoComplete:(void (^)(void))complete{
    // 获取图片和图片信息
    [[PHImageManager defaultManager] requestImageDataForAsset:_set options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSURL *url = [info valueForKey:@"PHImageFileURLKey"];
        self->_fileurl = [url absoluteString];
        NSInteger sizelength = imageData.length;
        NSString *fileSize;
        if (sizelength > 1024 && sizelength < (1024 * 1024)) {
            fileSize = [NSString stringWithFormat:@"%.2fK", (float) sizelength / 1024];
        } else if (sizelength < 1024) {
            fileSize = [NSString stringWithFormat:@"%luB", (unsigned long) sizelength];
        } else if (sizelength > (1024 * 1024) && sizelength < (1024 * 1024 * 1024)) {
            fileSize = [NSString stringWithFormat:@"%.2fM", (float) sizelength / (1024 * 1024)];
        } else {
            fileSize = [NSString stringWithFormat:@"%.2fG", (float) sizelength / (1024 * 1024 * 1024)];
        }
        self->_size = fileSize;
        UIImage *image = [UIImage imageWithData:imageData];
        //                    获取缩略图
        self->_image = [self thumbnailWithImageWithoutScale:image size:CGSizeMake(100, image.size.height * 100 / image.size.width)];
        if (complete) {
            complete();
        }
    }];
}

// 获取指定大小的缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize {
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    } else {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width / asize.height > oldsize.width / oldsize.height) {
            rect.size.width = asize.height * oldsize.width / oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width) / 2;
            rect.origin.y = 0;
        } else {
            rect.size.width = asize.width;
            rect.size.height = asize.width * oldsize.height / oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height) / 2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

@end

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

+ (NSString *)createFilePathWithName:(NSString *)name {
    NSString *path = [[self getDocumentPath] stringByAppendingPathComponent:name];
    return path;
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

-(NSMutableArray *)getLocalImage{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:path];
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        QYFileModel *model = [[QYFileModel alloc] init];
        if ([fileName hasSuffix:@".png"] || [fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".jpeg"] || [fileName hasSuffix:@".bmp"] || [fileName hasSuffix:@".gif"] || [fileName hasSuffix:@".PNG"] || [fileName hasSuffix:@".JPG"] || [fileName hasSuffix:@".JPEG"] || [fileName hasSuffix:@".BMP"] || [fileName hasSuffix:@".GIF"] || [fileName isEqualToString:@"HEIC"] || [fileName isEqualToString:@"heic"]) {
            model.filetype = @"image/png/jpg/jpeg/gif";
        } else {
            continue;
        }
        NSDictionary *fileInfo = [dirEnum fileAttributes];
        //            NSLog(@"%@",fileInfo);
        NSArray *pathArr = [fileName componentsSeparatedByString:@"/"];
        model.filename = [pathArr lastObject];
        NSArray *nameArr = [fileName componentsSeparatedByString:@"."];
        model.name = nameArr[0];
        NSString *time = [NSString stringWithFormat:@"%@", fileInfo[@"NSFileModificationDate"]];
        model.time = [time substringToIndex:19];
        NSInteger sizelength = [[NSString stringWithFormat:@"%@", fileInfo[@"NSFileSize"]] integerValue];
        NSString *fileSize;
        if (sizelength > 1024) {
            fileSize = [NSString stringWithFormat:@"%.0luK", sizelength / 1024];
        } else if (sizelength < 1024) {
            fileSize = [NSString stringWithFormat:@"%luB", (unsigned long) sizelength];
        } else if (sizelength > (1024 * 1024)) {
            fileSize = [NSString stringWithFormat:@"%.0luM", sizelength / (1024 * 2014)];
        } else {
            fileSize = [NSString stringWithFormat:@"%.0luG", sizelength / (1024 * 1024 * 1024)];
        }
        model.size = fileSize;
        model.filePath = [path stringByAppendingPathComponent:fileName];
        [array addObject:model];
    }
    return array;
}

// 删除本地文件
+(BOOL)deleteLocalFileWithPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}
+(void)saveImgWithImageData:(NSData *)data result:(void (^)(BOOL, NSError * _Nonnull))result {
    // 1. 获取相片库对象
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    // 2. 调用changeBlock
    [library performChanges:^{
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest;
        // 2.2 取出指定名称的相册
        PHAssetCollection *assetCollection = [[FileTool new] getCurrentPhotoCollectionWithTitle:@"pornhub"];
        // 2.3 判断相册是否存在
        if (assetCollection) { // 如果存在就使用当前的相册创建相册请求
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else { // 如果不存在, 就创建一个新的相册请求
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"pornhub"];
        }
        
        // 2.4 根据传入的相片, 创建相片变动请求
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:data]];
        // 2.4 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        // 2.5 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // 3. 判断是否出错, 如果报错, 声明保存不成功
        result(success,error);
    }];
}

- (PHAssetCollection *)getCurrentPhotoCollectionWithTitle:(NSString *)collectionName {
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 2. 遍历搜索集合并取出对应的相册
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    return nil;
}

@end
