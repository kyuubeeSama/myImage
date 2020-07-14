//
//  NetWorkingTool.h
//  myimage
//
//  Created by liuqingyuan on 2018-12-18.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MethodType) {
    /**get*/
        AFNetworkMethodGet,
    /**post*/
        AFNetworkMethodPost
};

@interface NetWorkingTool : NSObject

@property (nonatomic, copy)void(^downloadProgress)(double progress);
@property (nonatomic, copy)void(^downloadCompleted)(void);
@property(nonatomic,copy)void(^imgDownloadCompleted)(NSInteger imgID);
@property(nonatomic,copy)void(^imgDownloadFailure)(NSInteger imgID);
// 下载文件
-(void)downloadingFileWithUrl:(NSString *)urlStr path:(NSString *)path;
// 获取文件内容
+(void)getHtmlWithUrl:(NSString *)urlStr WithData:(NSDictionary * _Nullable)dic success:(void(^)(NSString *html))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
